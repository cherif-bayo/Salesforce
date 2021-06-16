public class TrialProcessor implements
	Database.Batchable<sObject>, Database.Stateful{
    // instance member to retain state across transactions
    public Integer recordsProcessed = 0;
        
        public Database.QueryLocator start(Database.BatchableContext bc){
            DateTime dateDeletion = Date.valueOf(System.Label.DateTrialDeletion);
            Integer NumberOfDeletion = Integer.valueOf(System.Label.TrialNumberDeletion);
            
            return Database.getQueryLocator(
            	'SELECT ID, Name, CreatedDate, Domaine_utilisateur__c FROM Flexera_Key__c WHERE CreatedDate < :dateDeletion AND Domaine_utilisateur__c = \'Trial\' LIMIT :NumberOfDeletion'
            );
        }
        
        public void execute(Database.BatchableContext bc, List<Flexera_Key__c> scope){
            //Process each batch of records
            delete scope;
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