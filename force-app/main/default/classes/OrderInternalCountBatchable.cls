global class OrderInternalCountBatchable implements Database.Batchable<sObject>, Database.AllowsCallouts{    
    global OrderInternalCountBatchable(){
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Internal_Count__c FROM Order';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Order> orders){
        for(Order order : orders){
            order.Internal_Count__c = 1;
        }
        
        update orders;
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