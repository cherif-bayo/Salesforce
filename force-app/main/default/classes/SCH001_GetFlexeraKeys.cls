global class SCH001_GetFlexeraKeys implements Schedulable,Database.AllowsCallouts {

    global void execute(SchedulableContext ctx) {
                
        String domainUserTrial = Parameters.getString('Trial_Domain_User');
        integer maxKeysStock = Integer.valueOf(Parameters.getString('Trial_Key_Stock_Volume'));        
        integer batchSize = Integer.valueOf(Parameters.getString('Trial_Flexera_Batch_Size'));   
        integer availableKeys = database.countQuery('SELECT count()  FROM Flexera_Key__c WHERE isInStock__c = True and Domaine_utilisateur__c = :domainUserTrial');
		integer nbLots = ((maxKeysStock - availableKeys) / batchSize) +1;
        
		if (Test.isRunningTest()) nbLots = 1; // For purpose testing because maxkeystock is unknown

        for (integer i=1; i<= nbLots ; i++) System.enqueueJob(new QUE001_GetFlexeraKeys());        		
    }
    
}