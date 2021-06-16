@isTest
public class TEST001_UTL_UpdateExistingKeys {

	@TestSetup
	public static void setup() {
		Account acc = new Account(Name = 'testAccount');
		insert acc;

		Contact ct = new Contact(LastName = 'testName', accountId = acc.Id);
		insert ct;

		String orderId = HelperTestData.createOrderWithProductWithContact(ct);
		Order order = [select Id, Type_licence__c from Order where Id = :orderId limit 1];

		Flexera_Key__c key = new Flexera_Key__c(Name = 'key1', Order__c = orderId, Quantity__c = 3, XLSTAT_Solution__c = 'XLSTAT-Premium', XLSTAT_Options__c = 'XLSTAT-3DPlot');
		insert key;

		Flexera_Key__c key2 = new Flexera_Key__c(Name = 'key2', Order__c = orderId, Quantity__c = 3, XLSTAT_Solution__c = 'XLSTAT-Marketing', XLSTAT_Options__c = 'XLSTAT-LatentClass');
		insert key2;

		Flexera_Key__c key3 = new Flexera_Key__c(Name = 'key3', Order__c = orderId, Quantity__c = 3, XLSTAT_Solution__c = 'XLSTAT-Quality', XLSTAT_Options__c = 'XLSTAT-3DPlot');
		insert key3;
	}

	@IsTest
	public static void casNominal() {
		List<String> keyNames = new List<String> { 'key1', 'key2', 'key3' }; // inserted in setup
		Order order = [select Id, Type_licence__c from Order  limit 1];      // inserted in setup

		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('jsonCryptlexMockLicenceCreation');
		mock.setStatusCode(201);
		mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
		Test.setMock(HttpCalloutMock.class, mock);		

		Test.startTest();
		CL001_UTL_UpdateExistingKeys.updateKeys(keyNames, order);
		Test.stopTest();

	}
}