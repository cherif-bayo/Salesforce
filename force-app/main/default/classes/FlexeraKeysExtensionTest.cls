@IsTest
public class FlexeraKeysExtensionTest {

	@TestSetup
	public static void SetUp() {
		Account acc = new Account(Name = 'test', BillingCountry = 'France');
		insert acc;

		Contact ct = new Contact(LastName = 'test', AccountId = acc.Id);
		insert ct;

		List<Software__c> softwares = new List<Software__c>{
				new Software__c(AccessType__c='Multiple', Code__c='00', Name='XLSTAT', DevelopmentDone__c=true, ProductId__c='44affc53-2fc9-4942-a8bb-5f87214c8f0a'),
				new Software__c(AccessType__c='Simple', Code__c='01', Name='XLRISK', ProductId__c='abb8ac81-f3a1-402a-a5e5-e90b444aa933')
		};
		insert softwares;

		insert new Flexera_Key__c(Name = 'test', Contact__c = ct.Id, Date_limite__c = Date.today(), Quantity__c = 3, Is_Inactive__c = false);
		insert new Order(Name = 'test', AccountId = acc.Id, EffectiveDate = Date.today(), Status = 'Version préliminaire', Contact_lie__c = ct.Id, BillingCountry = 'France');
		insert new Version__c(Name = 'test', Date__c = Date.today());
		insert new Campaign(Name = 'test', CurrencyIsoCode = 'EUR');
	}

	@IsTest
	public static void testCoverture() {
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('jsonCryptlexMockLicenceCreation');
		mock.setStatusCode(201);
		mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
		Test.setMock(HttpCalloutMock.class, mock);

		PageReference pg = Page.FlexeraKeyNewOrEdit;
		Order order = [SELECT Contact_lie__c FROM Order WHERE Name = 'test'];
		pg.getParameters().put('order_id', order.Id);
		Test.setCurrentPage(pg);

		Contact ct = [SELECT Id FROM Contact WHERE LastName = 'test'];

		Flexera_Key__c key = [SELECT Name, Contact__c FROM Flexera_Key__c WHERE Name = 'test'];
		ApexPages.StandardController sc = new ApexPages.StandardController(key);
		FlexeraKeysExtension flexeraKeysExtension = new FlexeraKeysExtension(sc);

		Test.startTest();
		flexeraKeysExtension.TmpOrder = order;
		flexeraKeysExtension.UpdateContacts();
		flexeraKeysExtension.SelectedContactId = ct.Id;
		flexeraKeysExtension.UpdateActivationsAllowed();
		flexeraKeysExtension.AddOrRemoveContact();
		flexeraKeysExtension.GetFlexeraInformationsFromRead();
		Test.stopTest();
	}

	@IsTest
	public static void testKeySaveNoUpdate() {
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('jsonCryptlexMockLicenceCreation');
		mock.setStatusCode(200);
		mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
		Test.setMock(HttpCalloutMock.class, mock);

		PageReference pg = Page.FlexeraKeyNewOrEdit;
		Order order = [SELECT Contact_lie__c FROM Order WHERE Name = 'test'];
		pg.getParameters().put('order_id', order.Id);
		Test.setCurrentPage(pg);

		Contact ct = [SELECT Id FROM Contact WHERE LastName = 'test'];

		ApexPages.StandardController sc = new ApexPages.StandardController(new Flexera_Key__c(Name = 'test', Contact__c = ct.Id));
		FlexeraKeysExtension flexeraKeysExtension = new FlexeraKeysExtension(sc);
		flexeraKeysExtension.Key.XLSTAT_Solution__c = 'XLSTAT-Premium';
		flexeraKeysExtension.Key.Type_licence__c = 'Small Campus';
		flexeraKeysExtension.Key.Date_limite__c = Date.today();
		flexeraKeysExtension.Key.XLSTAT_Options__c = '';

		Test.startTest();
		flexeraKeysExtension.Save();
		Test.stopTest();
	}

	@IsTest
	public static void testKeySaveUpdate() {
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('jsonCryptlexMockLicenceCreation');
		mock.setStatusCode(200);
		mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
		Test.setMock(HttpCalloutMock.class, mock);

		PageReference pg = Page.FlexeraKeyNewOrEdit;
		Order order = [SELECT Contact_lie__c FROM Order WHERE Name = 'test'];
		pg.getParameters().put('order_id', order.Id);
		Test.setCurrentPage(pg);

		Contact ct = [SELECT Id FROM Contact WHERE LastName = 'test'];

		Flexera_Key__c key = [SELECT Id FROM Flexera_Key__c];

		ApexPages.StandardController sc = new ApexPages.StandardController(new Flexera_Key__c(Name = 'test', Contact__c = ct.Id));
		FlexeraKeysExtension flexeraKeysExtension = new FlexeraKeysExtension(sc);
		flexeraKeysExtension.Key.XLSTAT_Solution__c = 'XLSTAT-Premium';
		flexeraKeysExtension.Key.Type_licence__c = 'Small Campus';
		flexeraKeysExtension.Key.Date_limite__c = Date.today();
		flexeraKeysExtension.Key.XLSTAT_Options__c = '';
		flexeraKeysExtension.Key.Id = key.Id;

		Test.startTest();
		flexeraKeysExtension.Save();
		Test.stopTest();
	}

	@IsTest
	public static void testOrderNew() {
		Flexera_Key__c key = [SELECT Id, Name, Campaign__c, Order__c, Contact__c, Date_limite__c, Domaine_utilisateur__c, Expiration__c, Modules__c,
		                      Nb_activations__c, Nb_activations_allowed__c, Quantity__c, Type_client__c, Type_licence__c, XLSTAT_Options__c,
		                      XLSTAT_Solution__c, Version__c, Entitlement_Id__c FROM Flexera_Key__c WHERE Name = 'test'];
		Flexera_Key__c newKey = key.clone(false, true);

		Order order = [SELECT Id FROM Order WHERE Name = 'test'];

		Test.setMock(WebServiceMock.class, new FlexeraWebServiceMockImpl());

		PageReference pg = Page.FlexeraKeyNewOrEdit;
		pg.getParameters().put('order_id', order.Id);
		Test.setCurrentPage(pg);

		ApexPages.StandardController sc = new ApexPages.StandardController(new Flexera_Key__c());
		FlexeraKeysExtension flexeraKeysExtension = new FlexeraKeysExtension(sc);
		flexeraKeysExtension.Key = newKey;

		Test.startTest();
		flexeraKeysExtension.Save();
		Test.stopTest();
	}

	@IsTest
	public static void testOrderNewErrorCountUser() {
		Flexera_Key__c key = [SELECT Id, Name, Campaign__c, Order__c, Contact__c, Date_limite__c, Domaine_utilisateur__c, Expiration__c, Modules__c, Nb_activations__c, Nb_activations_allowed__c, Quantity__c, Type_client__c, Type_licence__c, XLSTAT_Options__c, XLSTAT_Solution__c, Version__c, Entitlement_Id__c FROM Flexera_Key__c WHERE Name = 'test'];

		Flexera_Key__c newKey = key.clone(false, true);

		Order order = [SELECT Id FROM Order WHERE Name = 'test'];

		Test.setMock(WebServiceMock.class, new FlexeraWebServiceMockImpl());

		PageReference pg = Page.FlexeraKeyNewOrEdit;
		pg.getParameters().put('order_id', order.Id);
		Test.setCurrentPage(pg);

		ApexPages.StandardController sc = new ApexPages.StandardController(new Flexera_Key__c());
		FlexeraKeysExtension flexeraKeysExtension = new FlexeraKeysExtension(sc);
		flexeraKeysExtension.Key = newKey;

		flexeraKeysExtension.MainContact.contact.Email = 'test@test.com';

		Test.startTest();
		flexeraKeysExtension.Save();
		Test.stopTest();
	}

	@IsTest
	public static void testCampaignNew() {
		Campaign campaign = [SELECT Id FROM Campaign WHERE Name = 'test'];

		Test.setMock(WebServiceMock.class, new FlexeraWebServiceMockImpl());

		PageReference pg = Page.FlexeraKeyNewOrEdit;
		pg.getParameters().put('campaign_id', campaign.Id);
		Test.setCurrentPage(pg);

		ApexPages.StandardController sc = new ApexPages.StandardController(new Flexera_Key__c());
		FlexeraKeysExtension flexeraKeysExtension = new FlexeraKeysExtension(sc);
	}

	@IsTest
	public static void testKeyRead() {
		Flexera_Key__c key = [SELECT Id FROM Flexera_Key__c WHERE Name = 'test'];

		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('jsonCryptlexMockLicenceCreation');
		mock.setStatusCode(200);
		mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
		Test.setMock(HttpCalloutMock.class, mock);

		PageReference pg = Page.FlexeraKeyRead;
		Test.setCurrentPage(pg);

		ApexPages.StandardController sc = new ApexPages.StandardController(key);
		FlexeraKeysExtension flexeraKeysExtension = new FlexeraKeysExtension(sc);

		Test.startTest();
		flexeraKeysExtension.GetFlexeraInformations();
		Test.stopTest();
	}

	@IsTest
	public static void testKeyReadError() {
		Flexera_Key__c key = [SELECT Id FROM Flexera_Key__c WHERE Name = 'test'];

		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('jsonCryptlexMockLicenceCreation');
		mock.setStatusCode(200);
		mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
		Test.setMock(HttpCalloutMock.class, mock);

		PageReference pg = Page.FlexeraKeyRead;
		Test.setCurrentPage(pg);

		ApexPages.StandardController sc = new ApexPages.StandardController(key);
		FlexeraKeysExtension flexeraKeysExtension = new FlexeraKeysExtension(sc);
		flexeraKeysExtension.Key.Name = 'TestError2';

		Test.startTest();
		flexeraKeysExtension.GetFlexeraInformations();
		Test.stopTest();
	}

	@IsTest
	public static void testKeyUpdate() {
		Flexera_Key__c key = [SELECT Id FROM Flexera_Key__c WHERE Name = 'test'];

		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('jsonCryptlexMockLicenceCreation');
		mock.setStatusCode(200);
		mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
		Test.setMock(HttpCalloutMock.class, mock);

		PageReference pg = Page.FlexeraKeyNewOrEdit;
		Test.setCurrentPage(pg);

		ApexPages.StandardController sc = new ApexPages.StandardController(key);
		FlexeraKeysExtension flexeraKeysExtension = new FlexeraKeysExtension(sc);
		flexeraKeysExtension.Key.XLSTAT_Solution__c = 'XLSTAT-Premium';
		flexeraKeysExtension.Key.Type_licence__c = 'Small Campus';
		flexeraKeysExtension.Key.Date_limite__c = Date.today();
		flexeraKeysExtension.Key.XLSTAT_Options__c = '';

		Test.startTest();
		flexeraKeysExtension.Save();
		Test.stopTest();
	}

	@IsTest
	public static void testKeyUpdateError() {
		Flexera_Key__c key = [SELECT Id FROM Flexera_Key__c WHERE Name = 'test'];

		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('jsonCryptlexMockLicenceCreation');
		mock.setStatusCode(200);
		mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
		Test.setMock(HttpCalloutMock.class, mock);

		PageReference pg = Page.FlexeraKeyNewOrEdit;
		Test.setCurrentPage(pg);

		ApexPages.StandardController sc = new ApexPages.StandardController(key);
		FlexeraKeysExtension flexeraKeysExtension = new FlexeraKeysExtension(sc);
		flexeraKeysExtension.Key.XLSTAT_Solution__c = 'XLSTAT-Premium';
		flexeraKeysExtension.Key.Type_licence__c = 'Small Campus';
		flexeraKeysExtension.Key.Date_limite__c = Date.today();
		flexeraKeysExtension.Key.XLSTAT_Options__c = '';
		flexeraKeysExtension.Key.Entitlement_Id__c = 'TestError';

		Test.startTest();
		flexeraKeysExtension.Save();
		Test.stopTest();
	}

	@IsTest
	public static void testKeyUpdateLimit() {
		Flexera_Key__c key = [SELECT Id FROM Flexera_Key__c WHERE Name = 'test'];

		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('jsonCryptlexMockLicenceCreation');
		mock.setStatusCode(200);
		mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
		Test.setMock(HttpCalloutMock.class, mock);

		PageReference pg = Page.FlexeraKeyRead;
		Test.setCurrentPage(pg);

		ApexPages.StandardController sc = new ApexPages.StandardController(key);
		FlexeraKeysExtension flexeraKeysExtension = new FlexeraKeysExtension(sc);

		Test.startTest();
		flexeraKeysExtension.UpdateKeyLimit();
		Test.stopTest();
	}

	@IsTest
	public static void testDeactivate() {
		Flexera_Key__c key = [SELECT Id FROM Flexera_Key__c WHERE Name = 'test'];

		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('jsonCryptlexMockLicenceCreation');
		mock.setStatusCode(200);
		mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
		Test.setMock(HttpCalloutMock.class, mock);

		PageReference pg = Page.FlexeraKeyRead;
		Test.setCurrentPage(pg);

		ApexPages.StandardController sc = new ApexPages.StandardController(key);
		FlexeraKeysExtension flexeraKeysExtension = new FlexeraKeysExtension(sc);

		Test.startTest();
		flexeraKeysExtension.Deactivate();
		Test.stopTest();
	}

	@IsTest
	public static void testKeyWithoutVersion() {
		Flexera_Key__c key = new Flexera_Key__c();
		key.Date_limite__c = Date.today();
		key.Contact__c = [SELECT Id FROM Contact LIMIT 1].Id;
		key.Entitlement_Id__c = 'Test';
		key.Quantity__c = 1;

		insert key;
	}

	@IsTest
	public static void testUpdateSolution() {

		Account acc = [SELECT Id FROM Account WHERE Name = 'test'];
		Contact ct = [SELECT Id FROM Contact WHERE LastName = 'test'];

		Currencies_Exchange_Rates__c rate = new Currencies_Exchange_Rates__c();
		rate.Day__c = Date.today();
		rate.CurrencyIsoCode = 'USD';
		rate.Rate__c = 1;

		insert rate;

		Pricebook2 pricebook = new Pricebook2();
		pricebook.Name = 'Test';

		insert pricebook;

		Product2 product = new Product2(IsActive = true, Name = 'XLSTAT-Base', ProductCode = 'S_BAS_CMP_AN', Family = 'Solution',
		                                CurrencyIsoCode = 'USD', Domaine_utilisateur__c = 'Campus', Type_licence__c = 'Annuelle');

		insert product;


		Product2 p3 = new Product2(IsActive = true, Name = '3DPLOT', ProductCode = 'M_3DPLOT_CMP_AN', Family = 'Module',
		                           CurrencyIsoCode = 'USD', Domaine_utilisateur__c = 'Campus', Type_licence__c = 'Annuelle');
		insert p3;

		PricebookEntry pes = new PricebookEntry();
		pes.Product2Id = product.Id;
		pes.Pricebook2Id = Test.getStandardPricebookId();
		pes.UnitPrice = 10;
		pes.CurrencyIsoCode = 'USD';
		insert pes;

		PricebookEntry pes2 = new PricebookEntry();
		pes2.Product2Id = p3.Id;
		pes2.Pricebook2Id = Test.getStandardPricebookId();
		pes2.UnitPrice = 10;
		pes2.CurrencyIsoCode = 'USD';
		insert pes2;

		PricebookEntry pe = new PricebookEntry();
		pe.Product2Id = product.Id;
		pe.Pricebook2Id = pricebook.Id;
		pe.UnitPrice = 10;
		pe.CurrencyIsoCode = 'USD';
		insert pe;

		PricebookEntry pe2 = new PricebookEntry();
		pe2.Product2Id = p3.Id;
		pe2.Pricebook2Id = pricebook.Id;
		pe2.CurrencyIsoCode = 'USD';
		pe2.UnitPrice = 10;
		insert pe2;

		Order order = new Order();
		order.AccountId = acc.Id;
		order.EffectiveDate = Date.today();
		order.Pricebook2Id = pricebook.Id;
		order.CurrencyIsoCode = 'USD';
		order.BillingCountry = 'France';
		order.Status = 'Version préliminaire';
		insert order;

		OrderItem orderItem = new OrderItem();
		orderItem.PricebookEntryId = pe.Id;
		orderItem.OrderId = order.Id;
		orderItem.Quantity = 1;
		orderItem.UnitPrice = 10;
		insert orderItem;

		OrderItem orderItem2 = new OrderItem();
		orderItem2.PricebookEntryId = pe.Id;
		orderItem2.OrderId = order.Id;
		orderItem2.Quantity = 1;
		orderItem2.UnitPrice = 10;
		insert orderItem2;

		Flexera_Key__c key = [SELECT Id, Name, Campaign__c, Order__c, Contact__c, Date_limite__c, Domaine_utilisateur__c, Expiration__c, Modules__c,
		                      Nb_activations__c, Nb_activations_allowed__c, Quantity__c, Type_client__c, Type_licence__c, XLSTAT_Options__c,
		                      XLSTAT_Solution__c, Version__c, Entitlement_Id__c FROM Flexera_Key__c WHERE Name = 'test'];
		Flexera_Key__c newKey = key.clone(false, true);

		Test.setMock(WebServiceMock.class, new FlexeraWebServiceMockImpl());

		PageReference pg = Page.FlexeraKeyNewOrEdit;
		pg.getParameters().put('order_id', order.Id);
		Test.setCurrentPage(pg);

		ApexPages.StandardController sc = new ApexPages.StandardController(new Flexera_Key__c());
		FlexeraKeysExtension flexeraKeysExtension = new FlexeraKeysExtension(sc);
		flexeraKeysExtension.Key = newKey;
		flexeraKeysExtension.UpdateSolutions();
	}

}