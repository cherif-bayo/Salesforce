@isTest
global class Test_PardotListePanierAbandonne {

	@isTest
	global static void testAbandonnedCarts() {
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('PardotWebServiceMock');
		mock.setStatusCode(200);
		mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
		Test.setMock(HttpCalloutMock.class, mock);

		SCH001_PardotListePanierAbandonne pa = new SCH001_PardotListePanierAbandonne();
		pa.execute(null);
	}

	@isTest
	global static void testAbandonnedCartsKo() {
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('PardotWebServiceMock');
		mock.setStatusCode(200);
		mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
		Test.setMock(HttpCalloutMock.class, mock);

		SCH001_PardotListePanierAbandonne pa = new SCH001_PardotListePanierAbandonne();
		pa.execute(null);
	}
}