global class B001_ManageRenewalOrders implements Database.Batchable<sObject> {
	global List<Exception> B001_ManageRenewalOrdersErrors = new List<Exception> ();

	global Database.QueryLocator start(Database.BatchableContext BC) {
		Integer nbDays = Integer.valueOf(Parameters.getString('Renewal_NbOfDays'));
		if (Test.isRunningTest()) nbDays = 0; // Pour être independant du parametre custom metadata
		DateTime dtValue = DateTime.now().addDays(-nbDays);
		String query ='SELECT Id FROM Order where status=\'ShareIt - Envoyer clé Nalpeiron\' and Renewal_Auto__c=true and CreatedDate <= ' + dtValue.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
		System.debug('[B001_ManageRenewalOrders] query :' + query);
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<Order> orders) {
		System.debug('>>' + orders);
		for (Order order : orders) {
			try {
				CL001_SendKeyByEmail sender = new CL001_SendKeyByEmail(order.Id);
				sender.SendEmails();
				order.Status = 'Payée';
			} catch(Exception e) {
				System.debug('[B001_ManageRenewalOrders] exception :' + e + '/' + e.getStackTraceString());
				B001_ManageRenewalOrdersErrors.add(e);
			}
		}
		update orders;
	}

	global void finish(Database.BatchableContext BC) {
		if (!B001_ManageRenewalOrdersErrors.isEmpty()) {
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			mail.setSubject('Erreur durant l\'envoi automatique des clés pour le renouvellement des licences annuelles');
			mail.setToAddresses(new List<String> { Label.emailAdmin });
			mail.setPlainTextBody(buildBodyFor(B001_ManageRenewalOrdersErrors));
			Messaging.sendEmail(new Messaging.Email[] { mail });
		}
	}

	private String buildBodyFor(List<Exception> exceptions) {
		String body;

		for (Exception e : exceptions) {
			body += e.getMessage();
			body += e.getStackTraceString();
		}

		return body;
	}
}