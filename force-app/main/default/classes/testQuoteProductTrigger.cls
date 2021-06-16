@IsTest
public class testQuoteProductTrigger{

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
                CurrencyIsoCode = 'EUR', UnitPrice = 10000, IsActive=true);
        insert pbe;

        Opportunity opp = new Opportunity();
        opp.Name = 'MyOpportunity';
        opp.AccountId = acc.Id;
        opp.Type = 'Test';
        opp.CurrencyIsoCode = 'EUR';
        opp.CloseDate = Date.today() + 90;
        opp.StageName = 'Proposition/Devis';
        insert opp;

        Quote quote = new Quote (Name='test',OpportunityId = opp.Id, Status= 'Version préliminaire',Pricebook2Id = pb.Id,CurrencyIsoCode = 'EUR');
        insert quote;

        insert new QuoteLineItem (QuoteId = quote.id, PricebookEntryId = pbe.Id,Quantity = 2,UnitPrice = 10000);

        Coupon__c coupon =  new Coupon__c (Name='COUPON', DomainName__c = 'STUDENT',Fin__c= Date.today().addDays(1) ,Debut__c = Date.today().addDays(-1),discount_EUR__c=50,discount_USD__c=25);
        insert coupon;
    }

    @IsTest
    public static void testTriggerNewAndUpdate(){
         Quote order = [
                 SELECT Pricebook2.Id, Ref_du_coupon__c, AccountId, CurrencyIsoCode, Pricebook2.CurrencyIsoCode
                 FROM Quote
                 LIMIT 1
         ];
         PricebookEntry pe = [
                 SELECT Id, UnitPrice, CurrencyIsoCode, Pricebook2.CurrencyIsoCode, Pricebook2Id
                 FROM PricebookEntry
                 WHERE IsActive = TRUE
                 AND Pricebook2.Id = :order.Pricebook2.Id
                 AND CurrencyIsoCode = :order.CurrencyIsoCode
                 LIMIT 1
         ];
         
         order.Ref_du_coupon__c = null;
         order.Date__c = Date.today();
         update order;
         
         QuoteLineItem orderItemTest = new QuoteLineItem();
         orderItemTest.PricebookEntryId = pe.Id;
         orderItemTest.Quantity = 1;
         orderItemTest.QuoteId = order.Id;
         orderItemTest.UnitPrice = pe.UnitPrice;
         insert orderItemTest;
         
         Account account = [SELECT Id, Discount_global__c FROM Account WHERE Id = :order.AccountId LIMIT 1];
         account.Discount_global__c = 25;
         update account;
         
         QuoteLineItem orderItemTest2 = new QuoteLineItem();
         orderItemTest2.PricebookEntryId = orderItemTest.PricebookEntryId;
         orderItemTest2.Quantity = orderItemTest.Quantity;
         orderItemTest2.QuoteId = orderItemTest.QuoteId;
         orderItemTest2.UnitPrice = orderItemTest.UnitPrice;
         insert orderItemTest2;
         
         Coupon__c coupon = [SELECT Id FROM Coupon__c LIMIT 1];
         
         if(coupon != null){
             order.Ref_du_coupon__c = coupon.Id;
             update order;
             
             QuoteLineItem orderItemTest3 = new QuoteLineItem();
             orderItemTest3.PricebookEntryId = orderItemTest.PricebookEntryId;
             orderItemTest3.Quantity = orderItemTest.Quantity;
             orderItemTest3.QuoteId = orderItemTest.QuoteId;
             orderItemTest3.UnitPrice = orderItemTest.UnitPrice;
             insert orderItemTest3;
         
             delete orderItemTest3;
         }
      }
}