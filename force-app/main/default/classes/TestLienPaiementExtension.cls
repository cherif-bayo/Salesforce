@isTest
public class TestLienPaiementExtension {

	@TestSetup
	public static void setUp() {
		HelperTestData.createQuoteWithProductWithContact();
	}

	@IsTest
	public static void testGenerate() {

		// Mock de l'appel
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('jsonPaymentLink');
		mock.setStatusCode(201);
		mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
		Test.setMock(HttpCalloutMock.class, mock);
		Test.setCurrentPage(Page.LienPaiement);

		// Recuperation du devis
		Quote quote = [select Id from Quote limit 1];

		// Setup Page
		LienPaiementExtension ext = new LienPaiementExtension(new ApexPages.StandardController(quote));
		ext.montant = 10;
		ext.email = 'test@test.com';

		// Test
		Test.startTest();
		ext.generateLink();
		Test.stopTest();
	}

	@IsTest
	public static void testCancel() {

		// Recuperation du devis
		Quote quote = [select Id from Quote limit 1];

		// Setup Page
		Test.setCurrentPage(Page.LienPaiement);
		LienPaiementExtension ext = new LienPaiementExtension(new ApexPages.StandardController(quote));

		// Test
		Test.startTest();
		ext.cancel();
		Test.stopTest();
	}
}