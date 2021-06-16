@isTest
private class Test_HelperCustomer {
	
	@TestSetup
	private static void setUp() {}

	@isTest
	private static void test_checkPayedOrderFromAbandonnedCarts() {
        Account personnalAccount = new Account (firstName='test', lastName='test');
		insert personnalAccount;
        HelperTestData.createOrderWithProductWithPersonalAccount(personnalAccount);
		List<Order> abandonnedCarts = new List<Order> ();
		Order o = [select Contact_Id__c,EffectiveDate from Order limit 1];
		abandonnedCarts.add(o);

		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('PardotWebServiceMock');
		mock.setStatusCode(200);
		mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
		Test.setMock(HttpCalloutMock.class, mock);

		HelperCustomer.checkPayedOrderFromAbandonnedCarts(abandonnedCarts);
	}
    
    @isTest
	private static void test_checkNonPayedQuotesFromAbandonnedQuotes() {
        HelperTestData.createQuoteWithProductWithContact();
		List<Quote> abandonnedQuotes = new List<Quote> ();
		Quote q = [select ContactId,createdDate from Quote limit 1];
		abandonnedQuotes.add(q);

		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('PardotWebServiceMock');
		mock.setStatusCode(200);
		mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
		Test.setMock(HttpCalloutMock.class, mock);

		HelperCustomer.checkNonPayedQuotes(abandonnedQuotes);
	}
}