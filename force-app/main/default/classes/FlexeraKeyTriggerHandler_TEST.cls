@isTest
private class FlexeraKeyTriggerHandler_TEST{

	@testSetup static void setup() {
		Account a = new Account();
		a.Name = 'Test Account' ;
		insert a;

		Contact c = new Contact();
        c.FirstName ='Camille';
        c.LastName  ='Honnet';
        c.AccountId = a.Id;
		insert c;

		Flexera_Key__c flexeraKey01 = new Flexera_Key__c();
        flexeraKey01.Account__c = a.Id;
        flexeraKey01.Contact__c = c.Id;
        flexeraKey01.Date_limite__c = Date.today().addMonths(1);
        flexeraKey01.Quantity__c = 1;
        flexeraKey01.Expiration__c = 'Expiring';
		insert flexeraKey01;

		Flexera_Key__c flexeraKey02 = new Flexera_Key__c();
        flexeraKey02.Account__c = a.Id;
        flexeraKey02.Contact__c = c.Id;
        flexeraKey02.Date_limite__c = Date.today() - 30;
        flexeraKey02.Quantity__c = 2;
        flexeraKey02.Expiration__c = 'Expiring';
		insert flexeraKey02;
	}

	/**
	 * Field Update (ActivatedKey) testing
	 */
	@isTest static void testMethod_ActivatedKey() {
		Contact c = [SELECT Id, ActivatedKey__c FROM Contact WHERE FirstName = 'Camille' LIMIT 1];
		System.assertEquals(c.ActivatedKey__c, false);

		Flexera_Key__c fk = [SELECT Id, Date_limite__c FROM Flexera_Key__c WHERE Contact__c = :c.Id LIMIT 1];
		fk.Date_limite__c = Date.today() - 92;
		update fk;
		System.assertEquals(c.ActivatedKey__c, false);

		fk.Date_limite__c = fk.Date_limite__c.addMonths(6);
		update fk;
		System.assertEquals(c.ActivatedKey__c, false);

		//Test insert Flexera_Key__c
		Flexera_Key__c flexeraKey03 = new Flexera_Key__c();
        flexeraKey03.Contact__c = c.Id;
        flexeraKey03.Date_limite__c = Date.today()+365;
        flexeraKey03.Quantity__c = 2;
        flexeraKey03.Expiration__c = 'Expiring';
		insert flexeraKey03;

	}

	@isTest static void testMethod_ActivatedKeyBatch() {
		Test.startTest();
        FlexeraKeyBatch myBatch = new FlexeraKeyBatch();
        DataBase.executeBatch(myBatch);
		Test.stopTest();
	}
}