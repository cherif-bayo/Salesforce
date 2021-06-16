global class SCH001_RelanceClientSupport implements Schedulable {

	global SCH001_RelanceClientSupport() {}

	global void execute(System.SchedulableContext ctx) {
		Relance_Support__mdt[]  relances = [select DeveloperName, Case_Status__c, New_Status__c, Nb_Jours__c, Email_Template__c from Relance_Support__mdt];

		// Recupération des templates de mail à utiliser pour les relances
		List<String> templatesNames = new List<String> ();
		Map<String, String> templateIdByName = new Map<String, String> ();
		for (Relance_Support__mdt relance : relances) templatesNames.add(relance.Email_Template__c);
		List<EmailTemplate> templates = [Select Name from EmailTemplate where Name in :templatesNames];
		for (EmailTemplate template : templates) templateIdByName.put(template.Name, template.Id);
		System.debug('[SCH001_RelanceClientSupport] templates :' + templates);

		for (Relance_Support__mdt relance : relances) {
			System.debug('[SCH001_RelanceClientSupport] relance :' + relance);

			// Recuperation de la liste des tickets à relancer
			DateTime dtValue = DateTime.now().addDays(- Math.round(relance.Nb_Jours__c));
			System.debug('[SCH001_RelanceClientSupport] date limite :' + dtValue);

			String matchingLabel = '%' + relance.DeveloperName + '%';
			List<Case> cases = [SELECT contact.Email, caseNumber, ContactId, StatusRelances__c FROM Case WHERE
			                    Status = :relance.Case_Status__c AND
			                    DateChangementStatus__c <= :dtValue AND(NOT StatusRelances__c LIKE :matchingLabel)];
			System.debug('[SCH001_RelanceClientSupport] cases :' + cases);

			// Envoi des lots d'emails
			if (cases.size() > 0) sendEmails(cases, templateIdByName.get(relance.Email_Template__c), relance.DeveloperName, relance.New_Status__c);
		}
	}

	global void sendEmails(List<Case> cases, String templateId, String RelanceDeveloperName, String newStatus) { // public for test purpose
		String SEP = ',';
		List<Messaging.SingleEmailMessage> emails;
		List<WS_Error__c> errors = new List<WS_Error__c> ();

		// Recuperation de l'adresse support pour l'envoi des emails
		String senderEmailAdressId='';
		OrgWideEmailAddress[] oweas = [select Id from OrgWideEmailAddress where Address = 'info@xlstat.com'];
		if (oweas.size() > 0) senderEmailAdressId = oweas[0].Id;

		for (integer i = 0; i <= cases.size() / SalesforceLimits.MESSAGING_SENDEMAIL_LIMIT; i++) { // Decoupage en lot de 10 (ma
			emails = new List<Messaging.SingleEmailMessage> ();
			for (integer j = 0; j<Math.mod(cases.size(), SalesforceLimits.MESSAGING_SENDEMAIL_LIMIT); j++) {
				Case aCase = cases[SalesforceLimits.MESSAGING_SENDEMAIL_LIMIT * i + j];
				Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
				email.setTargetObjectId(acase.ContactId);
				email.setWhatId(acase.Id);
				email.setOrgWideEmailAddressId(senderEmailAdressId);
				email.setTemplateId(templateId);
				System.debug('[SCH001_RelanceClientSupport] email :' + email);

				emails.add(email);
			}

			// Envoi des 10 emails de relance
			Messaging.SendEmailResult[] results = Messaging.sendEmail(emails);

			for (integer j = 0; j<Math.mod(cases.size(), SalesforceLimits.MESSAGING_SENDEMAIL_LIMIT); j++) {
				Case aCase = cases[SalesforceLimits.MESSAGING_SENDEMAIL_LIMIT * i + j];

				if (results[j].isSuccess()) {
					aCase.StatusRelances__c = aCase.StatusRelances__c != null ? aCase.StatusRelances__c + SEP + RelanceDeveloperName : RelanceDeveloperName;
					if (newStatus != null && newStatus.length()> 0) aCase.status = newStatus;
				} else errors.add(new WS_Error__c(Email__c = aCase.contact.Email,
				                                  RecordId__c = aCase.Id,
				                                  WebserviceName__c = 'email',
				                                  Request__c = 'Le mail de relance pour ' + aCase.caseNumber + ' n\'a pu être envoyé'));
			}
		}
		update cases;
		insert errors;
	}
}