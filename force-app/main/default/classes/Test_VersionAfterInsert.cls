@isTest 
private class Test_VersionAfterInsert {

	@isTest
	private static void testName() {
		insert new Version__c(Date__c = Date.today(), name ='2019.1.1');
	}
}