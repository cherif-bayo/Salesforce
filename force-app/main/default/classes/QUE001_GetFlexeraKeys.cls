public class QUE001_GetFlexeraKeys implements Queueable, Database.AllowsCallouts {
    
    public void execute(QueueableContext context) {
        integer batchSize = Integer.valueOf(Parameters.getString('Trial_Flexera_Batch_Size'));
        
		List<Flexera_Key__c> keys = CL004_TrialKeyGeneration.GenerateTrialKeysInFlexera(batchSize);
        System.debug('[SCH001_GetFlexeraKeys] keys :'+keys);        
        insert keys;
        
        //Enregistrement des erreurs rencontrées lors de la génération des clés par flexera
        insert CL004_TrialKeyGeneration.errors; 
    }    
}