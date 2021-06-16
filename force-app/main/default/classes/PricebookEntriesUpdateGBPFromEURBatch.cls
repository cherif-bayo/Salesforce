global class PricebookEntriesUpdateGBPFromEURBatch implements Database.Batchable<sObject>{   
    private static String PRICEBOOK_NAME_GBP = 'Addinsoft GBP';
    private static String PRICEBOOK_NAME_EUR = 'Addinsoft EUR';    
 
    public PricebookEntriesUpdateGBPFromEURBatch(){}  

    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT UseStandardPrice, UnitPrice, Product2Id FROM PricebookEntry WHERE Pricebook2.Name = \'' + PRICEBOOK_NAME_GBP + '\' AND CurrencyIsoCode = \'GBP\'';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<PricebookEntry> pricebookEntriesGBP){
        PricebookEntry[] pricebookEntriesEUR = [SELECT UnitPrice, Product2Id FROM PricebookEntry WHERE Pricebook2.Name = :PRICEBOOK_NAME_EUR AND CurrencyIsoCode = 'EUR'];
        Map<Id, PricebookEntry> pricebookEntriesEURByProductId = new Map<Id, PricebookEntry>();
        for(PricebookEntry pe : pricebookEntriesEUR){
            pricebookEntriesEURByProductId.put(pe.Product2Id, pe);
        }
    
        Map<Id, PricebookEntry> pricebookEntriesGBPByProductId = new Map<Id, PricebookEntry>();
        for(PricebookEntry pe : pricebookEntriesGBP){
            pricebookEntriesGBPByProductId.put(pe.Product2Id, pe);
        }
        
        for(Id productId : pricebookEntriesGBPByProductId.keySet()){
            PricebookEntry peGBP = pricebookEntriesGBPByProductId.get(productId);
            PricebookEntry peEUR = pricebookEntriesEURByProductId.get(productId);
            
            peGBP.UnitPrice = peEUR.UnitPrice;
            peGBP.UseStandardPrice = false;
        }
        
        update pricebookEntriesGBPByProductId.values();
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