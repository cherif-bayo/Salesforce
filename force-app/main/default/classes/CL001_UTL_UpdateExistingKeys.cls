public class CL001_UTL_UpdateExistingKeys {

	public static List<FlexeraController.ResultGenerateKey> updateKeys(List<String> keyNames, Order order) {
		List<FlexeraController.ResultGenerateKey> resultsFlexeraGeneratedKey = new List<FlexeraController.ResultGenerateKey> (); //retour de la methode
		Date limitDate = Date.today().addYears(1);
		
		// Clonage des SObject licences flexera dans SF puis changement de la date limite         
		Flexera_Key__c[] existingFlexeraKeys = [SELECT Share_It__c, Date_Limite__c, Order__c, Name,Quantity__c FROM Flexera_Key__c WHERE Name in :keyNames ORDER BY Date_Limite__c DESC];
		List<Flexera_Key__c> flexeraKeysToInsert = new List<Flexera_Key__c> ();
		Map<String, Flexera_Key__c> existingFlexeraKeysSingles = new Map<String, Flexera_Key__c> ();
		for (Flexera_Key__c existingFlexeraKey : existingFlexeraKeys) {
			if (!existingFlexeraKeysSingles.containsKey(existingFlexeraKey.Name)) existingFlexeraKeysSingles.put(existingFlexeraKey.Name, existingFlexeraKey);
		}
		for (Flexera_Key__c existingFlexeraKey : existingFlexeraKeysSingles.values()) {
			Flexera_Key__c newKey = existingFlexeraKey.clone();
			newKey.Date_Limite__c = limitDate;
			newKey.Order__c = order.Id;
			newKey.Share_It__c = true;
			newKey.Quantity__c = existingFlexeraKey.Quantity__c;
			flexeraKeysToInsert.add(newKey);
		} // flexeraKeysToInsert est enregistré à la fin de la méthode après le callout flexera	

		// Mise à jour de la date limite des licences dans le SI Flexera        
		String expiration = order.Type_licence__c == ParametersForOrders.SEND_KEY_LICENSE_TYPE_2 || order.Type_licence__c == ParametersForOrders.SEND_KEY_LICENSE_TYPE_3 ? FlexeraController.EXPIRATION_PERMANENT : FlexeraController.EXPIRATION_EXPIRING;
		resultsFlexeraGeneratedKey.addAll(updateLimitDate(keyNames, limitDate, expiration));

		// Renvoie le resultats de la MAJ dans flexera avec les cles clonés dans SF
		for (Integer i = 0; i<resultsFlexeraGeneratedKey.size(); i++) {
			if (flexeraKeysToInsert.size()> i) resultsFlexeraGeneratedKey[i].GeneratedKeys = new List<Flexera_Key__c> { flexeraKeysToInsert[i] };
		}
		
		// Insertion en base après le callout
		insert flexeraKeysToInsert;

		return resultsFlexeraGeneratedKey;
	}

	private static List<FlexeraController.ResultGenerateKey> updateLimitDate(List<String> keys, Date limitDate, String expiration) {
		List<FlexeraController.ResultGenerateKey> updatedKeys = new List<FlexeraController.ResultGenerateKey> (); //retour de la methode

		for (String licenseKey : keys) {
			FlexeraController.ResultGenerateKey resultGenerateKey = new FlexeraController.ResultGenerateKey();
			resultGenerateKey.Status = FlexeraController.UpdateKeyLimit(null, licenseKey, expiration); // Mise à jour de la date limite dans Flexera
			updatedKeys.add(resultGenerateKey);
		}

		return updatedKeys;
	}
}