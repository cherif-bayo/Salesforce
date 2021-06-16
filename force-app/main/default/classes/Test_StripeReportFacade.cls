@isTest 
private class Test_StripeReportFacade {

	@IsTest
	public static void testGenerateReportPayout() {
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStatusCode(200);
		mock.setStaticResource('jsonStripeWebHook'); // La réponse du WS n'a pas d'importance
		mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
		Test.setMock(HttpCalloutMock.class, mock);

		Test.startTest();
		StripeReportFacade.generateReportPayout(null);
		Test.stopTest();
	}

	@IsTest
	public static void testGetPayoutSince() {
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStatusCode(200);		
		mock.setStaticResource('jsonStripePayout'); // La réponse du WS n'a pas d'importance
		mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
		Test.setMock(HttpCalloutMock.class, mock);

		Test.startTest();
		StripeReportFacade.getPayoutSince(Date.today());
		Test.stopTest();
	}

	@IsTest
	public static void testManageReportPayout() {
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStatusCode(200);		
		mock.setStaticResource('jsonStripePayout'); // La réponse du WS n'a pas d'importance
		mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
		Test.setMock(HttpCalloutMock.class, mock);

		Test.startTest();
		StripeReportFacade.manageReportPayout('zz');
		Test.stopTest();
	}

	@IsTest
	public static void testGetReport() {
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStatusCode(200);		
		mock.setStaticResource('jsonStripePayout'); // La réponse du WS n'a pas d'importance
		mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
		Test.setMock(HttpCalloutMock.class, mock);

		Test.startTest();
		StripeReportFacade.getReport('zz');
		Test.stopTest();
	}

}