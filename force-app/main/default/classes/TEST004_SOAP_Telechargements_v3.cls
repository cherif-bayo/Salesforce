@IsTest
public class TEST004_SOAP_Telechargements_v3 {

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

		WS004_SOAP_Telechargements_v3.Person p = new WS004_SOAP_Telechargements_v3.Person();
		p.firstName = 'firstName';
		p.lastName = 'lastName';
		p.email = 'test@test.fr';
		p.phone = '04040404';
		p.position = 'position';
		p.company = 'company';
		p.locale = 'fr';
		p.countryCode = 'FR';
		p.domainCode = 'domain';
		p.HasOptedOutOfPhone = true;
		p.HasOptedOutOfEmail = false;

		WS004_SOAP_Telechargements_v3.Download download = new WS004_SOAP_Telechargements_v3.Download();
		download.dateDownload = Date.newInstance(1960, 2, 17);

		Test.startTest();
		WS004_SOAP_Telechargements_v3.createTelechargement(p, download);
		Test.stopTest();

		List<Lead> leads = [SELECT Id FROM Lead];
		System.assert(leads.size() > 0);
	}

	@IsTest
	public static void testUpdateLead() {
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('jsonCryptlexMockLicenceCreation');
		mock.setStatusCode(200);
		mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
		Test.setMock(HttpCalloutMock.class, mock);
		Lead lead = new Lead(LastName = 'test', Email = 'test@test.fr', FirstName = 'test');
		insert lead;

		WS004_SOAP_Telechargements_v3.Person p = new WS004_SOAP_Telechargements_v3.Person();
		p.firstName = 'firstName';
		p.lastName = 'lastName';
		p.email = 'test@test.fr';
		p.phone = '04040404';
		p.position = 'position';
		p.company = 'company';
		p.locale = 'fr';
		p.countryCode = 'FR';
		p.domainCode = 'domain';
		p.HasOptedOutOfPhone = true;
		p.HasOptedOutOfEmail = false;

		WS004_SOAP_Telechargements_v3.Download download = new WS004_SOAP_Telechargements_v3.Download();
		download.dateDownload = Date.newInstance(1960, 2, 17);
		download.osDownload = 'macOs';

		Test.startTest();
		WS004_SOAP_Telechargements_v3.createTelechargement(p, download);
		Test.stopTest();

		// Pas de création mais MAJ du lead existant
		List<Lead> leads = [SELECT FirstName FROM Lead WHERE Email = 'test@test.fr'];
		System.assert(leads.size() == 1);
	}

	@IsTest
	public static void testUpdateLeadWithKey() {
		Lead lead = new Lead(LastName = 'test', Email = 'test@test.fr', FirstName = 'test', numoKey__c = 'zzz');
		insert lead;
		Flexera_Key__c Key =  new Flexera_Key__c(Lead__c = lead.Id, Expiration__c = 'Expiring', Quantity__c = 1);
        insert Key;

		WS004_SOAP_Telechargements_v3.Person p = new WS004_SOAP_Telechargements_v3.Person();
		p.firstName = 'firstName';
		p.lastName = 'lastName';
		p.email = 'test@test.fr';
		p.phone = '04040404';
		p.position = 'position';
		p.company = 'company';
		p.locale = 'fr';
		p.countryCode = 'FR';
		p.domainCode = 'domain';
		p.HasOptedOutOfPhone = true;
		p.HasOptedOutOfEmail = false;

		WS004_SOAP_Telechargements_v3.Download download = new WS004_SOAP_Telechargements_v3.Download();
		download.dateDownload = Date.newInstance(1960, 2, 17);
		download.osDownload = 'macOs';

		Test.startTest();
		WS004_SOAP_Telechargements_v3.createTelechargement(p, download);
		Test.stopTest();

		// Pas de création mais MAJ du lead existant
		List<Lead> leads = [SELECT FirstName FROM Lead WHERE Email = 'test@test.fr'];
		System.assert(leads.size() == 1);
	}

	@IsTest
	public static void testEmailAuthorizedWithExistingLead() {
		insert new Lead(LastName = 'test', Email = 'test@test.fr', numoKey__c = 'zzz');

		Test.startTest();
		Boolean ret = WS004_SOAP_Telechargements_v3.isEmailAuthorized('test@test.fr');
		Test.stopTest();

		System.assert(ret=true);
	}

	@IsTest
	public static void testEmailAuthorizedWithExistingLeadWithoutKey() {
		insert new Lead(LastName = 'test', Email = 'test@test.fr');

		Test.startTest();
		Boolean ret = WS004_SOAP_Telechargements_v3.isEmailAuthorized('test@test.fr');
		Test.stopTest();

		System.assert(ret);
	}

	@IsTest
	public static void testEmailAuthorizedOK() {

		Test.startTest();
		Boolean ret = WS004_SOAP_Telechargements_v3.isEmailAuthorized('test@test.fr');
		Test.stopTest();

		System.assert(ret);
	}
    
    @IsTest public static void sendEmailWithoutKey() {
        Lead lead = new Lead(FirstName='firstName',LastName='lastName',Email='test@xlstat.com', Langue__c= 'fr');
        insert lead;
                
        Test.startTest();
        CL004_HelperLeads_v2.sendEmailWithoutKey(lead.Id, lead.Langue__c, lead.Email);
        Integer invocations = Limits.getEmailInvocations();
        Test.stopTest();
        
        System.assertEquals(1, invocations, 'An email has been sent');
    }

}