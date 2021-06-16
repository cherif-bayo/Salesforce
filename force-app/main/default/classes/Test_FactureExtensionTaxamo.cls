@isTest
public class Test_FactureExtensionTaxamo  {

	@TestSetup
	public static void setUp() {
		HelperTestData.createContactAndAccountByAccountNameAndContactEmail('test','test@test.fr');

		Contact ct = [select Contact.AccountId from Contact limit 1];
		HelperTestData.createOrderWithProductWithContact(ct);
	}

	@IsTest
	public static void test() {
		Order o = [select Id from order limit 1];
		Facture__c f = new Facture__c();
		f.Commande_lie__c = o.Id;
		insert f;

		Test.setCurrentPage(Page.facture_Taxamo);
		FactureExtensionTaxamo ext = new FactureExtensionTaxamo(new ApexPages.StandardController(f));
	}
}