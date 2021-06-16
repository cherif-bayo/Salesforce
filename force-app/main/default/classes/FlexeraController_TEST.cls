@IsTest
private class FlexeraController_TEST {

	@TestSetup static void setup() {
		//Create common test account
		Account a = new Account();
		a.Name = 'Test Account';
		insert a;

		//Create common test contact
		Contact c = new Contact();
		c.FirstName = 'Camille';
		c.LastName = 'Honnet';
		c.AccountId = a.Id;
		c.MailingCountryCode = 'FR';
		insert c;

		//Create common test flexera_key
		Flexera_Key__c key01 = new Flexera_Key__c();
		key01.Account__c = a.Id;
		key01.Contact__c = c.Id;
		key01.Date_limite__c = Date.today();
		key01.Quantity__c = 1;
		key01.Expiration__c = 'Expiring';
		key01.Entitlement_Id__c = 'Test';
		key01.Nb_activations_allowed__c = 1;
		key01.Domaine_utilisateur__c = 'Company';
		key01.Type_licence__c = 'Annuelle';
		key01.Date_limite__c = Date.today();
		key01.XLSTAT_Solution__c = 'XLSTAT-Premium';
		key01.Is_Network__c = false;
		insert key01;

		Flexera_Key__c key02 = new Flexera_Key__c();
		key02.Account__c = a.Id;
		key02.Contact__c = c.Id;
		key02.Date_limite__c = Date.today() - 30;
		key02.Quantity__c = 2;
		key02.Expiration__c = 'Permanent';
		key01.Entitlement_Id__c = 'Tets';
		key01.Nb_activations_allowed__c = 5;
		key01.Domaine_utilisateur__c = 'Academic';
		key01.Type_licence__c = 'Perpétuelle';
		key01.Date_limite__c = Date.today() - 30;
		key01.XLSTAT_Solution__c = 'XLSTAT-Base';
		key01.XLSTAT_Options__c = 'XLSTAT-3DPlot';
		key01.Is_Network__c = true;
		insert key02;

		key02.Entitlement_Id__c = 'Test';
		key02.Date_limite__c = Date.today() + 60;
		update key02;

		List<Software__c> softwares = new List<Software__c>{
				new Software__c(AccessType__c='Multiple', Code__c='00', Name='XLSTAT', DevelopmentDone__c=true, ProductId__c='44affc53-2fc9-4942-a8bb-5f87214c8f0a'),
				new Software__c(AccessType__c='Simple', Code__c='01', Name='XLRISK', ProductId__c='abb8ac81-f3a1-402a-a5e5-e90b444aa933')
		};
		insert softwares;
	}

	@IsTest static void testMethod_Key() {
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('jsonCryptlexMockLicenceCreation');
		mock.setStatusCode(201);
		mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
		Test.setMock(HttpCalloutMock.class, mock);

		Account a = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
		Contact c = [SELECT Id, FirstName, LastName, Email, MailingCountryCode FROM Contact WHERE LastName = 'Honnet' LIMIT 1];

		Flexera_Key__c key = [SELECT Id, Flexera_Key__c.Contact__r.Id, Nb_activations_allowed__c, Domaine_utilisateur__c, Type_licence__c, Expiration__c, Date_limite__c, Is_Network__c, XLSTAT_Solution__c, XLSTAT_Options__c FROM Flexera_Key__c WHERE Contact__c = :c.Id AND Date_limite__c = :Date.today()];

		Test.startTest();

		FlexeraController fcontroller = new FlexeraController();
		FlexeraController.Generate(1, key, c);

		Flexera_Key__c newkey = key;
		newkey.Expiration__c = 'Permanent';
		newkey.Entitlement_Id__c = 'Test';
		newkey.Nb_activations_allowed__c = 5;
		newkey.Domaine_utilisateur__c = 'Campus';
		newkey.Type_licence__c = 'Perpétuelle';
		newkey.Date_limite__c = Date.today() - 30;
		newkey.XLSTAT_Solution__c = 'XLSTAT-Base';
		newkey.XLSTAT_Options__c = 'XLSTAT-3DPlot';
		newkey.Is_Network__c = true;

		mock.setStatusCode(200);
		FlexeraController.UpdateKey(key, newkey);

		List<String> lstToAdd = new List<String> ();
		lstToAdd.add(key.XLSTAT_Solution__c.trim());
		FlexeraController.DeactivateEntitlement(key.Entitlement_Id__c);

		FlexeraController.UpdateKeyLimit(key.Entitlement_Id__c, 'Test', 'Anuelle');
		FlexeraController.UpdateKeyLimit(key.Entitlement_Id__c, 'Test', 'Permanent');

		FlexeraController.UpdateKey(newkey, key);

		FlexeraController.GetInformations(key.Entitlement_Id__c);
		Test.stopTest();
	}

	@IsTest static void generateTrialKey() {
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('jsonCryptlexMockLicenceCreation');
		mock.setStatusCode(201);
		mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
		Test.setMock(HttpCalloutMock.class, mock);

		FlexeraController.ResultCreateEntitlement r = new FlexeraController.ResultCreateEntitlement();

		Lead lead = new Lead(FirstName = 'firstname', LastName = 'LastName', Email = 'test@xlstat.com');

		Flexera_Key__c key = new Flexera_Key__c();
		key.XLSTAT_Solution__c = 'XLSTAT-Premium';
		key.Domaine_utilisateur__c = Parameters.getString('Trial_Domain_User');
		key.Quantity__c = 1;
		key.Nb_activations_allowed__c = key.Quantity__c;
		key.Expiration__c = FlexeraController.EXPIRATION_EXPIRING;
		key.Lead__c = lead.Id;

		Test.startTest();
		FlexeraController.ResultGenerateKey resultFlexeraGeneratedKey = FlexeraController.Generate(key, lead);
		Test.stopTest();

		System.assert(resultFlexeraGeneratedKey.Status);
	}
}