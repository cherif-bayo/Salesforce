@IsTest
public class TEST004_HelperLeads_v2 {

	@TestSetup
	public static void setup() {
		List<Software__c> softwares = new List<Software__c>{
				new Software__c(AccessType__c='Multiple', Code__c='00', Name='XLSTAT', DevelopmentDone__c=true, ProductId__c='44affc53-2fc9-4942-a8bb-5f87214c8f0a'),
				new Software__c(AccessType__c='Simple', Code__c='01', Name='XLRISK', ProductId__c='abb8ac81-f3a1-402a-a5e5-e90b444aa933')
		};
		insert softwares;
	}

	@IsTest
	public static void testcreateLead() {

		Date dt = Date.newInstance(1960, 2, 17);

		Test.startTest();
		Lead leadToInsert = CL004_HelperLeads_v2.createLeadWithoutDML(
				dt, 'firstName', 'lastName', 'email@email.fr', '060606060606', 'FR',
				'company', 'langue', 'domainCode', 'position', null, true, false
		);
		insert leadToInsert;
		Test.stopTest();
		Lead lead = [SELECT Date_premier_telechargement__c, Date_dernier_telechargement__c, FirstName, LastName, Email, Phone, CountryCode,
		             Company, Langue__c, Domain__c, Position__c, HasOptedOutOfEmail, No_mailling__c, HasOptedOutOfPhone__c FROM Lead LIMIT 1];
		System.assertEquals(dt, lead.Date_premier_telechargement__c);
		System.assertEquals(dt, lead.Date_dernier_telechargement__c);
		System.assertEquals('firstName', lead.FirstName);
		System.assertEquals('lastName', lead.LastName);
		System.assertEquals('email@email.fr', lead.Email);
		System.assertEquals('060606060606', lead.Phone);
		System.assertEquals('FR', lead.CountryCode);
		System.assertEquals('company', lead.Company);
		System.assertEquals('langue', lead.Langue__c);
		System.assertEquals('position', lead.Position__c);
		System.assertEquals(false, lead.HasOptedOutOfEmail);
		System.assertEquals(false, lead.No_mailling__c);
		System.assertEquals(true, lead.HasOptedOutOfPhone__c);
		System.assert(lead.Domain__c == null);
	}

	@IsTest
	public static void testUpdateLead() {
		Date dt = Date.newInstance(1960, 2, 17);
		Lead lead = new Lead(LastName = 'test');
		insert lead;
		Test.startTest();
		CL004_HelperLeads_v2.updateLeadWithoutDML(lead, dt, 'firstName', 'lastName', 'domainCode', null, true, false);
		update lead;
		Test.stopTest();
		Lead lead2 = [
				SELECT Date_premier_telechargement__c, Date_dernier_telechargement__c, FirstName, LastName, Domain__c, LeadSource,
		              HasOptedOutOfEmail, No_mailling__c, HasOptedOutOfPhone__c
				FROM Lead LIMIT 1
		];
		System.assertEquals(dt, lead2.Date_premier_telechargement__c);
		System.assertEquals(dt, lead2.Date_dernier_telechargement__c);
		System.assertEquals('firstName', lead2.FirstName);
		System.assertEquals('lastName', lead2.LastName);
		System.assertEquals(false, lead2.HasOptedOutOfEmail);
		System.assertEquals(false, lead2.No_mailling__c);
		System.assertEquals(true, lead2.HasOptedOutOfPhone__c);
		System.assertEquals(CL003_Constants.ORIGINE_DOWNLOAD, lead2.LeadSource);
		System.assert(lead2.Domain__c == null);
	}

	@IsTest
	public static void testCreateTrialKeyAndSendEmail() {
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('jsonCryptlexMockLicenceCreation');
		mock.setStatusCode(200);
		mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
		Test.setMock(HttpCalloutMock.class, mock);
		Date dt = Date.newInstance(1960, 2, 17);
		Lead lead = CL004_HelperLeads_v2.createLeadWithoutDML(
				dt, 'firstName', 'lastName', 'email@email.fr', '060606060606', 'FR',
				'company', 'langue', 'domainCode', 'position', null, true, false
		);
		insert lead;
		Test.startTest();
		String keyName = CL004_HelperLeads_v2.createTrialKeyAndSendEmail(lead, 'FR');
		Test.stopTest();
		System.assertNotEquals('', keyName);
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