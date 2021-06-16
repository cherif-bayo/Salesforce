@isTest (SeeAllData=false)
public class PricebookEntriesUpdateStandardTest{
    public static testMethod void testMain() {            
        Product2 product = new Product2();
        product.Name = 'Test';
        
        insert product;
        
        PricebookEntry pes = new PricebookEntry();
        pes.Product2Id = product.Id;
        pes.Pricebook2Id = Test.getStandardPricebookId();
        pes.UnitPrice = 10;
        pes.CurrencyIsoCode = 'EUR';
        
        insert pes;
        
        PricebookEntry pesGBP = new PricebookEntry();
        pesGBP.Product2Id = product.Id;
        pesGBP.Pricebook2Id = Test.getStandardPricebookId();
        pesGBP.UnitPrice = 20;
        pesGBP.CurrencyIsoCode = 'GBP';
        
        insert pesGBP;
        
        Test.startTest();
        Database.executeBatch(new PricebookEntriesUpdateStandardBatch(), 200);
        Test.stopTest();
        
        pesGBP = [SELECT UnitPrice FROM PricebookEntry WHERE Id = :pesGBP.Id];
        
        System.assertEquals(pes.UnitPrice, pesGBP.UnitPrice);
    }
}