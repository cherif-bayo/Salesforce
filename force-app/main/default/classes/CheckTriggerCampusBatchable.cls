public class CheckTriggerCampusBatchable implements
	Database.Batchable<sObject>, Database.Stateful{
    // instance member to retain state across transactions
	// Test Adding comment
    public Integer recordsProcessed = 0;
        
    public Database.QueryLocator start(Database.BatchableContext bc){
        DateTime dateDeletion = Date.valueOf(System.Label.DateTrialDeletion);
        Integer NumberOfDeletion = Integer.valueOf(System.Label.TrialNumberDeletion);
        DateTime dateDeletion2 = Date.valueOf(System.Label.DateTrialDeletion);
        Integer NumberOfDeletion2 = Integer.valueOf(System.Label.TrialNumberDeletion);
        List<Flexera_Key__c> keysToUpdate = new List<Flexera_Key__c>();

        return Database.getQueryLocator(
            'SELECT ID, Name, Expires90DFromToday__c, Domaine_utilisateur__c FROM Flexera_Key__c WHERE Expires90DFromToday__c = true AND Domaine_utilisateur__c = \'Campus\' '
        );
    }
    
    public void execute(Database.BatchableContext bc, List<Flexera_Key__c> scope){
        //Process each batch of records
        for (Flexera_Key__c key : scope){
            key.Trigger_Expire_Key__c = true;
        }
        update scope;
        System.debug('Key is expiring :'+scope.size());
    }
    public void finish(Database.BatchableContext bc){
        System.debug(recordsProcessed + ' records processed. DeleteLead !');
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors,
            JobItemsProcessed,
            TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob
            WHERE Id = :bc.getJobId()];
        
    }
}