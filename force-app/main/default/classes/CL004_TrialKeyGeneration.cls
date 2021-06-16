public class CL004_TrialKeyGeneration {

	// Les erreurs doivent être récupérées après le traitement pour être enregistrées
	// Dans le but d'éviter de faire un appel DML avant un autre appel Webservices
	public static List<WS_Error__c> errors = new List<WS_Error__c> ();

	public static Flexera_Key__c GenerateTrialKeyInFlexera() {
		return GenerateTrialKeyInFlexera(CL003_Constants.DEFAULT_SOFTWARE); // Backward compatibility
	}

	public static Flexera_Key__c GenerateTrialKeyInFlexera(String softwareCode) {
		Flexera_Key__c newKey;
		Decimal TRIAL_QTY = Integer.valueOf(Parameters.getString('Trial_Number_Activations'));
		try {
			newKey = new Flexera_Key__c();
			newKey.Domaine_utilisateur__c = Parameters.getString('Trial_Domain_User');
			newKey.Nb_activations_allowed__c = TRIAL_QTY;
			newKey.Quantity__c = TRIAL_QTY;

			LicenseKey key = CryptlexFacade.getNewTrialKey(softwareCode);
			newKey.Entitlement_Id__c = key.id;
			newKey.Name = key.keyNumber;
			newKey.SoftwareCode__c = softwareCode;
			newKey.Software__c = new SoftwareService().getSoftwareNameFromCode(softwareCode);
			System.debug('>>>> CL004_Trial...gen - GenerateTrialKeyInFlexera - Flexera_Key__c newKey = '+newKey);
			System.debug('>>>> CL004_Trial...gen - GenerateTrialKeyInFlexera - LicenseKey key = '+key);
			System.debug('[CL004_TrialKeyGeneration] : génération de la clé trial pour '+ softwareCode +' : name=' + newKey.Name + ' id='+key.id);
		} catch(CryptlexException ce) {
			System.debug('erreur generation cle cryptlex');
			errors.add(new WS_Error__c(Request__c = 'GET', WebserviceName__c = 'Cryptlex webservices', ErrorMessage__c = 'erreur generation cle cryptlex'));
		}

		return newKey;
	}

	public static List<Flexera_Key__c> GenerateTrialKeysInFlexera(Integer numberOfKeys) {
		List<Flexera_Key__c> generatedKeys = new List<Flexera_Key__c> ();

		for (Integer i=0; i<numberOfKeys; i++) generatedKeys.add(GenerateTrialKeyInFlexera());
		System.debug('>>>> CL004_Trial...gen - GenerateTrialKeysInFlexera - generatedKeys = '+generatedKeys);
		return generatedKeys;
	}
}