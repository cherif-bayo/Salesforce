@isTest
public class TestGenerateFraisShareItCorrection{

	@TestSetup
    public static void setup() {
        Account acc = new Account(Name = 'test');
		insert acc;

		Contact ct = new Contact(lastName = 'test', accountId = acc.Id);
		insert ct;

		HelperTestData.createOrderWithProductWithContact (ct);

		Order o = [select Id from Order limit 1];
		o.Status= 'Validée';
		o.Import_Auto__c = true;
		o.Provenance__c = 'Bon de commande';

		update o;
    } 


	@isTest
    public static void testGenerate() {

        FraisShareItCorrectionController controller = new FraisShareItCorrectionController();
        controller.Generate();
		String count = controller.CountOrders;
    } 
}