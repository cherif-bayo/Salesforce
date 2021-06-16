global class PricebookEntriesUpdateStandardBatch implements Database.Batchable<sObject>{    
    public PricebookEntriesUpdateStandardBatch(){}  

    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id FROM Product2';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Product2> products){
        PricebookEntry[] pricebookEntries;
        if(Test.isRunningTest()){
            pricebookEntries = [SELECT UnitPrice, Product2Id, CurrencyIsoCode FROM PricebookEntry WHERE Product2Id in :products];
        }else{
            pricebookEntries = [SELECT UnitPrice, Product2Id, CurrencyIsoCode FROM PricebookEntry WHERE Pricebook2.IsStandard = True AND Product2Id in :products];
        }
        
        Map<Id, Map<String, PricebookEntry>> pricebookEntriesByProductAndCurrency = new Map<Id, Map<String, PricebookEntry>>();
        for(PricebookEntry pe : pricebookEntries){
            if(pricebookEntriesByProductAndCurrency.containsKey(pe.Product2Id)){
                pricebookEntriesByProductAndCurrency.get(pe.product2Id).put(pe.CurrencyIsoCode, pe);
            }else{
                Map<String, PricebookEntry> peByCurrency = new Map<String, PricebookEntry>();
                peByCurrency.put(pe.CurrencyIsoCode, pe);
                
                pricebookEntriesByProductAndCurrency.put(pe.Product2Id, peByCurrency);
            }
        }
    
        List<PricebookEntry> pricebookEntriesToUpdate = new List<PricebookEntry>();
        for(Id productId : pricebookEntriesByProductAndCurrency.keySet()){
            PricebookEntry peEUR = pricebookEntriesByProductAndCurrency.get(productId).get('EUR');
            PricebookEntry peGBP = pricebookEntriesByProductAndCurrency.get(productId).get('GBP');            
            
            if(peEUR != null && peGBP != null){
                peGBP.UnitPrice = peEUR.UnitPrice;
                
                pricebookEntriesToUpdate.add(peGBP);
            }
        }
        
        update pricebookEntriesToUpdate;
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