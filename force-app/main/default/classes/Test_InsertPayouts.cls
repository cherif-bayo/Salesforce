@isTest 
private class Test_InsertPayouts {

	@isTest
	private static void testName() {
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('jsonStripePayout');
		mock.setStatusCode(200);
		mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
		Test.setMock(HttpCalloutMock.class, mock);

		InsertPayoutsSchedulableClass insertPayout = new InsertPayoutsSchedulableClass();
		insertPayout.execute(null);
	}
}