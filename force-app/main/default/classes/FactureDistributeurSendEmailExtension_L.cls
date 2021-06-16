public class FactureDistributeurSendEmailExtension_L {

	private Facture_Distributeur__c facture;
	private Map<String, Id> contactIdByEmail;
	public List<SelectOption> emails { get; set; }
	public String email { get; set; }
	public String GetFactureId() { return facture.Id; }
	public String Subject { get; set; }
	public String Body { get; set; }
	private ContentVersion fileContent;
	public String AttachmentLink { get; set; }
	public String AttachmentName { get; set; }
	public Boolean isValid { get; set; }
	public String sender = '';

	public FactureDistributeurSendEmailExtension_L(ApexPages.StandardController standardController) {
		facture = [select Id, GenerateFactureEN__c, Compte_lie__c, PeriodeEN__c, Periode__c from Facture_Distributeur__c where Id = :standardController.getId() limit 1];

		isValid = true;
		contactIdByEmail = new Map<String, Id> ();

		emails = new List<SelectOption> ();
		for (Contact contact :[SELECT Email FROM Contact WHERE AccountId = :facture.Compte_Lie__c]) {
			emails.add(new SelectOption(contact.Email, contact.Email));
			contactIdByEmail.put(contact.Email, contact.Id);
		}

		if (emails.size() > 0) {
			ContentDocumentLink[] cdls = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :facture.Id order by SystemModStamp DESC LIMIT 1];
			if (cdls.size() > 0) {
				fileContent = [SELECT VersionData, Title, FileType FROM ContentVersion WHERE ContentDocumentId = :cdls[0].ContentDocumentId AND IsLatest = true LIMIT 1];

				if (facture.GenerateFactureEN__c) {
					sender = 'Equipe commerciale XLSTAT';
					Subject = 'XLSTAT Invoice ' + facture.PeriodeEN__c;
					Body = 'Dear Sirs,\n\nPlease find enclosed our invoice for the period ' + facture.PeriodeEN__c + '.\n\nKind Regards,\nThe XLSTAT sales team';
				} else {
					sender = 'XLSTAT Sales Team';
					Subject = 'XLSTAT Facture ' + facture.Periode__c;
					Body = 'Bonjour,\n\nVeuillez trouver ci-jointe notre facture pour la période de ' + facture.Periode__c + '.\n\nCordialement,\nL\'équipe de ventes d\'XLSTAT';
				}

				AttachmentLink = '/' + fileContent.Id;
				AttachmentName = fileContent.Title;
			} else {
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Aucun fichier de facture trouvé.'));
				isValid = false;
			}
		} else {
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Aucun contact lié au distributeur.'));
			isValid = false;
		}
	}

	public PageReference Send() {
		try {

			// Piece jointe d'email : la facture en PDF
			Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
			efa.setFileName(fileContent.Title);
			efa.setBody(fileContent.VersionData);
			efa.setContentType('application/' + fileContent.FileType);

			// Création du mail avec la pièce jointe
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			mail.setSenderDisplayName(sender);
			mail.setSubject(Subject);
			mail.setPlainTextBody(Body);
			mail.setReplyTo('sales@xlstat.com');
			mail.setToAddresses(new String[] { email });
			mail.setBccAddresses(new String[] { 'sales@xlstat.com' });
			mail.setTargetObjectId(contactIdByEmail.get(Email));
			mail.setSaveAsActivity(true);
			mail.setFileAttachments(new Messaging.EmailFileAttachment[] { efa });

			// Envoi d'email
			Messaging.SendEmailResult[] emailsResults = Messaging.sendEmail(new Messaging.Email[] { mail });

			// Ajout d'un post dans le fil chatter
			if (emailsResults[0].isSuccess()) {
				String Post = 'Email avec la facture distributeur envoyé à ' + email;
				ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement('internal', facture.Id, ConnectApi.FeedElementType.FeedItem, Post);

				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Email envoyé avec succés.'));
			} else { // Sinon message d'erreur
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Une erreur est survenue lors de l\'envoi de la facture.'));
			}

			PageReference pr = new PageReference('/' + facture.Id);
			pr.setRedirect(true);
			return pr;
		} catch(Exception ex) {
			System.debug('>>>> exception :' + ex.getMessage() + ' ' + ex.getStackTraceString());
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Erreur :' + ex.getMessage()));
		}
		return null;
	}
}