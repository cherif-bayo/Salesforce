@isTest (SeeAllData=false)
public class DiscountsUpdateEURFromGBPTest{
    public static testMethod void testMain() {    
        Pricebook2 pricebookGBP = new Pricebook2();
        pricebookGBP.Name = 'Addinsoft GBP';
        
        insert pricebookGBP;
        
        Pricebook2 pricebookEUR = new Pricebook2();
        pricebookEUR.Name = 'Addinsoft EUR';
        
        insert pricebookEUR;
        
        Product2 product = new Product2();
        product.Name = 'Test';
        
        insert product;
        
        AyPrice__DiscountDetail__c discountEur1 = new AyPrice__DiscountDetail__c();
        discountEur1.AyPrice__Product_Id__c = product.Id;
        discountEur1.AyPrice__Price_Book_Id__c = pricebookEUR.Id;
        discountEur1.AyPrice__Range_From__c = 1;
        discountEur1.AyPrice__Range_To__c = 1;
        discountEur1.Price_After_Discount__c = 200;
        
        insert discountEur1;
        
        AyPrice__DiscountDetail__c discountEur2 = discountEur1.clone();
        discountEur2.AyPrice__Range_From__c = 2;
        discountEur2.AyPrice__Range_To__c = 2;
        discountEur2.Price_After_Discount__c = 199;
        
        insert discountEur2;
        
        AyPrice__DiscountDetail__c discountEur3 = discountEur1.clone();
        discountEur3.AyPrice__Range_From__c = 30;
        discountEur3.AyPrice__Range_To__c = null;
        discountEur3.Price_After_Discount__c = 198;
        
        insert discountEur3;
        
        AyPrice__DiscountDetail__c discountGbp1 = new AyPrice__DiscountDetail__c();
        discountGbp1.AyPrice__Product_Id__c = product.Id;
        discountGbp1.AyPrice__Price_Book_Id__c = pricebookGBP.Id;
        discountGbp1.AyPrice__Range_From__c = 1;
        discountGbp1.AyPrice__Range_To__c = 1;
        discountGbp1.Price_After_Discount__c = 150;
        
        insert discountGbp1;
        
        AyPrice__DiscountDetail__c discountGbp2 = discountGbp1.clone();
        discountGbp2.AyPrice__Range_From__c = 2;
        discountGbp2.AyPrice__Range_To__c = 2;
        discountGbp2.Price_After_Discount__c = 149;
        
        insert discountGbp2;
        
        AyPrice__DiscountDetail__c discountGbp3 = discountGbp1.clone();
        discountGbp3.AyPrice__Range_From__c = 30;
        discountGbp3.AyPrice__Range_To__c = null;
        discountGbp3.Price_After_Discount__c = 148;
        
        insert discountGbp3;
        
        Test.startTest();
        Database.executeBatch(new DiscountsUpdateEURFromGBPBatch(), 200);
        Test.stopTest();
        
        discountGbp1 = [SELECT Price_After_Discount__c FROM AyPrice__DiscountDetail__c WHERE Id = :discountGbp1.Id];
        discountGbp2 = [SELECT Price_After_Discount__c FROM AyPrice__DiscountDetail__c WHERE Id = :discountGbp2.Id];
        discountGbp3 = [SELECT Price_After_Discount__c FROM AyPrice__DiscountDetail__c WHERE Id = :discountGbp3.Id];                
        
        System.assertEquals(discountEur1.Price_After_Discount__c, discountGbp1.Price_After_Discount__c);
        System.assertEquals(discountEur2.Price_After_Discount__c, discountGbp2.Price_After_Discount__c);
        System.assertEquals(discountEur3.Price_After_Discount__c, discountGbp3.Price_After_Discount__c);                
    }
}