@IsTest
public class FlexeraGenerateExtensionCampusTest {

	@TestSetup
	public static void setUp() {
		Account account = new Account();
		account.Name = 'Test';
		insert account;

		Contact contact = new Contact();
		contact.AccountId = account.Id;
		contact.Email = 'test@test.com';
		contact.FirstName = 'Test';
		contact.LastName = 'Test';
		insert contact;

		Order order = new Order();
		order.AccountId = account.Id;
		order.Contact_lie__c = contact.Id;
		order.EffectiveDate = Date.today();
		order.Status = 'Version préliminaire';
		order.BillingCountry = 'France';
		insert order;

		Version__c version = new Version__c();
		version.Name = 'Test';
		version.Date__c = Date.today();
		insert version;

		List<Software__c> softwares = new List<Software__c>{
				new Software__c(AccessType__c='Multiple', Code__c='00', Name='XLSTAT', DevelopmentDone__c=true, ProductId__c='44affc53-2fc9-4942-a8bb-5f87214c8f0a'),
				new Software__c(AccessType__c='Simple', Code__c='01', Name='XLRISK', ProductId__c='abb8ac81-f3a1-402a-a5e5-e90b444aa933')
		};
		insert softwares;

		Flexera_Key__c key = new Flexera_Key__c();
		key.Name = 'Test';
		key.Entitlement_Id__c = 'Test';
		key.Contact__c = contact.Id;
		key.Date_limite__c = Date.today().addYears(1);
		key.Version__c = version.Id;
		key.Quantity__c = 1;
		key.Domaine_utilisateur__c = 'Campus';
		key.XLSTAT_Solution__c = 'XLSTAT-Base';
		key.Order__c = order.Id;
		insert key;
	}

	@IsTest
	public static void testMain() {
		Order order = [SELECT Id FROM Order LIMIT 1];

		PageReference pg = Page.FlexeraGenerateExtensionCampus;
		pg.getParameters().put('order_id', order.Id);
		Test.setCurrentPage(pg);

		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('jsonCryptlexMockLicenceCreation');
		mock.setStatusCode(201);
		mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
		Test.setMock(HttpCalloutMock.class, mock);

		Test.startTest();
		FlexeraGenerateExtensionCampus controller = new FlexeraGenerateExtensionCampus();
		controller.WrapperKeys[0].IsSelected = true;
		controller.Generate();
		Test.stopTest();

		Flexera_Key__c resultKey = [SELECT Id FROM Flexera_Key__c WHERE Has_Student_Ext__c = TRUE AND Order__c = :order.Id];
		System.assertNotEquals(resultKey, null);
	}
}