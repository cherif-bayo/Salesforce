@isTest
public class TestOrderPaymentExtension {

	@TestSetup
	public static void setUp() {
        
        Account acc = new Account(Name = 'account');
        insert acc;
    
        Account accDel = new Account(Name = 'accountDelivring');
        insert accDel;
    
        Contact ct = new Contact(LastName = 'Name', AccountId = acc.Id, Email = 'cbayo@xlstat.com', Langue__c='FR');
        insert ct;
        HelperTestData.createOrderWithProductWithContact(ct);
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
		Order order = [select Id from Order limit 1];

		// Setup Page
		OrderPaymentLinkExtension ext = new OrderPaymentLinkExtension(new ApexPages.StandardController(order));
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
		Order order = [select Id from Order limit 1];

		// Setup Page
		Test.setCurrentPage(Page.LienPaiement);
		OrderPaymentLinkExtension ext = new OrderPaymentLinkExtension(new ApexPages.StandardController(order));

		// Test
		Test.startTest();
		ext.cancel();
		Test.stopTest();
	}
}