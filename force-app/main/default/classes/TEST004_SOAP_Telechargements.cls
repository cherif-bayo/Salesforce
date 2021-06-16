@IsTest
public class TEST004_SOAP_Telechargements {

	@TestSetup
	private static void setup() {
		List<Software__c> softwares = new List<Software__c>{
				new Software__c(AccessType__c='Multiple', Code__c='00', Name='XLSTAT', DevelopmentDone__c=true, ProductId__c='44affc53-2fc9-4942-a8bb-5f87214c8f0a'),
				new Software__c(AccessType__c='Simple', Code__c='01', Name='XLRISK', ProductId__c='abb8ac81-f3a1-402a-a5e5-e90b444aa933')
		};
		insert softwares;
	}

	@IsTest
	public static void testCreateLead() {
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('jsonCryptlexMockLicenceCreation');
		mock.setStatusCode(200);
		mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
		Test.setMock(HttpCalloutMock.class, mock);

		WS004_SOAP_Telechargements_v2.Person p = new WS004_SOAP_Telechargements_v2.Person();
		p.firstName = 'firstName';
		p.lastName = 'lastName';
		p.email = 'test@test.fr';
		p.phone = '04040404';
		p.position = 'position';
		p.company = 'company';
		p.locale = 'fr';
		p.countryCode = 'FR';
		p.domainCode = 'domain';

		WS004_SOAP_Telechargements_v2.Download download = new WS004_SOAP_Telechargements_v2.Download();
		download.dateDownload = Date.newInstance(1960, 2, 17);

		Test.startTest();
		WS004_SOAP_Telechargements_v2.createTelechargement(p, download);
		Test.stopTest();

		List<Lead> leads = [SELECT Id FROM Lead];
		System.assert(leads.size() > 0);
	}

	@IsTest
	public static void testUpdateLead() {
		Lead lead = new Lead(LastName = 'test', Email = 'test@test.fr');
		insert lead;

		WS004_SOAP_Telechargements_v2.Person p = new WS004_SOAP_Telechargements_v2.Person();
		p.firstName = 'firstName';
		p.lastName = 'lastName';
		p.email = 'test@test.fr';
		p.phone = '04040404';
		p.position = 'position';
		p.company = 'company';
		p.locale = 'fr';
		p.countryCode = 'FR';
		p.domainCode = 'domain';

		WS004_SOAP_Telechargements_v2.Download download = new WS004_SOAP_Telechargements_v2.Download();
		download.dateDownload = Date.newInstance(1960, 2, 17);

		Test.startTest();
		WS004_SOAP_Telechargements_v2.createTelechargement(p, download);
		Test.stopTest();

		// Pas de création mais MAJ du lead existant
		List<Lead> leads = [SELECT FirstName FROM Lead WHERE Email = 'test@test.fr'];
		System.assert(leads.size() == 1);
		System.assertEquals(leads[0].FirstName, 'firstName');
	}

	@IsTest
	public static void testUpdateContact() {
		Account act = new Account(Name = 'test');
		insert act;

		Contact ct = new Contact(LastName = 'test', Email = 'test@test.fr');
		insert ct;

		WS004_SOAP_Telechargements_v2.Person p = new WS004_SOAP_Telechargements_v2.Person();
		p.firstName = 'firstName';
		p.lastName = 'lastName';
		p.email = 'test@test.fr';
		p.phone = '04040404';
		p.position = 'position';
		p.company = 'company';
		p.locale = 'fr';
		p.countryCode = 'FR';
		p.domainCode = 'domain';

		WS004_SOAP_Telechargements_v2.Download download = new WS004_SOAP_Telechargements_v2.Download();
		download.dateDownload = Date.newInstance(1960, 2, 17);

		Test.startTest();
		WS004_SOAP_Telechargements_v2.createTelechargement(p, download);
		Test.stopTest();

		// Pas de lead créé
		List<Lead> leads = [SELECT FirstName FROM Lead WHERE Email = 'test@test.fr'];
		System.assert(leads.size() == 0);

		// Pas de contact créé mais un contact MAJ
		List<Contact> cts = [SELECT FirstName FROM Contact WHERE Email = 'test@test.fr'];
		System.assert(cts.size() == 1);
	}


}