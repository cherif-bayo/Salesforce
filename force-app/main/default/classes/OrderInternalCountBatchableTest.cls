@IsTest(seeAllData=false)
public class OrderInternalCountBatchableTest {   
    public static testMethod void testBatchable(){    
        Currencies_Exchange_Rates__c rate = new Currencies_Exchange_Rates__c();
        rate.Day__c = Date.today();
        rate.CurrencyIsoCode = 'USD';
        rate.Rate__c = 1;
        
        insert rate;
    
        Pricebook2 pricebook = new Pricebook2();
        pricebook.Name = 'Test';
        
        insert pricebook;
        
        Product2 product = new Product2();
        product.Name = 'Test';
        
        insert product;
        
        PricebookEntry pes = new PricebookEntry();
        pes.Product2Id = product.Id;
        pes.Pricebook2Id = Test.getStandardPricebookId();
        pes.UnitPrice = 10;
        
        insert pes;
        
        PricebookEntry pe = new PricebookEntry();
        pe.Product2Id = product.Id;
        pe.Pricebook2Id = pricebook.Id;
        pe.UnitPrice = 10;
        
        insert pe;
    
        Account account = new Account();
        account.Name = 'Test';
        
        insert account;
        
        Order order = new Order();
        order.AccountId = account.Id;
        order.Status = 'Version préliminaire';
        order.EffectiveDate = Date.today();
        order.Provenance__c = 'ShareIt';
        order.Ref_ShareIt__c = '123456789';
        order.Pricebook2Id = pricebook.Id;
        order.CurrencyIsoCode = 'USD';
        order.Internal_Count__c = 0;
        
        insert order;
        
        OrderItem orderItem = new OrderItem();
        orderItem.PricebookEntryId = pe.Id;
        orderItem.OrderId = order.Id;
        orderItem.Quantity = 1;
        orderItem.UnitPrice = 10;
        
        insert orderItem;
    
        Test.StartTest();        
        Database.executeBatch(new OrderInternalCountBatchable(), 50);
        Test.StopTest();
        
        Order[] ordersInternalCount = [SELECT Id FROM Order WHERE Internal_Count__c = 1 limit 2000];
        
        System.assertEquals(1, ordersInternalCount.size());
    }
}