global class UpdateContactLead implements Database.Batchable<sObject> {
	global UpdateContactLead() {
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		String query = 'SELECT Systeme_d_exploitation__c, LeadSource, Email, XLSTAT_365__c, Piste_date_cr_ation__c, Piste_date_derni_re_recommandation__c, Piste_date_dernier_recommand__c, Piste_date_dernier_t_l_chargement__c, Piste_Premier_telechargement__c, Piste_nombre_de_recommandations__c, Piste_nombre_de_t_l_chargements__c, Piste_nombre_recommand__c, Piste_source_site__c FROM Contact';
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<Contact> contacts) {
		Map<String, Contact> contactsByEmail = new Map<String, Contact> ();
		for (Contact contact : contacts) if (contact.Email != null) {
			contactsByEmail.put(contact.Email, contact);
		}
		Lead[] leads = [SELECT Id, Systeme_d_exploitation__c, Date_premier_telechargement__c, LeadSource, CreatedDate, Email, Date_derniere_recommendation__c, Date_dernier_recommand__c, Date_dernier_telechargement__c, Nombre_de_recommandations__c, Nombre_de_telechargements__c, Nombre_recommand__c, Source_site__c FROM Lead WHERE Email in :contactsByEmail.keySet()];
		List<String> leadsIds = new List<String> ();
		for (Lead lead : leads) {
			leadsIds.add(lead.Id);
		}
		Telechargement__c[] telechargements = [SELECT Lead__r.Email, Lead__c, Contact__c FROM Telechargement__c WHERE Lead__c in :leadsIds];
		for (Telechargement__c telechargement : telechargements) if (contactsByEmail.get(telechargement.Lead__r.Email) != null && contactsByEmail.get(telechargement.Lead__r.Email).Id != null) { 
			telechargement.Contact__c = contactsByEmail.get(telechargement.Lead__r.Email).Id;
			telechargement.Lead__c = null;
		}
		XLSTAT_365_Activation__c[] activationsXLSTAT365 = [SELECT Lead__r.Email, Lead__c, Contact__c FROM XLSTAT_365_Activation__c WHERE Lead__c in :leadsIds];
		for (XLSTAT_365_Activation__c activation : activationsXLSTAT365) {
			activation.Contact__c = contactsByEmail.get(activation.Lead__r.Email).Id;
			activation.Lead__c = null;
		}
		Map<Id, Contact> contactsToUpdate = new Map<Id, Contact> ();
		for (Lead l : leads) {
			Contact c = contactsByEmail.get(l.Email);

			if (c != null && l != null) {
				c.Piste_date_cr_ation__c = l.CreatedDate;
				c.Piste_date_derni_re_recommandation__c = l.Date_derniere_recommendation__c;
				c.Piste_date_dernier_recommand__c = l.Date_dernier_recommand__c;
				c.Piste_date_dernier_t_l_chargement__c = l.Date_dernier_telechargement__c;
				c.Piste_premier_telechargement__c = l.Date_premier_telechargement__c;
				c.Piste_nombre_de_recommandations__c = l.Nombre_de_recommandations__c;
				c.Piste_nombre_de_t_l_chargements__c = l.Nombre_de_telechargements__c;
				c.Piste_nombre_recommand__c = l.Nombre_recommand__c;
				c.Piste_source_site__c = l.Source_site__c;
				c.LeadSource = l.LeadSource;
				c.XLSTAT_365__c = activationsXLSTAT365.size() > 0;
				c.Systeme_d_exploitation__c = l.Systeme_d_exploitation__c;

				if (!contactsToUpdate.ContainsKey(c.Id)) contactsToUpdate.put(c.Id, c);
			}
		}
		update contactsToUpdate.values();
		update telechargements;
        // Stop deleting Lead for now . Will see later what to do 
		// delete leads;
	}

	global void finish(Database.BatchableContext BC) {
	}
}