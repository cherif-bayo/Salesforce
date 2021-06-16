@IsTest
public class Test_WS01Products  {

	@TestSetup
	public static void setUp() {
	}

	@IsTest
	public static void testMain() {
		HelperTestData.createStandardPriceBook();
		WS001_Products.getAllMyCommerceFormat();
	}

}