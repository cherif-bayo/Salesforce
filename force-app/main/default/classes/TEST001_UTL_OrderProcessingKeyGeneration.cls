@IsTest
public class TEST001_UTL_OrderProcessingKeyGeneration {

	@TestSetup
	public static void setup() {
		List<Software__c> softwares = new List<Software__c>{
				new Software__c(AccessType__c='Multiple', Code__c='00', Name='XLSTAT', DevelopmentDone__c=true, ProductId__c='44affc53-2fc9-4942-a8bb-5f87214c8f0a'),
				new Software__c(AccessType__c='Simple', Code__c='01', Name='XLRISK', ProductId__c='abb8ac81-f3a1-402a-a5e5-e90b444aa933')
		};
		insert softwares;
	}

	@IsTest
	public static void casNominalRenewal() {
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('jsonCryptlexMockLicenceCreation');
		mock.setStatusCode(201);
		mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
		Test.setMock(HttpCalloutMock.class, mock);

		Account acc = new Account(Name = 'account');
		insert acc;

		Account accDel = new Account(Name = 'accountDelivring');
		insert accDel;

		Contact ct = new Contact(LastName = 'Nom', AccountId = acc.Id, Email = 'baymed2007@gmail.com');
		insert ct;

		//Id orderId = HelperTestData.createOrderWithProductWithContact(ct);
		//Too Many query with this method when trying to deploy in production
		
		Pricebook2 pricebook = new Pricebook2();
		pricebook.Name = 'Test';

		insert pricebook;

		Product2 product = new Product2(IsActive = true, Name = 'XLSTAT-Base', ProductCode = 'S_BAS_CMP_AN', Family = 'Solution',
		                                CurrencyIsoCode = 'USD', Domaine_utilisateur__c = 'Campus', Type_licence__c = 'Annuelle');
		insert product;
        
        PricebookEntry pes2 = new PricebookEntry();
		pes2.Product2Id = product.Id;
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
        
        Order order = new Order();
		order.AccountId = acc.Id;
		order.EffectiveDate = Date.today();
		order.Pricebook2Id = pricebook.Id;
		order.CurrencyIsoCode = 'USD';
		order.BillingCountry = 'France';
		order.Status = 'Version préliminaire';
        //order.Provenance__c = 'ShareIt';
		insert order;
         
        OrderItem orderItem = new OrderItem();
		orderItem.PricebookEntryId = pe.Id;
		orderItem.OrderId = order.Id;
		orderItem.Quantity = 1;
		orderItem.UnitPrice = 10;
		insert orderItem;
        
        List<Software__c> softwares = new List<Software__c>{
                new Software__c(AccessType__c='Multiple', Code__c='00', Name='XLSTAT', DevelopmentDone__c=true, ProductId__c='44affc53-2fc9-4942-a8bb-5f87214c8f0a'),
                new Software__c(AccessType__c='Simple', Code__c='01', Name='XLRISK', ProductId__c='abb8ac81-f3a1-402a-a5e5-e90b444aa933')
        };
        insert softwares;
        
		//Order order = [SELECT Ref_ShareIt__c, Id, Account.Type, Domaine_utilisateur__c, Status, Type_licence__c, Contact_lie__r.Email, Client_final__r.Email, AccountId, Contact_lie__c, Client_final__c, MyAccount_Auto__c, CurrencyIsoCode FROM Order WHERE Id = :order.Id];
		order.Ref_ShareIt__c = '55666,699';
		update order;

		Contact ctDel = new Contact(LastName = 'NomDel', AccountId = accDel.Id, Email = 'cbayo@xlstat.com');
		insert ctDel;

		Flexera_Key__c key = new Flexera_Key__c(Order__c = order.Id, Quantity__c = 3, XLSTAT_Solution__c = 'XLSTAT-Premium', XLSTAT_Options__c = 'XLSTAT-3DPlot');
		insert key;

		Test.startTest();
		CL001_UTL_OrderProcessingKeyGeneration.generateKey(order, acc, ct,true);
		Test.stopTest();
	}

	@IsTest
	public static void casNominal() {
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('jsonCryptlexMockLicenceCreation');
		mock.setStatusCode(201);
		mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
		Test.setMock(HttpCalloutMock.class, mock);

		Account acc = new Account(Name = 'account');
		insert acc;

		Account accDel = new Account(Name = 'accountDelivring');
		insert accDel;

		Contact ct = new Contact(LastName = 'Nom', AccountId = acc.Id, Email = 'baymed2007@gmail.com');
		insert ct;

		Id orderId = HelperTestData.createOrderWithProductWithContact(ct);
		Order order = [SELECT Ref_ShareIt__c, Id, Account.Type, Domaine_utilisateur__c, Status, Type_licence__c, Contact_lie__r.Email, Client_final__r.Email, AccountId, Contact_lie__c, Client_final__c, MyAccount_Auto__c, CurrencyIsoCode FROM Order WHERE Id = :orderId];

		Contact ctDel = new Contact(LastName = 'NomDel', AccountId = accDel.Id, Email = 'cbayo@xlstat.com');
		insert ctDel;

		Test.startTest();
		CL001_UTL_OrderProcessingKeyGeneration.generateKey(order, accDel, ctDel,true);
		Test.stopTest();
	}

}