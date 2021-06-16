@IsTest
public class TEST001_OrderProcessing {

	@IsTest
	public static void testEnvoiCommandeXLStat() {
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('jsonCryptlexMockLicenceCreation');
		mock.setStatusCode(201);
		mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
		Test.setMock(HttpCalloutMock.class, mock);

		Account acc = new Account(Name = 'account');
		insert acc;

		Account accDel = new Account(Name = 'accountDelivring');
		insert accDel;

		Contact ctUS = new Contact(LastName = 'Name', AccountId = acc.Id, Email = 'lbeaubier@xlstat.com', Langue__c='US');
		insert ctUS;

		List<Software__c> softwares = new List<Software__c>{
				new Software__c(AccessType__c='Multiple', Code__c='00', Name='XLSTAT', DevelopmentDone__c=true, ProductId__c='44affc53-2fc9-4942-a8bb-5f87214c8f0a'),
				new Software__c(AccessType__c='Simple', Code__c='01', Name='XLRISK', ProductId__c='abb8ac81-f3a1-402a-a5e5-e90b444aa933')
		};
		insert softwares;

		Id orderId = HelperTestData.createOrderWithProductWithContact(ctUS);
		Order o = [SELECT OrderNumber,Account.BillingCountryCode FROM Order WHERE Id = :orderId LIMIT 1];
		o.Status = ParametersForOrders.ORDER_STATUS_ABANDONNE;
		update o;

		Contact ctDel = new Contact(LastName = 'NomDel', AccountId = accDel.Id, Email = 'laurent.beaubier@gmail.com');
		insert ctDel;

		Test.startTest();
		CL001_OrderProcessing.generateLicenceAndSendEmailToCustomerWithKey(o.OrderNumber, 'test', 'test', 'test', 'test');
		Test.stopTest();
	}

	@IsTest
	public static void testEnvoiCommandeXLStatDistrib() {
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('jsonCryptlexMockLicenceCreation');
		mock.setStatusCode(201);
		mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
		Test.setMock(HttpCalloutMock.class, mock);

		Account acc = new Account(Name = 'account');
		insert acc;

		Account accDel = new Account(Name = 'accountDelivring');
		insert accDel;

		Contact ctUS = new Contact(LastName = 'Name', AccountId = acc.Id, Email = 'lbeaubier@xlstat.com', Langue__c='US');
		insert ctUS;

		List<Software__c> softwares = new List<Software__c>{
				new Software__c(AccessType__c='Multiple', Code__c='00', Name='XLSTAT', DevelopmentDone__c=true, ProductId__c='44affc53-2fc9-4942-a8bb-5f87214c8f0a'),
				new Software__c(AccessType__c='Simple', Code__c='01', Name='XLRISK', ProductId__c='abb8ac81-f3a1-402a-a5e5-e90b444aa933')
		};
		insert softwares;

		Id orderId = HelperTestData.createOrderWithProductWithContact(ctUS);
		Order o = [SELECT OrderNumber,Account.BillingCountryCode, Status, Type FROM Order WHERE Id = :orderId LIMIT 1];
		o.Status = ParametersForOrders.ORDER_STATUS_ABANDONNE;
		o.Type = 'Distributeur';
		update o;

		Contact ctDel = new Contact(LastName = 'NomDel', AccountId = accDel.Id, Email = 'laurent.beaubier@gmail.com');
		insert ctDel;

		Test.startTest();
		CL001_OrderProcessing.generateLicenceAndSendEmailToCustomerWithKey(o.OrderNumber, 'test', 'test', 'test', 'test');
		Test.stopTest();
	}

	@IsTest
	public static void testEnvoiCommandeXLStatFR() {
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('jsonCryptlexMockLicenceCreation');
		mock.setStatusCode(201);
		mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
		Test.setMock(HttpCalloutMock.class, mock);

		Account accfr = new Account(Name = 'accountfr');
		insert accfr;

		Account accDel = new Account(Name = 'accountDelivring');
		insert accDel;

		Contact ctFR = new Contact(LastName = 'Nom', AccountId = accfr.Id, Email = 'lbeaubierfr@xlstat.com', Langue__c='FR');
		insert ctFR;

		List<Software__c> softwares = new List<Software__c>{
				new Software__c(AccessType__c='Multiple', Code__c='00', Name='XLSTAT', DevelopmentDone__c=true, ProductId__c='44affc53-2fc9-4942-a8bb-5f87214c8f0a'),
				new Software__c(AccessType__c='Simple', Code__c='01', Name='XLRISK', ProductId__c='abb8ac81-f3a1-402a-a5e5-e90b444aa933')
		};
		insert softwares;

		Id orderId = HelperTestData.createOrderWithProductWithContact(ctFR);
		Order o = [SELECT OrderNumber,Account.BillingCountryCode FROM Order WHERE Id = :orderId LIMIT 1];
		o.Status = ParametersForOrders.ORDER_STATUS_ABANDONNE;
		update o;

		Contact ctDel = new Contact(LastName = 'NomDel', AccountId = accDel.Id, Email = 'laurent.beaubier@gmail.com', Langue__c='FR');
		insert ctDel;

		Test.startTest();
		CL001_OrderProcessing.generateLicenceAndSendEmailToCustomerWithKey(o.OrderNumber, 'test', 'test', 'test', 'test');
		Test.stopTest();
	}



	@IsTest
	public static void testEnvoiCommandeOthers() {

		List<Software__c> softwares = new List<Software__c>{
				new Software__c(AccessType__c='Multiple', Code__c='00', Name='XLSTAT', DevelopmentDone__c=true, ProductId__c='44affc53-2fc9-4942-a8bb-5f87214c8f0a'),
				new Software__c(AccessType__c='Simple', Code__c='01', Name='XLRISK', ProductId__c='abb8ac81-f3a1-402a-a5e5-e90b444aa933')
		};
		insert softwares;

		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('jsonCryptlexMockLicenceCreation');
		mock.setStatusCode(201);
		mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
		Test.setMock(HttpCalloutMock.class, mock);

		Account acc = new Account(Name = 'account');
		insert acc;

		Account accDel = new Account(Name = 'accountDelivring');
		insert accDel;

		Contact ct = new Contact(LastName = 'Nom', AccountId = acc.Id, Email = 'lbeaubier@xlstat.com');
		insert ct;

		Id orderId = HelperTestData.createOrderWithProductWithContactNotXLStat(ct);
		Order o = [SELECT OrderNumber,Account.BillingCountryCode, (SELECT Software__c, SoftwareCode__c, XLSTAT_Solution__c FROM Cles_Flexera__r) FROM Order WHERE Id = :orderId LIMIT 1];
		System.debug('>>>> o = '+o);
		o.Status = ParametersForOrders.ORDER_STATUS_ABANDONNE;
		update o;

		Contact ctDel = new Contact(LastName = 'NomDel', AccountId = accDel.Id, Email = 'laurent.beaubier@gmail.com');
		insert ctDel;

		Test.startTest();
		CL001_OrderProcessing.generateLicenceAndSendEmailToCustomerWithKey(o.OrderNumber, 'test', 'test', 'test', 'test');
		Test.stopTest();
	}

	@IsTest
	public static void testEnvoiCommandeOthersFR() {

		List<Software__c> softwares = new List<Software__c>{
				new Software__c(AccessType__c='Multiple', Code__c='00', Name='XLSTAT', DevelopmentDone__c=true, ProductId__c='44affc53-2fc9-4942-a8bb-5f87214c8f0a'),
				new Software__c(AccessType__c='Simple', Code__c='01', Name='XLRISK', ProductId__c='abb8ac81-f3a1-402a-a5e5-e90b444aa933')
		};
		insert softwares;

		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('jsonCryptlexMockLicenceCreation');
		mock.setStatusCode(201);
		mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
		Test.setMock(HttpCalloutMock.class, mock);

		Account acc = new Account(Name = 'account');
		insert acc;

		Account accDel = new Account(Name = 'accountDelivring');
		insert accDel;

		Contact ct = new Contact(LastName = 'Nom', AccountId = acc.Id, Email = 'lbeaubier@xlstat.com', Langue__c='FR');
		insert ct;

		Id orderId = HelperTestData.createOrderWithProductWithContactNotXLStat(ct);
		Order o = [SELECT OrderNumber,Account.BillingCountryCode FROM Order WHERE Id = :orderId LIMIT 1];
		o.Status = ParametersForOrders.ORDER_STATUS_ABANDONNE;
		update o;

		Contact ctDel = new Contact(LastName = 'NomDel', AccountId = accDel.Id, Email = 'laurent.beaubier@gmail.com', Langue__c='FR');
		insert ctDel;

		Test.startTest();
		CL001_OrderProcessing.generateLicenceAndSendEmailToCustomerWithKey(o.OrderNumber, 'test', 'test', 'test', 'test');
		Test.stopTest();
	}

	@IsTest
	public static void testEnvoiCommandeOthersFRDistrib() {

		List<Software__c> softwares = new List<Software__c>{
				new Software__c(AccessType__c='Multiple', Code__c='00', Name='XLSTAT', DevelopmentDone__c=true, ProductId__c='44affc53-2fc9-4942-a8bb-5f87214c8f0a'),
				new Software__c(AccessType__c='Simple', Code__c='01', Name='XLRISK', ProductId__c='abb8ac81-f3a1-402a-a5e5-e90b444aa933')
		};
		insert softwares;

		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('jsonCryptlexMockLicenceCreation');
		mock.setStatusCode(201);
		mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
		Test.setMock(HttpCalloutMock.class, mock);

		Account acc = new Account(Name = 'account');
		insert acc;

		Account accDel = new Account(Name = 'accountDelivring');
		insert accDel;

		Contact ct = new Contact(LastName = 'Nom', AccountId = acc.Id, Email = 'lbeaubier@xlstat.com', Langue__c='FR');
		insert ct;

		Id orderId = HelperTestData.createOrderWithProductWithContactNotXLStat(ct);
		Order o = [SELECT OrderNumber,Account.BillingCountryCode, Status, Type FROM Order WHERE Id = :orderId LIMIT 1];
		o.Status = ParametersForOrders.ORDER_STATUS_ABANDONNE;
		o.Type = 'Distributeur';
		update o;

		Contact ctDel = new Contact(LastName = 'NomDel', AccountId = accDel.Id, Email = 'laurent.beaubier@gmail.com', Langue__c='FR');
		insert ctDel;

		Test.startTest();
		CL001_OrderProcessing.generateLicenceAndSendEmailToCustomerWithKey(o.OrderNumber, 'test', 'test', 'test', 'test');
		Test.stopTest();
	}
}