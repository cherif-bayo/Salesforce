@isTest
public class Test_FactureGenerationExtension_L {

	@TestSetup
	public static void setUp() {
	    Account account = new Account(Name='test');
        insert account;
        
        Contact contact = new Contact (LastName='test', AccountId = account.id, email = 'test@addissoft.com');
        insert contact;
        
        Id orderId = HelperTestData.createOrderWithProductWithContact(contact);	

		Facture__c facture = new Facture__c();
		facture.Commande_lie__c = orderId;
		insert facture;
	}

	@IsTest
	public static void testFacture() {		

		Facture__c facture = [select GenerateFactureEN__c from Facture__c limit 1];
		Test.setCurrentPage(Page.factureGeneration_L);

		FactureGenerationExtension_L controller = new FactureGenerationExtension_L(new ApexPages.StandardController(facture));
		controller.Generate();
	}
}