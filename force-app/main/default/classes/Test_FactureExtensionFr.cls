@isTest
public class Test_FactureExtensionFr  {

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
		Facture__c facture = [select TVA__c,Numero_de_TVA__c,BillingCountry__c,Commande_lie__r.HasDiscount__c,Commande_lie__r.CurrencyIsoCode from Facture__c limit 1];
		Test.setCurrentPage(Page.facture_fr);

		FactureExtensionFr ext = new FactureExtensionFr(new ApexPages.StandardController(facture));
	}
}