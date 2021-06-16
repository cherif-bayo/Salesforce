/**
 * isTEST
 * WEB SERVICE USER TESTS 
 */
@IsTest
public class WebserviceUserTests {

	/**
	 * Method for initialize data
	 */
	@TestSetup static void setup() {

		HelperTestData.createExchangeRate();

		/* ACCOUNT */
		Account account = new Account();
		account.Name = 'Addinsoft';
		account.Type = 'Test';
		insert account;

		Account accountDistributeur = new Account();
		accountDistributeur.Name = 'Addinsoft';
		accountDistributeur.Type = 'Distributeur';
		accountDistributeur.BillingStreet = 'Test';
		accountDistributeur.BillingCountryCode = 'FR';
		accountDistributeur.BillingCity = 'Test';
		accountDistributeur.BillingPostalCode = '00000';
		accountDistributeur.Num_ro_de_TVA__c = '000000';
		account.BillingCountry = 'France';
		insert accountDistributeur;

		/* CONTACT */
		Contact contact = new Contact();
		contact.FirstName = 'Martin';
		contact.LastName = 'Lezer';
		contact.Email = Label.emailAdmin;
		contact.AccountId = account.Id;
		insert contact;

		Contact contactDistributeur = new Contact();
		contactDistributeur.FirstName = 'Simon';
		contactDistributeur.LastName = 'Gazin';
		contactDistributeur.Email = 'sgazin@xlstat.com';
		contactDistributeur.AccountId = accountDistributeur.Id;
		contactDistributeur.Phone = '000000';
		insert contactDistributeur;

		Contact contactWrongName = new Contact();
		contactWrongName.FirstName = '456';
		contactWrongName.LastName = 'Simon';
		contactWrongName.Email = '123@x123.com';
		contactWrongName.AccountId = accountDistributeur.Id;
		contactWrongName.Phone = '000000';
		insert contactWrongName;

		/* LEAD */
		Lead lead = new Lead();
		lead.FirstName = 'Martin';
		lead.LastName = 'Lezer';
		lead.Email = Label.emailAdmin;
		insert lead;

		/* VERSION */
		Version__c version = new Version__c();
		version.Name = 'TestVersion';
		version.Date__c = Date.today().addDays(- 1);
		insert version;

		/* CAMPAIGN */
		Campaign campaign = new Campaign(Name = 'testCampaign',CurrencyIsoCode = 'EUR');
		insert campaign;

		/* ORDER */
		Order order = new Order();
		order.EffectiveDate = Date.today();
		order.Domaine_utilisateur__c = 'Company';
		order.AccountId = account.Id;
		order.Status = 'Version préliminaire';
		order.Type_licence__c = 'Annuelle';
		order.BillingCountry = 'France';
		insert order;

		Order order2 = order.clone();
		order2.Type_licence__c = 'Perpétuelle';
		order2.BillingCountry = 'France';
		insert order2;

		Order order3 = order2.clone();
		order3.Domaine_utilisateur__c = 'Academic';
		order3.BillingCountry = 'France';
		insert order3;

		Order orderDistributeur = new Order();
		orderDistributeur.EffectiveDate = Date.today();
		orderDistributeur.Domaine_utilisateur__c = 'Company';
		orderDistributeur.AccountId = accountDistributeur.Id;
		orderDistributeur.Status = 'Version préliminaire';
		orderDistributeur.Type_licence__c = 'Annuelle';
		orderDistributeur.Client_final__c = contactDistributeur.Id;
		orderDistributeur.BillingCountry = 'France';
		insert orderDistributeur;

		Order orderWrong = new Order();
		orderWrong.EffectiveDate = Date.today();
		orderWrong.Domaine_utilisateur__c = 'Company';
		orderWrong.AccountId = accountDistributeur.Id;
		orderWrong.Status = 'Version préliminaire';
		orderWrong.Type_licence__c = 'Annuelle';
		orderWrong.Client_final__c = contactWrongName.Id;
		orderWrong.BillingCountry = 'France';

		/* SOFTWARE__C */
		List<Software__c> softwares = new List<Software__c>{
				new Software__c(AccessType__c='Multiple', Code__c='00', Name='XLSTAT', DevelopmentDone__c=true, ProductId__c='44affc53-2fc9-4942-a8bb-5f87214c8f0a'),
				new Software__c(AccessType__c='Simple', Code__c='01', Name='XLRISK', ProductId__c='abb8ac81-f3a1-402a-a5e5-e90b444aa933')
		};
		insert softwares;

		/* FELEXERA_KEY__C */
		Flexera_Key__c key = new Flexera_Key__c();
		key.Name = 'e37a-075a-2bac-43e7-893d-9c03-0fce-1faf';
		key.Entitlement_Id__c = 'e37a-075a';
		key.XLSTAT_Solution__c = 'XLSTAT-Premium';
		key.Date_limite__c = Date.today();
		key.Contact__c = contact.Id;
		key.Type_licence__c = 'Annuelle';
		key.Domaine_utilisateur__c = 'Company';
		key.Order__c = order.Id;
		key.Campaign__c = campaign.Id;
		key.Quantity__c = 1;
		key.Is_Inactive__c = false;
		insert key;

		Flexera_Key__c key2 = key.clone();
		key2.Name = '1234567890';
		key.Entitlement_Id__c = '123';
		insert key2;

		Flexera_Key__c key3 = key2.clone();
		key3.Type_licence__c = 'Perpétuelle';
		key3.Order__c = order2.Id;
		key3.Name = '2345678901';
		key.Entitlement_Id__c = '234a';
		insert key3;

		Flexera_Key__c key4 = key3.clone();
		key4.Order__c = order3.Id;
		key4.Domaine_utilisateur__c = 'Academic';
		key4.Name = '3456789012';
		key.Entitlement_Id__c = '345';
		insert key4;

		Flexera_Key__c keyDistributeur = new Flexera_Key__c();
		keyDistributeur.Name = 'Test-Activation-Id';
		keyDistributeur.XLSTAT_Solution__c = 'XLSTAT-Premium';
		keyDistributeur.Date_limite__c = Date.today();
		keyDistributeur.Contact__c = contactDistributeur.Id;
		keyDistributeur.Type_licence__c = 'Annuelle';
		keyDistributeur.Domaine_utilisateur__c = 'Company';
		keyDistributeur.Order__c = orderDistributeur.Id;
		keyDistributeur.Quantity__c = 1;
		insert keyDistributeur;

		Flexera_Key__c keyWrong = new Flexera_Key__c();
		keyWrong.Name = 'Test2-Activation-Id';
		keyWrong.XLSTAT_Solution__c = 'XLSTAT-Premium';
		keyWrong.Date_limite__c = Date.today();
		keyWrong.Contact__c = contactWrongName.Id;
		keyWrong.Type_licence__c = 'Annuelle';
		keyWrong.Domaine_utilisateur__c = 'Company';
		keyWrong.Order__c = orderWrong.Id;
		keyWrong.Quantity__c = 1;
		insert keyWrong;
	}

	/**
	 * Test method for Unsubscribe function
	 */
	@IsTest
	static void UnsubscribeTEST() {
		Test.startTest();
		WebServiceUser.Unsubscribe('martinlezer@xlstat.com');
		WebServiceUser.Unsubscribe(Label.emailAdmin);
		Test.stopTest();

		//System.AssertEquals(database.countquery('SELECT COUNT() FROM Contact WHERE No_mailling__c = true'), 1);
		//System.AssertEquals(database.countquery('SELECT COUNT() FROM Lead WHERE No_mailling__c = true'), 2);
	}

	/**
	 * Test method for CanCreateAccount function
	 */
	@IsTest
	static void MyAccountClientCanCreateTEST() {
		Contact c = [SELECT Id, Email, Code_MyAccount__c FROM Contact WHERE FirstName = 'Martin' LIMIT 1];

		Test.startTest();
		WebServiceUser.ResultMyAccount resultGood = WebServiceUser.CanCreateAccount(c.Email, c.Code_MyAccount__c);

		c.Acces_MyAccount__c = false;
		update c;
		WebServiceUser.ResultMyAccount resultFalseAccessDenied = WebServiceUser.CanCreateAccount(c.Email, c.Code_MyAccount__c);

		c.Compte_MyAccount_cree__c = true;
		update c;
		WebServiceUser.ResultMyAccount resultFalseAccountCreated = WebServiceUser.CanCreateAccount(c.Email, c.Code_MyAccount__c);

		WebServiceUser.ResultMyAccount resultFalseNoClient = WebServiceUser.CanCreateAccount('test@test.com', '0');

		Test.stopTest();

		System.assertEquals('Client can create account.', resultGood.message);
		System.assertEquals('Client found but not allowed to create an account.', resultFalseAccessDenied.message);
		System.assertEquals('Client has already created his account.', resultFalseAccountCreated.message);
		System.assertEquals('Client with email: test@test.com and code: 0 was not found.', resultFalseNoClient.message);
	}


	/**
	 * Test method for CanAuthenticate function
	 */
	@IsTest
	static void MyAccountClientCanConnectTEST() {
		Contact c = [SELECT Id, Email, Code_MyAccount__c, Website_Id__c, FirstName, LastName FROM Contact WHERE FirstName = 'Martin' LIMIT 1];

		Test.startTest();
		WebServiceUser.ResultMyAccount resultFalseAccountNotCreated = WebServiceUser.CanAuthenticate(c.Email);

		c.Compte_MyAccount_cree__c = true;
		update c;
		WebServiceUser.ResultMyAccount resultGoodAccountCreated = WebServiceUser.CanAuthenticate(c.Email);

		c.Acces_MyAccount__c = false;
		update c;
		WebServiceUser.ResultMyAccount resultFalseAccessDenied = WebServiceUser.CanAuthenticate(c.Email);

		WebServiceUser.ResultMyAccount resultFalseNoClient = WebServiceUser.CanAuthenticate('test@test.com');
		Test.stopTest();

		System.assertEquals(false, resultFalseAccountNotCreated.status);
		System.assertEquals(false, resultFalseAccessDenied.status);
		System.assertEquals(true, resultGoodAccountCreated.status);
		System.assertEquals(c.Website_Id__c, resultGoodAccountCreated.myAccount.id);
		System.assertEquals(c.FirstName, resultGoodAccountCreated.myAccount.firstName);
		System.assertEquals(c.LastName, resultGoodAccountCreated.myAccount.lastName);
		System.assertEquals(true, resultGoodAccountCreated.status);
		System.assertEquals(false, resultFalseNoClient.status);
	}

	/**
	 * Test method for Create function
	 */
	@IsTest
	static void MyAccountCreationOkTEST() {
		Contact c = [SELECT Id, Email, Code_MyAccount__c, Compte_MyAccount_cree__c, Date_creation_compte_MyAccount__c FROM Contact WHERE FirstName = 'Martin' LIMIT 1];

		Test.startTest();
		WebServiceUser.Result resultGood = WebServiceUser.Create(c.Email, c.Code_MyAccount__c);
		c.Compte_MyAccount_cree__c = true;
		c.Date_creation_compte_MyAccount__c = Datetime.now();
		update c;

		WebServiceUser.Result resultFalseAlreadyCreated = WebServiceUser.Create(c.Email, c.Code_MyAccount__c);
		Test.stopTest();

		System.assertEquals(true, resultGood.status);
		System.assertNotEquals(null, c.Date_creation_compte_MyAccount__c);
		System.assertEquals(true, c.Compte_MyAccount_cree__c);
		System.assertEquals(false, resultFalseAlreadyCreated.status);
	}

	/**
	 * Test method for CreateForTest function
	 */
	@IsTest
	static void CreateForTestTEST() {
		String email = 'martinlezer@gmail.com';

		Test.startTest();
		WebServiceUser.Result result = WebServiceUser.CreateForTest(email);
		Test.stopTest();

		Account a = [SELECT Type, FirstName, LastName, PersonEmail, Code_MyAccount__pc FROM Account WHERE PersonEmail = :email LIMIT 1];

		System.assertEquals(true, result.status);
		System.assertEquals(a.Type, 'Test');
		System.assertEquals(a.FirstName, email);
		System.assertEquals(a.LastName, email);
		System.assertNotEquals(a.Code_MyAccount__pc, null);
		System.assertEquals(a.Code_MyAccount__pc, result.message);
		System.assertEquals(a.PersonEmail, email);
	}

	/**
	 * Test method for GetLicensesInformations function
	 */
	@IsTest
	static void GetLicensesInformationsFlexeraTEST() {
		Contact c = [SELECT Website_Id__c FROM Contact WHERE FirstName = 'Martin' LIMIT 1];
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('jsonCryptlexMockLicenceCreation');
		mock.setStatusCode(200);
		mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
		Test.setMock(HttpCalloutMock.class, mock);

		Test.startTest();
		WebServiceUser.ResultLicensesInformations result = WebServiceUser.GetLicensesInformations(WebServiceUser.GetLicenses(c.Website_Id__c).licenses);
		Test.stopTest();

		System.assertEquals(true, result.status);

		Map<String, Object> resultObject = (Map<String, Object>) JSON.deserializeUntyped(result.json);
		Map<String, Object> resultsCompany = (Map<String, Object>) resultObject.get('company');

		List<Object> annuals = (List<Object>) resultsCompany.get('annual');
		List<Object> perpetuals = (List<Object>) resultsCompany.get('perpetual');

		System.assertEquals(2, annuals.size());
		System.assertEquals(1, perpetuals.size());

		Map<String, Object> resultsAcademic = (Map<String, Object>) resultObject.get('academic');
		List<Object> perpetualsAcademic = (List<Object>) resultsAcademic.get('perpetual');

		System.assertEquals(1, perpetualsAcademic.size());
		System.assertEquals('TestVersion', ((Map<String, Object>) perpetualsAcademic[0]).get('version'));
	}

	/**
	 * Test method for GetLicensesInformationsDistrib function
	 */
	@IsTest
	static void GetLicensesInformationsFlexeraDistribTEST() {
		Contact c = [SELECT Website_Id__c FROM Contact WHERE FirstName = 'Simon'];
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('jsonCryptlexMockLicenceCreation');
		mock.setStatusCode(200);
		mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
		Test.setMock(HttpCalloutMock.class, mock);

		Test.startTest();
		WebServiceUser.ResultLicensesInformations result = WebServiceUser.GetLicensesInformationsDistrib(c.Website_Id__c);
		Test.stopTest();

		System.assertEquals(false, result.status);
	}
}