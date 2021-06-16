global class UpdateContactSystemeBatchable implements Database.Batchable<sObject>{
    global UpdateContactSystemeBatchable(){
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id, Systeme_d_exploitation__c FROM Contact WHERE Systeme_d_exploitation__c = null';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Contact> contacts){
        Map<Id, Contact> contactsById = new Map<Id, Contact>();
        for(Contact contact : contacts){
            contactsById.put(contact.Id, contact);
        }
    
        Telechargement__c[] telechargements = [SELECT Contact__c, Systeme__c FROM Telechargement__c WHERE Contact__c in :contactsById.keySet() ORDER BY CreatedDate DESC];
    
        Map<Id, Telechargement__c> telechargementsByContactId = new Map<Id, Telechargement__c>();
        for(Telechargement__c telechargement : telechargements){
            if(telechargementsByContactId.containsKey(telechargement.Contact__c) == false){
                telechargementsByContactId.put(telechargement.Contact__c, telechargement);
            }
        }
        
        List<Contact> contactsToUpdate = new List<Contact>();
        for(Id contactId : telechargementsByContactId.keySet()){
            contactsById.get(contactId).Systeme_d_exploitation__c = telechargementsByContactId.get(contactId).Systeme__c;
            contactsToUpdate.add(contactsById.get(contactId));
        }
        
        update contactsToUpdate;
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