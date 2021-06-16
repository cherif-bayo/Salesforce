@isTest
public class Test_CryptlexRenewExtension {

	@TestSetup
	public static void setUp() {
		Account account = new Account(Name = 'test');
		insert account;

		Contact contact = new Contact(LastName = 'test', AccountId = account.id, email = 'test@addissoft.com');
		insert contact;

		Flexera_Key__c key = new Flexera_Key__c(contact__c = contact.Id, Name = 'test', Quantity__c = 1, Date_limite__c = Date.today(), Entitlement_Id__c = 'id');
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
		CryptlexRenewExtension ext = new CryptlexRenewExtension(new ApexPages.StandardController(key));

		Test.startTest();
		ext.renew();
		Test.stopTest();
	}
}