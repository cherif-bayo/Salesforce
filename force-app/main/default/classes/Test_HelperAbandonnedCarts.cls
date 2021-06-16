@isTest
private class Test_HelperAbandonnedCarts {

	@TestSetup
	private static void setUp() {
		Account personnalAccount = new Account(firstName = 'test', lastName = 'test');
		insert personnalAccount;

		HelperTestData.createOrderWithProductWithPersonalAccount(personnalAccount);

		Order o = [select Id from Order limit 1];
		o.status = 'Stripe - Non Payée';
		o.effectiveDate = Date.today().addDays(- 3);
		o.PanierAbandonneRelance__c = false;
		update o;

		System.debug('[Test_HelperAbandonnedCarts] order :' + o);
	}

	@isTest
	private static void testName() {
		HelperAbandonnedCarts helper = new HelperAbandonnedCarts();

		helper.getProspects();

		helper.markAbonnedCartsAsCovered();
	}
}