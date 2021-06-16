public class FactureSendEmailExtension_L {

	private final Facture__c facture;
	Private String templateName;
	private ContentVersion fileContent;
	private EmailTemplate emailTemplate;
	private Boolean isPdfGenerated = true;
	private Boolean isFR;

	public Boolean HasPreview { get; set; }
	public String EmailText { get; set; }
	public String EmailAddress { get; set; }
	public String EmailSubject { get; set; }
	public String EmailAttachmentLink { get; set; }
	public String EmailAttachmentName { get; set; }

	public FactureSendEmailExtension_L(ApexPages.StandardController stdController) {
		facture = [SELECT Name, Id, Commande_Lie__r.OrderNumber, Commande_Lie__r.Contact_Lie__r.Langue__c, Commande_Lie__r.Contact_Email__c, Commande_Lie__r.Contact_Lie__c, Commande_Lie__c FROM Facture__c WHERE Id = :stdController.getId()];
		isFR = facture.Commande_Lie__r.Contact_Lie__r.Langue__c == 'FR';

		ContentDocumentLink[] cdls = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :facture.Id order by SystemModStamp DESC LIMIT 1];
		if (cdls.size() > 0) {
			fileContent = [SELECT VersionData, Title, FileType FROM ContentVersion WHERE ContentDocumentId = :cdls[0].ContentDocumentId AND IsLatest = true LIMIT 1];

			templateName = 'Facture ';
			if (isFR) {
				templateName += 'FR';
				EmailSubject = 'XLSTAT - Votre facture ';
			} else {
				templateName += 'EN';
				EmailSubject = 'XLSTAT - Your invoice ';
			}
			EmailSubject += facture.Name;
			emailTemplate = [SELECT Id, Body FROM EmailTemplate WHERE Name = :this.templateName];
		} else {
			isPdfGenerated = false;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Vous n \'avez pas généré de facture en pdf'));
		}
	}

	public PageReference Cancel() {
		PageReference pageRef = new PageReference('/' + facture.Id);
		pageRef.setRedirect(true);
		return pageRef;
	}

	public void Preview() {
		if (isPdfGenerated) {
			EmailAttachmentLink = '/' + fileContent.Id;
			EmailAttachmentName = fileContent.Title;
			EmailAddress = facture.Commande_Lie__r.Contact_Email__c;
			EmailText = emailTemplate.Body.replaceAll('\n', '<br/>');
			HasPreview = true;
		}
	}

	public void Send() {

		// Piece jointe d'email : la facture en PDF
		Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
		efa.setFileName(fileContent.Title);
		efa.setBody(fileContent.VersionData);
		efa.setContentType('application/' + fileContent.FileType);

		// Création du mail avec la pièce jointe
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		mail.setTemplateId(emailTemplate.Id);
		mail.setReplyTo('sales@xlstat.com');
		mail.setToAddresses(new String[] { facture.Commande_Lie__r.Contact_Email__c });
		mail.setBccAddresses(new String[] { 'sales@xlstat.com' });
		mail.setTargetObjectId(facture.Commande_Lie__r.Contact_Lie__c);
		mail.setSaveAsActivity(true);
		mail.setFileAttachments(new Messaging.EmailFileAttachment[] { efa });

		if (isFR) mail.setSenderDisplayName('Equipe commerciale XLSTAT');
		else mail.setSenderDisplayName('XLSTAT Sales Team');

		// Envoi d'email
		Messaging.SendEmailResult[] emailsResults = Messaging.sendEmail(new Messaging.Email[] { mail });

		// Ajout d'un post dans le fil chatter
		if (emailsResults[0].isSuccess()) {			
			String Post = 'Email avec la facture envoyé à ' + facture.Commande_Lie__r.Contact_Email__c;
			Post += ' correspondant à la commande ' + facture.Commande_Lie__r.OrderNumber;
			ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement('internal', facture.Id, ConnectApi.FeedElementType.FeedItem, Post);

			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Email envoyé avec succés.'));
		} else { // Sinon message d'erreur
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Une erreur est survenue lors de l\'envoi de la facture.'));
		}
		HasPreview = false;
	}
}