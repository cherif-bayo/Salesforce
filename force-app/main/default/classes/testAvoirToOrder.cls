@isTest
public class testAvoirToOrder {

	@TestSetup
	public static void setup() {
		Account acc = new Account(Name = 'test');
		insert acc;

		Contact ct = new Contact(lastName = 'test', accountId = acc.Id);
		insert ct;

		HelperTestData.createOrderWithProductWithContact(ct);

		Order o = [select Id from Order limit 1];
		o.Status = 'Payée';
		o.Import_Auto__c = true;
		o.Provenance__c = 'Bon de commande';

		update o;

		Avoir__c avoir = new Avoir__c (Commande_lie__c = o.Id,Montant__c =250);
		insert avoir;
	}

	@isTest
	public static void testMain() {
		AvoirToOrder testController = new AvoirToOrder();
		while (testController.CountOrder > 0) {
			testController.AddAvoirToOrder();
		}
	}

	@isTest
	public static void testTrigger() {
		Order order = [select Id from Order where Status = 'Payée' limit 1];
		Avoir__c avoir = new Avoir__c();
		avoir.Commande_lie__c = order.Id;
		avoir.Montant__c = 100;

		insert avoir;
	}
}