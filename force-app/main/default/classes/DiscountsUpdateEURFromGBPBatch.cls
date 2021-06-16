global class DiscountsUpdateEURFromGBPBatch implements Database.Batchable<sObject>{    
    public DiscountsUpdateEURFromGBPBatch(){}  

    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id FROM Product2';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Product2> products){
        Map<Id, Map<Decimal, AyPrice__DiscountDetail__c>> discountsEURByProductAndQuantity = new Map<Id, Map<Decimal, AyPrice__DiscountDetail__c>>();
        for(AyPrice__DiscountDetail__c discount : [SELECT AyPrice__Product_Id__c, Price_After_Discount__c, AyPrice__Range_From__c FROM AyPrice__DiscountDetail__c WHERE AyPrice__Product_Id__c in :products AND AyPrice__Price_Book_Id__r.Name = 'Addinsoft EUR']){
            if(discountsEURByProductAndQuantity.containsKey(discount.AyPrice__Product_Id__c)){
                discountsEURByProductAndQuantity.get(discount.AyPrice__Product_Id__c).put(discount.AyPrice__Range_From__c, discount);
            }else{
                Map<Decimal, AyPrice__DiscountDetail__c> discountByQuantity = new Map<Decimal, AyPrice__DiscountDetail__c>();
                discountByQuantity.put(discount.AyPrice__Range_From__c, discount);
                
                discountsEURByProductAndQuantity.put(discount.AyPrice__Product_Id__c, discountByQuantity);
            }
        }
        
        Map<Id, Map<Decimal, AyPrice__DiscountDetail__c>> discountsGBPByProductAndQuantity = new Map<Id, Map<Decimal, AyPrice__DiscountDetail__c>>();
        for(AyPrice__DiscountDetail__c discount : [SELECT AyPrice__Product_Id__c, Price_After_Discount__c, AyPrice__Range_From__c FROM AyPrice__DiscountDetail__c WHERE AyPrice__Product_Id__c in :products AND AyPrice__Price_Book_Id__r.Name = 'Addinsoft GBP']){
            if(discountsGBPByProductAndQuantity.containsKey(discount.AyPrice__Product_Id__c)){
                discountsGBPByProductAndQuantity.get(discount.AyPrice__Product_Id__c).put(discount.AyPrice__Range_From__c, discount);
            }else{
                Map<Decimal, AyPrice__DiscountDetail__c> discountByQuantity = new Map<Decimal, AyPrice__DiscountDetail__c>();
                discountByQuantity.put(discount.AyPrice__Range_From__c, discount);
                
                discountsGBPByProductAndQuantity.put(discount.AyPrice__Product_Id__c, discountByQuantity);
            }
        }
        
        List<AyPrice__DiscountDetail__c> discountsToUpdate = new List<AyPrice__DiscountDetail__c>();
        for(Id productId : discountsGBPByProductAndQuantity.keySet()){
            Map<Decimal, AyPrice__DiscountDetail__c> discountsByQuantityGBP = discountsGBPByProductAndQuantity.get(productId);
            Map<Decimal, AyPrice__DiscountDetail__c> discountsByQuantityEUR = discountsEURByProductAndQuantity.get(productId);            
            
            if(discountsByQuantityEUR != null){
                for(Decimal quantity : discountsByQuantityGBP.keySet()){
                    AyPrice__DiscountDetail__c discountGBP = discountsByQuantityGBP.get(quantity);
                    AyPrice__DiscountDetail__c discountEUR = discountsByQuantityEUR.get(quantity);
                    
                    if(discountEUR != null){
                        discountGBP.Price_After_Discount__c = discountEUR.Price_After_Discount__c;
                        
                        discountsToUpdate.add(discountGBP);
                    }
                }
            }
        }
        
        update discountsToUpdate;
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