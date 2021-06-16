@isTest
public class OrderUpdateOrderItemsDiscountTest{
    public static testMethod void test(){        
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
        pes.UnitPrice = 50;
        
        insert pes;
        
        PricebookEntry pe = new PricebookEntry();
        pe.Product2Id = product.Id;
        pe.Pricebook2Id = pricebook.Id;
        pe.UnitPrice = 50;
        
        insert pe;
        
        Account account = new Account();
        account.Name = 'Test';
        account.BillingCountryCode = 'FR';
        
        insert account;
        
        Contact contact = new Contact();
        contact.FirstName = 'Test';
        contact.LastName = 'Test';
        contact.Email = 'test@xlstat.com';
        contact.Langue__c = 'FR';
        contact.AccountId = account.Id;
        
        insert contact;
        
        Order order = new Order();
        order.EffectiveDate = Date.today();
        order.AccountId = account.Id;
        order.Status = 'Version préliminaire';
        order.Contact_Lie__c = contact.id;
        order.CurrencyIsoCode = 'USD';
        order.BillingCountryCode = 'FR';
        order.Pricebook2Id = pricebook.Id;
        
        insert order;
        
        OrderItem orderItem = new OrderItem();
        orderItem.PricebookEntryId = pe.Id;
        orderItem.OrderId = order.Id;
        orderItem.Quantity = 2;
        orderItem.UnitPrice = 50;
        
        insert orderItem;
        
        orderItem = [SELECT Percent_Discount_Coupon__c, Percent_Discount_Manuel__c, Percent_Discount_Total__c, Percent_Discount_Client__c, Total_Price_After_Discount__c FROM OrderItem WHERE Id = :orderItem.Id];
        
        System.assertEquals(0, orderItem.Percent_Discount_Total__c);
        System.assertEquals(null, orderItem.Percent_Discount_Coupon__c);
        System.assertEquals(null, orderItem.Percent_Discount_Client__c);
        System.assertEquals(null, orderItem.Percent_Discount_Manuel__c);   
        System.assertEquals(100, orderItem.Total_Price_After_Discount__c);
        
        account.Discount_Global__c = 50;
        
        update account;
        
        order.Discount_Client_Activated__c = true;
        order.Discount_Manuel_Activated__c = true;
        order.Discount_Manuel__c = 50;
        
        update order;
        
        Test.setCurrentPage(Page.OrderUpdateOrderItemsDiscountExtension);
        Test.startTest();
        OrderUpdateOrderItemsDiscountExtension controller = new OrderUpdateOrderItemsDiscountExtension(new ApexPages.StandardController(order));
        controller.UpdateDiscounts();
        Test.stopTest();
        
        orderItem = [SELECT Percent_Discount_Coupon__c, Percent_Discount_Manuel__c, Percent_Discount_Total__c, Percent_Discount_Client__c, Total_Price_After_Discount__c FROM OrderItem WHERE Id = :orderItem.Id];
        
        System.assertEquals(75, orderItem.Percent_Discount_Total__c);
        System.assertEquals(null, orderItem.Percent_Discount_Coupon__c);
        System.assertEquals(50, orderItem.Percent_Discount_Manuel__c);
        System.assertEquals(50, orderItem.Percent_Discount_Client__c);   
        System.assertEquals(25, orderItem.Total_Price_After_Discount__c);
    }
}