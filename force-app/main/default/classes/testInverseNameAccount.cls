@isTest
public class testInverseNameAccount {

	@TestSetup
	public static void setup() {
		Account acc = new Account(FirstName = 'test', LastName = 'test', Import_Auto__c = true);
		insert acc;

		HelperTestData.createOrderWithProductWithPersonalAccount(acc);
	}

	@IsTest
	public static void testInverse() {
		InverseNameAccountController controller = new InverseNameAccountController();
		controller.Inverse();

		String count = controller.CountOrders;
	}
}