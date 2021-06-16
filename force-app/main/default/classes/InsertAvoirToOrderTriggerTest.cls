@isTest
public class InsertAvoirToOrderTriggerTest{
    public static testMethod void testMain() {
        Decimal orderProductAmount = 100;
        Decimal avoirAmount = 50;
    
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
        pes.UnitPrice = orderProductAmount;
        
        insert pes;
        
        PricebookEntry pe = new PricebookEntry();
        pe.Product2Id = product.Id;
        pe.Pricebook2Id = pricebook.Id;
        pe.UnitPrice = orderProductAmount;
        
        insert pe;
    
        Account account = new Account();
        account.PersonEmail = 'test@test.com';
        account.FirstName = 'test';
        account.LastName = 'test';
        
        insert account;
        
        Order order = new Order();
        order.AccountId = account.Id;
        order.EffectiveDate = Date.today();
        order.Pricebook2Id = pricebook.Id;
        order.CurrencyIsoCode = 'USD';
        order.Status = 'Version préliminaire';
        
        insert order;
        
        OrderItem orderItem = new OrderItem();
        orderItem.PricebookEntryId = pe.Id;
        orderItem.OrderId = order.Id;
        orderItem.Quantity = 1;
        orderItem.UnitPrice = orderProductAmount;
        
        insert orderItem;
        
        order.Status = 'Validée';
        update order;
        
        Avoir__c avoir = new Avoir__c();
        avoir.Montant__c = avoirAmount;
        avoir.Commande_Lie__c = order.Id;
        avoir.Impact_Order_Price__c = false;
        
        insert avoir;
        
        order = [SELECT TotalAmountAfterDiscountShowed__c FROM Order WHERE Id = :order.Id];        
        avoir.Impact_Order_Price__c = true;
        
        update avoir;        
        order = [SELECT TotalAmountAfterDiscountShowed__c FROM Order WHERE Id = :order.Id];
		        
        delete avoir;        
        order = [SELECT TotalAmountAfterDiscountShowed__c FROM Order WHERE Id = :order.Id];        
    }
}