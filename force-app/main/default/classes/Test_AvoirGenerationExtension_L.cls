@isTest
public class Test_AvoirGenerationExtension_L  {

	@TestSetup
	public static void setUp() {
	    Account account = new Account(Name='test',BillingCountry = 'France');		
        insert account;
        
        Contact contact = new Contact (LastName='test', AccountId = account.id, email = 'test@addissoft.com');
        insert contact;
        
        Id orderId = HelperTestData.createOrderWithProductWithContact(contact);	

		Avoir__c avoir = new Avoir__c(Montant__c=50);
		avoir.Commande_lie__c = orderId;
		insert avoir;
	}

	@IsTest
	public static void testFacture() {		

		Avoir__c avoir = [select Id from Avoir__c limit 1];
		Test.setCurrentPage(Page.avoirGeneration_L);

		AvoirGenerationExtension_L controller = new AvoirGenerationExtension_L(new ApexPages.StandardController(avoir));
		controller.Generate();
	}
}