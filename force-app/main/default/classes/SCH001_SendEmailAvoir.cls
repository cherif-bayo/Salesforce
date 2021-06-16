public class SCH001_SendEmailAvoir implements Schedulable {
	private Avoir__c avoir;

	private static final String PREFIX_EMAIL_TEMPLATE = 'AVOIR_';

	public SCH001_SendEmailAvoir(Id avoirId) {
		this.avoir = [select Name, Commande_Lie__r.Contact_Lie__c, Commande_Lie__r.Contact_Lie__r.Langue__c,
		              Commande_Lie__r.Account.Langue__pc, commande_Lie__r.AddinsoftCompany__c, commande_lie__r.account.PersonContactId
		              from Avoir__c where Id = :avoirId limit 1];
	}

	public void execute(SchedulableContext ctx) {

		boolean IsFr = avoir.Commande_Lie__r.Contact_Lie__c == null ? 'FR'.equalsIgnoreCase(avoir.Commande_Lie__r.Account.Langue__pc) : 'FR'.equalsIgnoreCase(avoir.Commande_Lie__r.Contact_Lie__r.Langue__c);

		PageReference pgPDF;
		if (IsFr) pgPDF = new PageReference('/apex/Avoir_fr?id=' + avoir.Id);
		else pgPDF = new PageReference('/apex/Avoir_en?id=' + avoir.Id);

		//Création du PDF de l'avoir sour forme de version d'un file
		ContentVersion v = new ContentVersion();
		if (Test.isRunningTest()) v.versionData = blob.valueOf('Unit.Test');
		else v.versionData = pgPDF.getContent();
		v.title = 'Avoir n° ' + avoir.Name;
		v.PathOnClient = avoir.Name + '.pdf';
		v.ContentLocation = 'S';
		v.IsMajorVersion = true;
		insert v;

		// Recuperation du file généré à l'insertion de la version
		Id docId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :v.Id].ContentDocumentId;

		// Association du fichier PDF (file) à l'object avoir
		ContentDocumentLink cdl = new ContentDocumentLink();
		cdl.ContentDocumentId = docId;
		cdl.LinkedEntityId = avoir.Id;
		cdl.ShareType = 'I';
		insert cdl;

		try {
			// Recupération des templates de mail
			String emailTemplateName = PREFIX_EMAIL_TEMPLATE;
			if (IsFr) emailTemplateName += 'FR';
			else emailTemplateName += 'EN'; //valeur par defaut : anglais
			EmailTemplate template = [Select Id from EmailTemplate where Name = :emailTemplateName Limit 1];

			// Creation d'une pience jointe avec le devis en PDF
			Blob b = v.versionData;
			Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
			efa.setFileName('avoir.pdf');
			efa.setBody(b);

			// Creation du mail de facture
			Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

			if (avoir.commande_lie__r.Contact_lie__r.Id != null) email.setTargetObjectId(avoir.commande_lie__r.Contact_lie__r.Id);
			else email.setTargetObjectId(avoir.commande_lie__r.account.PersonContactId);
			email.setWhatId(avoir.commande_lie__r.Id);
			email.setSenderDisplayName('XLSTAT Sales Team');
			email.setTemplateId(template.Id);
			email.setFileAttachments(new List<Messaging.EmailFileAttachment> { efa });

			List<Messaging.SendEmailResult> results = Messaging.SendEmail(new Messaging.Email[] { email });
			if (!results.get(0).isSuccess()) {
				String errorMessage = results.get(0).getErrors() [0].getMessage();
				insert new WS_Error__c(WebserviceName__c = 'Envoi Email Avec l\'avoir', Request__c = 'mail avec l\'avoir pas envoyé correctement Id= : ' + avoir.Id, errorMessage__c = errorMessage);
			}
		} catch(Exception e) {
			insert new WS_Error__c(WebserviceName__c = 'Envoi Email Avec l\'avoir', Request__c = 'mail avec l\'avoir pas envoyé correctement Id=' + avoir.Id, errorMessage__c = e.getMessage());
		}
	}
}