@isTest
global class Test_PardotListeQuoteAbandonne {

	@isTest
	global static void testAbandonnedQuotes() {
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('PardotWebServiceMock');
		mock.setStatusCode(200);
		mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
		Test.setMock(HttpCalloutMock.class, mock);

		SCH001_PardotListeQuoteAbandonne pa = new SCH001_PardotListeQuoteAbandonne();
		pa.execute(null);
	}

	@isTest
	global static void testAbandonnedQuotesKo() {
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('PardotWebServiceMock');
		mock.setStatusCode(200);
		mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
		Test.setMock(HttpCalloutMock.class, mock);

		SCH001_PardotListeQuoteAbandonne pa = new SCH001_PardotListeQuoteAbandonne();
		pa.execute(null);
	}
}