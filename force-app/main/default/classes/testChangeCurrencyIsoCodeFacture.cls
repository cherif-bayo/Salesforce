@isTest
public class testChangeCurrencyIsoCodeFacture {

	@TestSetup
	public static void setup() {

		Account acc = new Account(Name = 'test');
		insert acc;

		Contact ct = new Contact(lastName = 'test', accountId = acc.Id);
		insert ct;

		String orderId = HelperTestData.createOrderWithProductWithContact(ct);

		Facture__c f = new Facture__c(Commande_Lie__c = orderId);
		insert f;
	}

	@IsTest
	public static void testMain() {
		Facture__c facture = [select Id, CurrencyIsoCode from Facture__c where CurrencyIsoCode = 'EUR' limit 1];

		Test.setCurrentPage(Page.changeFactureCurrencyIsoCodeExtension);

		// call the constructor
		ChangeFactureCurrencyIsoCodeExtension controller = new ChangeFactureCurrencyIsoCodeExtension(new ApexPages.StandardController(facture));
		controller.CurrencyIsoCode = 'USD';
		controller.ChangeCurrency();

		System.assertEquals('USD', controller.facture.CurrencyIsoCode);
		System.assertEquals(false, controller.NotChanged);
	}
}