@isTest
public class Test_UtilsCQP  {
	
	@TestSetup
	public static void setup() {
		HelperTestData.createPriceBookForCurrency('USD');
	}

	@IsTest
	public static void casNominal() {

		Test.startTest();
		UtilsCQP.getStdPricebookId();
		UtilsCQP.getStdPriceBook();
		Test.stopTest();
	}
}