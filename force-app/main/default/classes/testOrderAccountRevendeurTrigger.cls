@isTest
public class testOrderAccountRevendeurTrigger {

	@TestSetup
	public static void setup() {
		Account acc = new Account(Name = 'test');
		insert acc;

		Contact ct = new Contact(lastName = 'test', accountId = acc.Id);
		insert ct;

		HelperTestData.createOrderWithProductWithContact(ct);
		
		Order o = [select Id from Order limit 1];
		o.Provenance__c = 'Cengage';
	}


	@isTest
	public static void testTrigger() {
		Order order = [select Provenance__c from Order limit 1];
		order.Provenance__c = 'Bon de commande';
		update order;
	}
}