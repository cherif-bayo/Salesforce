global class UpdateNpsOrder implements Database.Batchable<sObject> {
	global UpdateNpsOrder() {
	}
	global Database.QueryLocator start(Database.BatchableContext BC) {
		String query = 'SELECT Already_Contacted__c, email__c, Nps_Consentment__c, OrderAmount__c, Nps_Note__c, Name, User_Comments__c, User_Domain__c, User_Key_Number__c, User_Language__c, Xlstat_Version__c FROM Reponse_Nps__c WHERE OrderAmount__c != null OR User_Key_Number__c != null OR User_Domain__c != null';
		return Database.getQueryLocator(query);
	}
	global void execute(Database.BatchableContext BC, List<Reponse_Nps__c> npss) {
		Map<String, Reponse_Nps__c> npsByKeyNumber = new Map<String, Reponse_Nps__c> ();
		for (Reponse_Nps__c nps : npss) if (nps.User_Key_Number__c != null) {
			npsByKeyNumber.put(nps.User_Key_Number__c, nps);
		}
		Flexera_Key__c[] Keys = [SELECT Id, Order__c, Account__c, Montant_commande__c, Contact__c, Date_limite__c, Date_relance__c, Domaine_Cmd__c, Domaine_utilisateur__c, Name FROM Flexera_Key__c WHERE Name in :npsByKeyNumber.keySet()];
		List<String> KeysIds = new List<String> ();
		for (Flexera_Key__c key : Keys) {
			keysIds.add(key.Id);
		}
		Map<Id, Reponse_Nps__c> npsToUpdate = new Map<Id, Reponse_Nps__c> ();
		for (Flexera_Key__c k : keys) {
			Reponse_Nps__c n = npsByKeyNumber.get(k.Name);
            //Decimal npsOrderAmount = n.OrderAmount__c;
			if (n != null && k != null) {
                //if(npsOrderAmount != null){ n.OrderAmount__c = k.Montant_commande__c; }
                n.OrderAmount__c = k.Montant_commande__c;
                n.User_Domain__c = k.Domaine_Cmd__c;
				if (!npsToUpdate.ContainsKey(n.Id)) npsToUpdate.put(n.Id, n);
			}
		}
		update npsToUpdate.values();       
	}
	global void finish(Database.BatchableContext BC) {
	}
}