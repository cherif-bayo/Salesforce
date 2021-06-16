@isTest 
public class testOrderProductTrigger{
    
    @testSetup
    public static void setUp() {
        Account acc = new Account (Name='test');
        insert acc;
        
        PriceBook2 pb = new PriceBook2 (Name='test');
        insert pb;
        
        Product2 p = new Product2 (Name='test',Type_licence__c='Perpet');
        insert p;
                
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = p.Id, 
                                                          UnitPrice = 15000,CurrencyIsoCode = 'EUR');
        insert standardPrice;
        
        PricebookEntry pbe = new PricebookEntry (Product2Id = p.Id, Pricebook2Id = pb.Id,
                                                 CurrencyIsoCode = 'EUR', UnitPrice = 10000);
        insert pbe;
        
        Order order = new Order (MontantModule__c=50, MontantSolution__c=50, MontantFormation__c= 50, 
                                 MontantExpertise__c=50, MontantShipping__c=50, MontantSupport__c=50,
                                 EffectiveDate = date.today(), Status= 'Version préliminaire',
                                 AccountId = acc.Id,Pricebook2Id = pb.Id,CurrencyIsoCode = 'EUR');
        insert order;
        
        insert new OrderItem (OrderId = order.id, PricebookEntryId = pbe.Id,Quantity = 2,UnitPrice = 10000);
        
        Coupon__c coupon =  new Coupon__c (Name='COUPON', DomainName__c = 'STUDENT',Fin__c= Date.today().addDays(1) ,Debut__c = Date.today().addDays(-1),discount_EUR__c=50,discount_USD__c=25);
		insert coupon;
    }
    
    @isTest
     public static void testTriggerNewAndUpdate(){
         Pricebook2 p = [select Id from Pricebook2 where Name='test'];
         Product2 po = [select Id from Product2 where Name='test'];
     
         AyPrice__DiscountDetail__c dd = new AyPrice__DiscountDetail__c();
         dd.AyPrice__Price_Book_Id__c = p.Id;
         dd.AyPrice__Product_Id__c = po.Id;
         dd.Price_After_Discount__c = 10;
         dd.AyPrice__Range_from__c = 1;
         dd.AyPrice__Range_to__c = 1;
         dd.AyPrice__Row_Counter__c = 1;
         insert dd;
         
         PricebookEntry pe = [select Id from PricebookEntry where Product2.Id = :dd.AyPrice__Product_Id__c and Pricebook2.id = :dd.AyPrice__Price_Book_Id__c and CurrencyIsoCode = 'EUR' limit 1];
     
         List<String> ordersWithStatus = new List<String>();
         for(Order order : [select Id from Order where Status = 'Version préliminaire']){
             ordersWithStatus.add(order.Id);
         }
     
         OrderItem orderItem = [select PricebookEntryId, Quantity, OrderId, UnitPrice from OrderItem where PricebookEntryId = :pe.Id and OrderId in :ordersWithStatus limit 1];
         Order order = [select Ref_du_coupon__c from Order where Id = :orderItem.OrderId limit 1];
         
         order.Ref_du_coupon__c = null;
         update order;
         
         OrderItem orderItemTest = new OrderItem();
         orderItemTest.PricebookEntryId = orderItem.PricebookEntryId;
         orderItemTest.Quantity = orderItem.Quantity;
         orderItemTest.OrderId = orderItem.OrderId;
         orderItemTest.UnitPrice = orderItem.UnitPrice;
         insert orderItemTest;
         
         Account account = [select Id, Discount_global__c from Account limit 1];
         account.Discount_global__c = 25;
         order.AccountId = account.Id;
         update order;
         
         OrderItem orderItemTest2 = new OrderItem();
         orderItemTest2.PricebookEntryId = orderItem.PricebookEntryId;
         orderItemTest2.Quantity = orderItem.Quantity;
         orderItemTest2.OrderId = orderItem.OrderId;
         orderItemTest2.UnitPrice = orderItem.UnitPrice;
         insert orderItemTest2;
         
         Coupon__c coupon = [select Id from Coupon__c limit 1];
         
         if(coupon != null){
             order.Ref_du_coupon__c = coupon.Id;
             update order;
             
             OrderItem orderItemTest3 = new OrderItem();
             orderItemTest3.PricebookEntryId = orderItem.PricebookEntryId;
             orderItemTest3.Quantity = orderItem.Quantity;
             orderItemTest3.OrderId = orderItem.OrderId;
             orderItemTest3.UnitPrice = orderItem.UnitPrice;
             insert orderItemTest3;
         
             delete orderItemTest3;
         }
         
         List<Currencies_Exchange_Rates__c> exchangeRates = new List<Currencies_Exchange_Rates__c>();
         for(Currencies_Exchange_Rates__c exchangeRate : [SELECT Rate__c, Day__c, CurrencyIsoCode FROM Currencies_Exchange_Rates__c WHERE Day__c = :Date.today()]){
            exchangeRate.Rate__c = 3;
            exchangeRates.add(exchangeRate);
        }
        update exchangeRates;
  }
}