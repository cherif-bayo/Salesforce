@isTest
public class testOrderFraisShareIt{
    
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
    }
    
    @isTest
    public static void testMain(){
         Order order = [select Status from Order where Status = 'Version préliminaire' and NbOrderItems__c > 0 limit 1];
         order.Status = 'Validée';
         update order;
    }
}