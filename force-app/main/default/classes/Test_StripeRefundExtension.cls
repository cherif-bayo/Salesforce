@IsTest
public class Test_StripeRefundExtension {

	@TestSetup
	public static void setUp() {
		Account paccount = new Account(FirstName = 'test', LastName = 'test', PersonEmail = 'test@addissoft.com');
		insert paccount;

		HelperTestData.createOrderWithProductWithPersonalAccount(paccount);

		Order o = [select Id from Order limit 1];
		o.PaymentToken__c = 'test';
		update o;
	}

	@IsTest
	public static void testRefund() {
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStatusCode(200);
		mock.setStaticResource('jsonStripeWebHook'); // La réponse du WS n'a pas d'importance
		mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
		Test.setMock(HttpCalloutMock.class, mock);

		Order order = [select Id From Order limit 1];
		Test.setCurrentPage(Page.Btn_Striperefund);
		Btn_StripeRefundExtension ext = new Btn_StripeRefundExtension(new ApexPages.StandardController(order));

		Test.startTest();
		ext.refund();
		Test.stopTest();
	}

}