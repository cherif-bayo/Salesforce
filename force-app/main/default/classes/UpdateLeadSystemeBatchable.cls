global class UpdateLeadSystemeBatchable implements Database.Batchable<sObject>{
    global UpdateLeadSystemeBatchable(){
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id, Systeme_d_exploitation__c FROM Lead WHERE Systeme_d_exploitation__c = null';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Lead> leads){
        Map<Id, Lead> leadsById = new Map<Id, Lead>();
        for(Lead lead : leads){
            leadsById.put(lead.Id, lead);
        }
    
        Telechargement__c[] telechargements = [SELECT Lead__c, Systeme__c FROM Telechargement__c WHERE Lead__c in :leadsById.keySet() ORDER BY CreatedDate DESC];
    
        Map<Id, Telechargement__c> telechargementsByLeadId = new Map<Id, Telechargement__c>();
        for(Telechargement__c telechargement : telechargements){
            if(telechargementsByLeadId.containsKey(telechargement.Lead__c) == false){
                telechargementsByLeadId.put(telechargement.Lead__c, telechargement);
            }
        }
        
        List<Lead> leadsToUpdate = new List<Lead>();
        for(Id leadId : telechargementsByLeadId.keySet()){
            leadsById.get(leadId).Systeme_d_exploitation__c = telechargementsByLeadId.get(leadId).Systeme__c;
            leadsToUpdate.add(leadsById.get(leadId));
        }
        
        update leadsToUpdate;
    }

    global void finish(Database.BatchableContext BC){
       // Get the ID of the AsyncApexJob representing this batch job
       // from Database.BatchableContext.
       // Query the AsyncApexJob object to retrieve the current job's information.
       AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
          TotalJobItems, CreatedBy.Email
          FROM AsyncApexJob WHERE Id =
          :BC.getJobId()];
       // Send an email to the Apex job's submitter notifying of job completion.
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       String[] toAddresses = new String[] {Label.emailAdmin};
       mail.setToAddresses(toAddresses);
       mail.setSubject('Apex Sharing Recalculation ' + a.Status);
       mail.setPlainTextBody
       ('The batch Apex job processed ' + a.TotalJobItems +
       ' batches with '+ a.NumberOfErrors + ' failures.');
       Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}