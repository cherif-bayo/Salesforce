global class UpdateKeysXlstatVersionBatchable implements Database.Batchable<SObject> {

	global UpdateKeysXlstatVersionBatchable() { }

	/**
	 * @description gets invoked when the batch job starts
	 * @param context contains the job ID
	 * @returns the record set as a QueryLocator object that will be batched for execution
	 */
	global Database.QueryLocator start(Database.BatchableContext context) {

		return Database.getQueryLocator('SELECT Date_limite__c FROM Flexera_Key__c where Domaine_utilisateur__c != \'Trial\' and Is_Inactive__c=false');
	}

	/**
	 * @description gets invoked when the batch job executes and operates on one batch of records. Contains or calls the main execution logic for the batch job.
	 * @param context contains the job ID
	 * @param scope contains the batch of records to process.
	 */
	global void execute(Database.BatchableContext context, List<Flexera_Key__c> scope) {

		// Get date of each version
		List<Version__c> versions = [select Date__c from Version__c order by Date__c asc];

		for (Version__c version : versions) {						
			for (Flexera_Key__c cle :scope) if (cle.Date_limite__c >= version.Date__c) cle.Version__c = version.Id;
		}

		update scope;
	}

	/**
	 * @description gets invoked when the batch job finishes. Place any clean up code in this method.
	 * @param context contains the job ID
	 */
	global void finish(Database.BatchableContext context) { }

}