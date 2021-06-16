@isTest
public class Test_HelperFacture {

	@IsTest
	public static void mainTest() {
		HelperTestData.createContactAndAccountByAccountNameAndContactEmail('test', 'test@test.fr');
		Contact ct = [Select AccountId from Contact limit 1];
		Id orderId = HelperTestData.createOrderWithProductWithContact(ct);
		Facture__c f = new Facture__c();
		f.Commande_lie__c = orderId;
		insert f;
		Order o = [select Id, Account.BillingCountryCode from Order Where Id = :orderId limit 1];
		HelperFacture.createFactureFromOrder(o);
		HelperFacture.getPDFFactureAttachmentFor(f);
	}
}