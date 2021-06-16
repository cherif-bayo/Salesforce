public class SCH001_SendEmailInvoice implements Schedulable {

	private static String PREFIX_EMAIL_TEMPLATE = 'NEW_Facture_';

	public SCH001_SendEmailInvoice() {}

	public void execute(SchedulableContext ctx) {
		Date dateLimit = Date.today().addDays(-1); // Au dela ce n'est pas raisonnable de renvoyer les factures au client ;-) 
		List<Facture__c> factures = [select Name,GenerateFactureEN__c, commande_lie__r.Id, commande_lie__r.Contact_lie__r.Id, commande_lie__r.account.PersonContactId from Facture__c where Envoyee__c = false and PayedWithStripe__c = true and createddate >= :dateLimit];
		List<Facture__c> facturesEnvoyees = new List<Facture__c>();

		For (Facture__c f : factures) {
			try {
				// Recupération des templates de mail
				String emailTemplateName = PREFIX_EMAIL_TEMPLATE;
				if (!f.GenerateFactureEN__c) emailTemplateName += 'FR';
				else emailTemplateName += 'EN'; //valeur par defaut : anglais
				EmailTemplate template = [Select Id from EmailTemplate where Name = :emailTemplateName Limit 1];

				// Creation de piece jointe facture
				Messaging.EmailFileAttachment invoice = HelperFacture.getPDFFactureAttachmentFor(f);

				// Creation du mail de facture
				Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

				if (f.commande_lie__r.Contact_lie__r.Id != null) email.setTargetObjectId(f.commande_lie__r.Contact_lie__r.Id);
				else email.setTargetObjectId(f.commande_lie__r.account.PersonContactId);
				email.setWhatId(f.commande_lie__r.Id);
				email.setSenderDisplayName('XLSTAT Sales Team');
				email.setTemplateId(template.Id);
				email.setFileAttachments(new List<Messaging.EmailFileAttachment> { invoice });

				List<Messaging.SendEmailResult> results = Messaging.SendEmail(new Messaging.Email[] { email });
				if (!results.get(0).isSuccess()) {
					String errorMessage = results.get(0).getErrors() [0].getMessage();
					insert new WS_Error__c(WebserviceName__c = 'Envoi Email Avec la facture', Request__c = 'mail avec la facture  pas envoyé correctement Id= : ' + f.Id, errorMessage__c = errorMessage);
				} else {
					f.Envoyee__c = true;
					facturesEnvoyees.add(f);
				}
			} catch(Exception e) {
				insert new WS_Error__c(WebserviceName__c = 'Envoi Email Avec la facture', Request__c = 'mail avec la facture  pas envoyé correctement Id=' + f.Id, errorMessage__c = e.getMessage());
			}
		}
		update facturesEnvoyees;
	}
}