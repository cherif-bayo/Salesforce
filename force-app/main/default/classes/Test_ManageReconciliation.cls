@isTest
private class Test_ManageReconciliation {

	@isTest
	private static void testReconciliation() {
		stripe_payouts__c p = new stripe_payouts__c();
		insert p;

		StripeReconciliation__c c = new StripeReconciliation__c();
		c.reporting_category__c = 'charge';
		c.charge_Id__c = 'zzz';
		c.Stripe_Payouts__c = p.id;
		insert c;
		
		Account newPersonAccount = new Account();
		newPersonAccount.FirstName = 'Fred';
		newPersonAccount.LastName = 'Smith';
		insert newPersonAccount;

		HelperTestData.createOrderWithProductWithPersonalAccount(newPersonAccount);
		Order o = [select Id from Order limit 1];
		o.chargeToken__c = 'zzz';
		update o;

		Test.startTest();
		ManageReconciliation.completeWithQuotesAndOrders(p);
		Test.stopTest();
	}
}