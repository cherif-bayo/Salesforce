@isTest
private class Test_UpdateKeysXlstatVersionBatchable {

	@testSetup
	private static void testName() {
		Account acc = new Account(Name = 'test', BillingCountry = 'France');
		insert acc;

		Contact ct = new Contact(LastName = 'test', AccountId = acc.Id);
		insert ct;

		insert new Flexera_Key__c(Name = 'test', Contact__c = ct.Id, Date_limite__c = date.today(), Quantity__c = 3, Is_Inactive__c = false);

		insert new Version__c(Date__c = Date.today(), name = '2019.1.1');
	}


	@isTest
	private static void main() {

		Test.StartTest();
		Database.executeBatch(new UpdateKeysXlstatVersionBatchable(), 50);
		Test.StopTest();
	}
}