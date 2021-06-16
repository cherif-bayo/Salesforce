@isTest
public class Test_WSProducts {

	@TestSetup
	public static void setUp() {
	}

	@IsTest
	public static void testMain() {
		HelperTestData.createStandardPriceBook();
		WS002_Products.getAllMyCommerceFormat();
	}

}