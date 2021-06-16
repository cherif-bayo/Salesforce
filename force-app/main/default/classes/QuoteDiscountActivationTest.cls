@isTest
public class QuoteDiscountActivationTest{
    public static testMethod void testInsert() {
		Coupon__c coupon =  new Coupon__c (Name='COUPON', DomainName__c = 'STUDENT',Fin__c= Date.today().addDays(1) ,Debut__c = Date.today().addDays(-1),discount_EUR__c=50,discount_USD__c=25);
        insert coupon;

        Account account = new Account();
        account.Name = 'Test';
        account.Discount_global__c = 30;

        insert account;

        Opportunity order = new Opportunity();
        order.CurrencyIsoCode = 'USD';
        order.Discount_manuel__c = 35;
        order.AccountId = account.Id;
        order.Ref_du_coupon__c = coupon.Id;
        order.Name = 'Test';
        order.StageName = 'Test';
        order.CloseDate = Date.today().addDays(1);

        insert order;

        Quote quote = new Quote();
        quote.OpportunityId = order.Id;
        quote.Name = 'Test';
		quote.BillingCountryCode = 'US';
		quote.BillingStateCode = 'CA';
        quote.BillingPostalCode = '33800';

        insert quote;

        Test.startTest();
        Test.stopTest();

        quote = [SELECT JPHasNotDiscount__c, BillingCountry, BillingStateCode, BillingState, BillingCountryCode, GenerateFactureEN__c, Discount_Manuel__c, Discount_coupon__c, Discount_Client__c, Discount_Client_Activated__c, Discount_Coupon_Activated__c, Discount_Manuel_Activated__c FROM Quote WHERE Id = :quote.Id];

        System.assertEquals(25, quote.Discount_coupon__c);
        System.assertEquals(30, quote.Discount_Client__c);
        System.assertEquals(35, quote.Discount_Manuel__c);
        System.assertEquals(true, quote.Discount_Client_Activated__c);
        System.assertEquals(true, quote.Discount_Coupon_Activated__c);
        System.assertEquals(true, quote.Discount_Manuel_Activated__c);
    }

    public static testMethod void testUpdate() {
		Coupon__c coupon =  new Coupon__c (Name='COUPON', DomainName__c = 'STUDENT',Fin__c= Date.today().addDays(1) ,Debut__c = Date.today().addDays(-1),discount_EUR__c=50,discount_USD__c=25);
        insert coupon;

        Account account = new Account();
        account.Name = 'Test';
        account.Discount_global__c = 30;

        insert account;

        Account accountWithoutDiscount = new Account();
        accountWithoutDiscount.Name = 'Test2';

        insert accountWithoutDiscount;

        Opportunity order = new Opportunity();
        order.CurrencyIsoCode = 'USD';
        order.AccountId = accountWithoutDiscount.Id;
        order.Name = 'Test';
        order.StageName = 'Test';
        order.CloseDate = Date.today().addDays(1);

        insert order;

        Quote quote = new Quote();
        quote.OpportunityId = order.Id;
        quote.Name = 'Test';
		quote.BillingCountryCode = 'US';
        quote.BillingStateCode = 'AL';
        quote.BillingPostalCode = '33800';

        insert quote;

        quote = [SELECT JPHasNotDiscount__c, BillingCountry, BillingStateCode, BillingState, BillingCountryCode, GenerateFactureEN__c, Discount_Manuel__c, Discount_coupon__c, Discount_Client__c, Discount_Client_Activated__c, Discount_Coupon_Activated__c, Discount_Manuel_Activated__c FROM Quote WHERE Id = :quote.Id];

        System.assertEquals(0, quote.Discount_coupon__c);
        System.assertEquals(0, quote.Discount_Client__c);
        System.assertEquals(null, quote.Discount_Manuel__c);
        System.assertEquals(false, quote.Discount_Client_Activated__c);
        System.assertEquals(false, quote.Discount_Coupon_Activated__c);
        System.assertEquals(false, quote.Discount_Manuel_Activated__c);

        quote.Discount_manuel__c = 35;
        quote.Ref_du_coupon__c = coupon.Id;
        quote.GenerateFactureEN__c = false;

        Test.startTest();
        update quote;
        Test.stopTest();

        quote = [SELECT JPHasNotDiscount__c, BillingCountry, BillingStateCode, BillingState, BillingCountryCode, GenerateFactureEN__c, Discount_Manuel__c, Discount_coupon__c, Discount_Client__c, Discount_Client_Activated__c, Discount_Coupon_Activated__c, Discount_Manuel_Activated__c FROM Quote WHERE Id = :quote.Id];

        System.assertEquals(25, quote.Discount_coupon__c);
        System.assertEquals(35, quote.Discount_Manuel__c);
        System.assertEquals(true, quote.Discount_Coupon_Activated__c);
        System.assertEquals(true, quote.Discount_Manuel_Activated__c);
    }
}