@isTest
public class TestAvoirExtension  {
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
	public static void testGenerationQuoteEn() {
		Avoir__c avoir = [select Id from Avoir__c limit 1];
		Test.setCurrentPage(Page.Avoir_en);
		AvoirExtension ext = new AvoirExtension(new ApexPages.StandardController(avoir));
	}
}