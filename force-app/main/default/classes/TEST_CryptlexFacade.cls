@IsTest
public class TEST_CryptlexFacade {

	@TestSetup
	public static void setup() {
		List<Software__c> softwares = new List<Software__c>{
				new Software__c(AccessType__c='Multiple', Code__c='00', Name='XLSTAT', DevelopmentDone__c=true, ProductId__c='44affc53-2fc9-4942-a8bb-5f87214c8f0a'),
				new Software__c(AccessType__c='Simple', Code__c='01', Name='XLRISK', ProductId__c='abb8ac81-f3a1-402a-a5e5-e90b444aa933')
		};
		insert softwares;
	}

	@IsTest
	public static void testGenerateLicences() {
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('jsonCryptlexMockLicenceCreation');
		mock.setStatusCode(201);
		mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
		Test.setMock(HttpCalloutMock.class, mock);

		Test.startTest();
		/*CryptlexFacade.key keyTrial = CryptlexFacade.getNewTrialKey();
		CryptlexFacade.key keyAnnual = CryptlexFacade.getNewAnnualKey('domain', 'licence', new List<String> { 'test' }, 10, Date.today().addDays(3));
		CryptlexFacade.key keyPerpetual = CryptlexFacade.getNewPerpetualKey('domain', 'licence', new List<String> { 'test' }, 10, Date.today());
		CryptlexFacade.key keyNetwork = CryptlexFacade.getNewNetworkKey('domain', 'licence', new List<String> { 'test' }, 10, Date.today().addDays(3));*/
		LicenseKey keyTrial = CryptlexFacade.getNewTrialKey('00');
		LicenseKey keyAnnual = CryptlexFacade.getNewAnnualKey('domain', 'licence', new List<String> { 'XLSTAT' }, 10, Date.today().addDays(3));
		LicenseKey keyPerpetual = CryptlexFacade.getNewPerpetualKey('domain', 'licence', new List<String> { 'XLSTAT' }, 10, Date.today());
		LicenseKey keyNetwork = CryptlexFacade.getNewNetworkKey('domain', 'licence', new List<String> { 'XLSTAT' }, 10, Date.today().addDays(3));
		Test.stopTest();

		System.assert(keyTrial != null);
		System.assert(keyAnnual != null);
		System.assert(keyPerpetual != null);
		System.assert(keyNetwork != null);
	}

	@IsTest
	public static void testRenewingLicence() {
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('jsonCryptlexMockLicenceCreation');
		mock.setStatusCode(200);
		mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
		Test.setMock(HttpCalloutMock.class, mock);

		Test.startTest();
		Boolean statusAnnual = CryptlexFacade.renewingAnnualKey('Id');
		Boolean statusPerpetual = CryptlexFacade.renewingPerpetualKey('Id');
		Test.stopTest();

		System.assert(statusAnnual);
		System.assert(statusPerpetual);
	}

	@IsTest
	public static void testExtendingLicence() {
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('jsonCryptlexMockLicenceCreation');
		mock.setStatusCode(200);
		mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
		Test.setMock(HttpCalloutMock.class, mock);

		Test.startTest();
		Boolean statusAnnual = CryptlexFacade.extendingKey('Id', 3600);
		Boolean statusPerpetual = CryptlexFacade.extendingPerpetualKey('Id', 3600);
		Test.stopTest();

		System.assert(statusAnnual);
		System.assert(statusPerpetual);
	}

	@IsTest
	public static void testGetInformations() {
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('jsonCryptlexMockLicenceCreation');
		mock.setStatusCode(200);
		mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
		Test.setMock(HttpCalloutMock.class, mock);

		Test.startTest();
		FlexeraController.ResultGetInformations result = CryptlexFacade.GetInformationsForController('Id');
		Test.stopTest();

		System.assert(result != null);
	}

	@IsTest
	public static void testSuspendKey() {
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('jsonCryptlexMockLicenceCreation');
		mock.setStatusCode(200);
		mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
		Test.setMock(HttpCalloutMock.class, mock);

		Test.startTest();
		Boolean result = CryptlexFacade.setSuspendStateKey('Id',true);
		Test.stopTest();

		System.assert(result);
	}

	@IsTest
	public static void testUpdateKey() {
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('jsonCryptlexMockLicenceCreation');
		mock.setStatusCode(200);
		mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
		Test.setMock(HttpCalloutMock.class, mock);

		Test.startTest();
		Boolean result = CryptlexFacade.updateKey('id','domain', 'licence', new List<String> { 'XLSTAT' }, 10);
		Test.stopTest();

		System.assert(result);
	}

	@IsTest
	public static void testErrors() {
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('jsonCryptlexMockLicenceCreation');
		mock.setStatusCode(500);
		mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
		Test.setMock(HttpCalloutMock.class, mock);

		Test.startTest();
		try {
			LicenseKey key = CryptlexFacade.getNewTrialKey('00');
		} catch(CryptlexException ce) { }
		Test.stopTest();
	}
}