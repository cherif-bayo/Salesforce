@isTest
public class testDateFactureToOrder{


	@testSetup
	public static void setup() {
		Account acc = new Account (Name='test');
		insert acc;

		Contact ct = new Contact (LastName='test', AccountId = acc.Id);
		insert ct;

		String orderId = HelperTestData.createOrderWithProductWithContact(ct);

		Facture__c f = new Facture__c(Commande_Lie__c = orderId, Date__c = Date.today().addDays(-3));
		insert f;		
	}

	@IsTest
    public static void testMain() {
        DateFactureToOrder testController = new DateFactureToOrder();
        while(testController.CountOrder > 0){
            testController.AddDateFactureToOrder();
        }
    }
}