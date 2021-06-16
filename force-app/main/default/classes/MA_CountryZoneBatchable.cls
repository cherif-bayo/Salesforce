/**
 * MA Country Zone Batchable
 */
global class MA_CountryZoneBatchable implements Database.Batchable<sObject> {

	/** Variable Declaration */
	String Query;

	/**
	 * [MA_CountryZoneBatchable description]
	 * @return [description]
	 */
	global MA_CountryZoneBatchable() {
		Date dateFilter = Date.today() - 365 ;
		//Query = 'SELECT BillingCountry, BillingCountryCode, Montant_Hors_FraisEUR__c FROM Order ';//WHERE CreatedDate >= ' + dateFilter;
		Query = 'SELECT Id, Country, CountryCode, Nombre_de_telechargements__c FROM Lead LIMIT 50000';
	}

	/**
	 * [start description]
	 * @param  BC [description]
	 * @return    [description]
	 */
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(Query);
	}

	/**
	 * [execute description]
	 * @param  BC    [description]
	 * @param  scope [description]
	 * @return       [description]
	 */
   	global void execute(Database.BatchableContext BC, List<Lead> scope) {
   		/** Variable Declaration */
	   	List<MA_CountryZone__c> lstCountryZone = new List<MA_CountryZone__c>();
	   	List<Lead> lstLead = new List<Lead>();

	   	Integer nbCountryZone = [SELECT count() FROM MA_CountryZone__c];
	   	if(nbCountryZone > 0){
	   		lstCountryZone = [SELECT AmountSpent__c, Country__c, Download__c FROM MA_CountryZone__c];
	   	}

		/* Initialize AmountSpent */
		if(lstCountryZone.size() > 0){
			for(MA_CountryZone__c cz : lstCountryZone){
				cz.AmountSpent__c = 0;
				cz.Download__c = 0;
			}
			update lstCountryZone;
		}


		/* Browse a list */
		List<Order> lstOrder = [SELECT BillingCountry, BillingCountryCode, Montant_Hors_FraisEUR__c FROM Order];
		for(Order o: lstOrder) {
			if([SELECT Id FROM MA_CountryZone__c WHERE Country__c = :o.BillingCountry].size() == 0){
				MA_CountryZone__c newRecord = new MA_CountryZone__c();
				newRecord.Name = o.BillingCountry;
				newRecord.AmountSpent__c = o.Montant_Hors_FraisEUR__c;
				newRecord.Country__c = o.BillingCountry;
				newRecord.CountryCode__c = o.BillingCountryCode;
				insert newRecord;
			}
			else {
				MA_CountryZone__c updateRecord = [SELECT AmountSpent__c, Country__c FROM MA_CountryZone__c WHERE Country__c = :o.BillingCountry LIMIT 1];
				updateRecord.AmountSpent__c += o.Montant_Hors_FraisEUR__c;
				update updateRecord;
			}
		}

		/* Browse Nb download */
		Integer limitSOQL = 50000;
		Integer valueOffset = 0;
		Integer nbLead = [SELECT count() FROM Lead];
		if(nbLead > 0){
			//for(Integer i = 0; i < nbLead; i += limitSOQL) {
				lstLead = [SELECT Id, Country, CountryCode, Nombre_de_telechargements__c FROM Lead LIMIT :limitSOQL ];//OFFSET :valueOffset];
				//valueOffset += limitSOQL;

				for(Lead l : scope){
					if([SELECT Id FROM MA_CountryZone__c WHERE Country__c = :l.Country].size() == 0){
						MA_CountryZone__c newRecord = new MA_CountryZone__c();
						newRecord.Name = l.Country;
						newRecord.Download__c = l.Nombre_de_telechargements__c;
						newRecord.Country__c = l.Country;
						newRecord.CountryCode__c = l.CountryCode;
						insert newRecord;
					}
					else {
						MA_CountryZone__c updateRecord = [SELECT AmountSpent__c, Country__c FROM MA_CountryZone__c WHERE Country__c = :l.Country LIMIT 1];
						updateRecord.AmountSpent__c += l.Nombre_de_telechargements__c;
						update updateRecord;
					}
				}
			//}
		}
	}

	/**
	 * [finish description]
	 * @param  BC [description]
	 * @return    [description]
	 */
	global void finish(Database.BatchableContext BC) {
		/** Variable Declaration */
		List<MA_CountryZone__c> lstCountryZone = new List<MA_CountryZone__c>();

		/* Get list custom settings */
		try {
			lstCountryZone = [SELECT AmountSpent__c, Country__c, Download__c, Ratio__c FROM MA_CountryZone__c];
		} catch(Exception e) {
			System.debug(e.getMessage());
		}

		/* Calculate the ratio */
		for(MA_CountryZone__c cz: lstCountryZone) {
			if(cz.Download__c > 0){
				cz.Ratio__c = cz.AmountSpent__c / cz.Download__c;
			}
			else {
				cz.Ratio__c = 0;
			}
		}

		/* Update custom settings */
		try {
			update lstCountryZone;
		} catch(Exception e) {
			System.debug(e.getMessage());
		}
	}

}