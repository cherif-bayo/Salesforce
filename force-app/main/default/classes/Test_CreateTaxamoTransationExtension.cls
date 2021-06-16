@isTest
public class Test_CreateTaxamoTransationExtension {

	@TestSetup
	public static void setUp() {
		Account acc = new Account(Name = 'test');
		insert acc;

		Contact ct = new Contact(lastName = 'test', accountId = acc.Id);
		insert ct;

		HelperTestData.createOrderWithProductWithContact(ct);
	}

	@IsTest
	public static void test() {
		Order order = [select AddinsoftCompany__c from Order limit 1];
		Test.setCurrentPage(Page.Btn_CreateTaxamoTransaction);
		Btn_CreateTaxamoTransationExtension ext = new Btn_CreateTaxamoTransationExtension(new ApexPages.StandardController(order));
	}
}