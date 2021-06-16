@IsTest
public class OrderCloneExtensionTest {

	@TestSetup
	public static void setUp() {
		Currencies_Exchange_Rates__c rate = new Currencies_Exchange_Rates__c();
		rate.Day__c = Date.today();
		rate.CurrencyIsoCode = 'USD';
		rate.Rate__c = 1;

		insert rate;

		Pricebook2 pricebook = new Pricebook2();
		pricebook.Name = 'Test';
		insert pricebook;

		Product2 product = new Product2();
		product.Name = 'Test';
		insert product;

		PricebookEntry pes = new PricebookEntry();
		pes.Product2Id = product.Id;
		pes.Pricebook2Id = Test.getStandardPricebookId();
		pes.CurrencyIsoCode = 'USD';
		pes.UnitPrice = 50;
		insert pes;

		PricebookEntry pe = new PricebookEntry();
		pe.Product2Id = product.Id;
		pe.Pricebook2Id = pricebook.Id;
		pe.CurrencyIsoCode = 'USD';
		pe.UnitPrice = 50;
		insert pe;

		Account account = new Account();
		account.Name = 'Test';
		account.BillingCountryCode = 'FR';
		insert account;

		Contact contact = new Contact();
		contact.FirstName = 'Test';
		contact.LastName = 'Test';
		contact.Email = 'test@xlstat.com';
		contact.Langue__c = 'FR';
		contact.AccountId = account.Id;
		insert contact;

		Order order = new Order();
		order.EffectiveDate = Date.today();
		order.AccountId = account.Id;
		order.Status = 'Version préliminaire';
		order.Contact_lie__c = contact.Id;
		order.CurrencyIsoCode = 'USD';
		order.BillingCountryCode = 'FR';
		order.Pricebook2Id = pricebook.Id;
		insert order;

		OrderItem orderItem = new OrderItem();
		orderItem.PricebookEntryId = pe.Id;
		orderItem.OrderId = order.Id;
		orderItem.Quantity = 2;
		orderItem.UnitPrice = 50;
		insert orderItem;

		List<Software__c> softwares = new List<Software__c>{
				new Software__c(AccessType__c='Multiple', Code__c='00', Name='XLSTAT', DevelopmentDone__c=true, ProductId__c='44affc53-2fc9-4942-a8bb-5f87214c8f0a'),
				new Software__c(AccessType__c='Simple', Code__c='01', Name='XLRISK', ProductId__c='abb8ac81-f3a1-402a-a5e5-e90b444aa933')
		};
		insert softwares;

		Flexera_Key__c key = new Flexera_Key__c();
		key.Order__c = order.Id;
		key.Contact__c = contact.Id;
		key.XLSTAT_Solution__c = 'XLSTAT-Base';
		key.Date_limite__c = Date.today();
		key.Name = 'Test';
		key.Quantity__c = 1;
		key.Domaine_utilisateur__c = 'Company';
		key.Type_licence__c = 'Annuelle';
		key.Expiration__c = 'Expiring';
		key.Nb_activations_allowed__c = 2;
		insert key;

	}

	public static testMethod void testCreate() {
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('jsonCryptlexMockLicenceCreation');
		mock.setStatusCode(201);
		mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
		Test.setMock(HttpCalloutMock.class, mock);

		Order order = [SELECT Id FROM Order LIMIT 1];

		Test.setCurrentPage(Page.OrderCloneExtension);
		Test.startTest();
		OrderCloneExtension controller = new OrderCloneExtension(new ApexPages.StandardController(order));
		controller.getRenderRefBonCommande();
		controller.getRenderRefShareIt();
		controller.NewOrder.R_f_Bon_de_commande__c = 'Test';
		controller.CustomClone();
		Test.stopTest();

		System.assertNotEquals(null, controller.NewOrder.Id);

		Flexera_Key__c[] keysNewOrder = [SELECT Id, Date_limite__c FROM Flexera_Key__c WHERE Order__c = :controller.NewOrder.Id];
		System.debug('[OrderCloneExtensionTest] testUpdate :'+keysNewOrder);

		System.assertEquals(1, keysNewOrder.size());
		System.assertEquals(Date.today().addYears(1), keysNewOrder[0].Date_limite__c);
	}

	public static testMethod void testUpdate() {
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('jsonCryptlexMockLicenceCreation');
		mock.setStatusCode(200);
		mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
		Test.setMock(HttpCalloutMock.class, mock);

		Order order = [SELECT Id FROM Order LIMIT 1];
		Flexera_Key__c key = [SELECT Id FROM Flexera_Key__c LIMIT 1];
		key.Expiration__c = 'Permanent';
		update key;

		Test.setCurrentPage(Page.OrderCloneExtension);
		Test.startTest();
		OrderCloneExtension controller = new OrderCloneExtension(new ApexPages.StandardController(order));
		controller.getRenderRefBonCommande();
		controller.getRenderRefShareIt();
		controller.NewOrder.R_f_Bon_de_commande__c = 'Test';
		controller.CustomClone();
		Test.stopTest();

		System.assertNotEquals(null, controller.NewOrder.Id);

		Flexera_Key__c[] keysNewOrder = [SELECT Id, Date_limite__c FROM Flexera_Key__c WHERE Order__c = :controller.NewOrder.Id];

		System.debug('[OrderCloneExtensionTest] testUpdate :'+keysNewOrder);
		System.assertEquals(1, keysNewOrder.size());
		System.assertEquals(Date.today().addYears(1), keysNewOrder[0].Date_limite__c);
	}
}