@isTest (SeeAllData=false)
public class PricebookEntriesUpdateGBPFromEURTest{
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
        
        PricebookEntry peEUR = new PricebookEntry();
        peEUR = pes.clone();
        peEUR.Pricebook2Id = pricebookEUR.Id;
        
        insert peEUR;
        
        PricebookEntry peGBP = new PricebookEntry();
        peGBP = pesGBP.clone();
        peGBP.Pricebook2Id = pricebookGBP.Id;
        
        insert peGBP;
        
        Test.startTest();
        Database.executeBatch(new PricebookEntriesUpdateGBPFromEURBatch(), 200);
        Test.stopTest();
        
        peGBP = [SELECT UnitPrice FROM PricebookEntry WHERE Id = :peGBP.Id];
        
        System.assertEquals(peEUR.UnitPrice, peGBP.UnitPrice);
    }
}