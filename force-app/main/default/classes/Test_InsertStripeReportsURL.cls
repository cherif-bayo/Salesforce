@isTest
private class Test_InsertStripeReportsURL {

	@TestSetup
	private static void setup() {
		stripe_payouts__c p = new stripe_payouts__c(report_run__c = 'test');
		insert p;
	}


	@isTest
	private static void testName() {
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('jsonTaxamoMock');
		mock.setStatusCode(200);
		mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
		Test.setMock(HttpCalloutMock.class, mock);

		InsertStripeReportsURLSchedulable sch = new InsertStripeReportsURLSchedulable();
		sch.execute(null);
	}
}