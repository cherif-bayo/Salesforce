@isTest
public class Test_SendEmailInvoice {

	@TestSetup
	public static void setUp() {
		HelperTestData.createContactAndAccountByAccountNameAndContactEmail('test', 'test@test.fr');
		Contact ct = [select AccountId from Contact limit 1];
		HelperTestData.createOrderWithProductWithContact(ct);
	}

	@IsTest
	public static void testMain() {
		Order o = [select Contact_lie__c from Order limit 1];
		Facture__c f = new Facture__c(Commande_Lie__c = o.Id, Date__c = Date.today().addDays(- 3), Envoyee__c = false, PayedWithStripe__c = true);
		insert f;

		SCH001_SendEmailInvoice sc = new SCH001_SendEmailInvoice();
		sc.execute(null);
	}
}