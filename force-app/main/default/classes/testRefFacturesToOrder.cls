@isTest
public class testRefFacturesToOrder {

	@TestSetup
	public static void setup() {
		Account acc = new Account(Name = 'test');
		insert acc;

		Contact ct = new Contact(lastName = 'test', accountId = acc.Id);
		insert ct;

		HelperTestData.createOrderWithProductWithContact(ct);

		Order o = [select Id from Order limit 1];
		o.Status = 'Payée';
		update o;
	}

	public static testMethod void testMain() {
		RefFactureToOrder controller = new RefFactureToOrder();
		while (controller.CountOrder > 0) {
			controller.AddRefFacturesToOrders();
		}
	}


	public static testMethod void testTrigger() {
		Order order = [select Id from Order where Status = 'Payée' limit 1];
		Facture__c facture = new Facture__c();
		facture.Commande_lie__c = order.Id;

		insert facture;
	}
}