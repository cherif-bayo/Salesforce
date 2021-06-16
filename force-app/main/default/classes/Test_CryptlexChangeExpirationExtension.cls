@isTest
public class Test_CryptlexChangeExpirationExtension {

	@TestSetup
	public static void setUp() {
		Flexera_Key__c key = new Flexera_Key__c(Name = 'test', Quantity__c = 1, Date_limite__c = Date.today(),Entitlement_Id__c='id');
		insert key;
	}

	@IsTest
	public static void testSave() {
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('jsonCryptlexMockLicenceCreation');
		mock.setStatusCode(200);
		mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
		Test.setMock(HttpCalloutMock.class, mock);

		Flexera_Key__c key = [select Quantity__c From Flexera_Key__c limit 1];	

		Test.setCurrentPage(Page.CryptlexChangeExpirationPage);
		CryptlexChangeExpirationExtension ext = new CryptlexChangeExpirationExtension(new ApexPages.StandardController(key));

		Test.startTest();
		ext.save();
		Test.stopTest();
	}
}