@isTest
public class Test_FactureDistributeurGenerationExt_L {

	@TestSetup
	public static void setUp() {
		Account account = new Account(Name = 'test');
		insert account;

		Contact contact = new Contact(LastName = 'test', AccountId = account.id, email = 'test@addissoft.com');
		insert contact;

		Id orderId = HelperTestData.createOrderWithProductWithContact(contact);

		Facture_Distributeur__c facture = new Facture_Distributeur__c();
		facture.Compte_lie__c = account.Id;
		insert facture;
	}

	@IsTest
	public static void testFacture() {

		Facture_Distributeur__c facture = [select Id from Facture_Distributeur__c limit 1];
		Test.setCurrentPage(Page.factureDistributeurGeneration_L);

		FactureDistributeurGenerationExtension_L controller = new FactureDistributeurGenerationExtension_L(new ApexPages.StandardController(facture));
		controller.Generate();
	}

}