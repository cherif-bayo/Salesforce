@isTest
public class OrderDiscountActivationTest {
	public static testMethod void testInsert() {
		Coupon__c coupon = new Coupon__c(Name = 'COUPON', DomainName__c = 'STUDENT', Fin__c = Date.today().addDays(1), Debut__c = Date.today().addDays(- 1), discount_EUR__c = 50, discount_USD__c = 25);
		insert coupon;

		Account account = new Account();
		account.Name = 'Test';
		account.Discount_global__c = 30;

		insert account;

		Order order = new Order();
		order.Status = 'Version préliminaire';
		order.EffectiveDate = Date.today();
		order.CurrencyIsoCode = 'USD';
		order.Discount_manuel__c = 35;
		order.AccountId = account.Id;
		order.Ref_du_coupon__c = coupon.Id;

		Test.startTest();
		insert order;
		Test.stopTest();

		order = [SELECT Discount_coupon__c, Discount_Client__c, Discount_Client_Activated__c, Discount_Coupon_Activated__c, Discount_Manuel_Activated__c FROM Order WHERE Id = :order.Id];

		System.assertEquals(25, order.Discount_coupon__c);
		System.assertEquals(30, order.Discount_Client__c);
		System.assertEquals(true, order.Discount_Client_Activated__c);
		System.assertEquals(true, order.Discount_Coupon_Activated__c);
		System.assertEquals(true, order.Discount_Manuel_Activated__c);
	}

	public static testMethod void testUpdate() {
		Coupon__c coupon = new Coupon__c(Name = 'COUPON', DomainName__c = 'STUDENT', Fin__c = Date.today().addDays(1), Debut__c = Date.today().addDays(- 1), discount_EUR__c = 50, discount_USD__c = 25);
		insert coupon;

		Account account = new Account();
		account.Name = 'Test';
		account.Discount_global__c = 30;

		insert account;

		Account accountWithoutDiscount = new Account();
		accountWithoutDiscount.Name = 'Test2';

		insert accountWithoutDiscount;

		Order order = new Order();
		order.Status = 'Version préliminaire';
		order.EffectiveDate = Date.today();
		order.CurrencyIsoCode = 'USD';
		order.AccountId = accountWithoutDiscount.Id;

		insert order;

		order = [SELECT Discount_Manuel__c, Discount_coupon__c, Discount_Client__c, Discount_Client_Activated__c, Discount_Coupon_Activated__c, Discount_Manuel_Activated__c FROM Order WHERE Id = :order.Id];

		System.assertEquals(0, order.Discount_coupon__c);
		System.assertEquals(0, order.Discount_Client__c);
		System.assertEquals(null, order.Discount_Manuel__c);
		System.assertEquals(false, order.Discount_Client_Activated__c);
		System.assertEquals(false, order.Discount_Coupon_Activated__c);
		System.assertEquals(false, order.Discount_Manuel_Activated__c);

		order.Discount_manuel__c = 35;
		order.AccountId = account.Id;
		order.Ref_du_coupon__c = coupon.Id;

		Test.startTest();
		update order;
		Test.stopTest();

		order = [SELECT Discount_Manuel__c, Discount_coupon__c, Discount_Client__c, Discount_Client_Activated__c, Discount_Coupon_Activated__c, Discount_Manuel_Activated__c FROM Order WHERE Id = :order.Id];

		System.assertEquals(25, order.Discount_coupon__c);
		System.assertEquals(30, order.Discount_Client__c);
		System.assertEquals(true, order.Discount_Client_Activated__c);
		System.assertEquals(true, order.Discount_Coupon_Activated__c);
		System.assertEquals(true, order.Discount_Manuel_Activated__c);
	}
}