@IsTest
public class Test_TrialKeyGeneration {

	@TestSetup
	private static void setup() {
		List<Software__c> softwares = new List<Software__c>{
				new Software__c(
						AccessType__c='Multiple', DevelopmentDone__c=true,
						Code__c='00',
						Name='XLSTAT',
						ProductId__c='44affc53-2fc9-4942-a8bb-5f87214c8f0a'
				),
				new Software__c(
						AccessType__c='Simple',
						Code__c='01',
						Name='XLRISK',
						ProductId__c='abb8ac81-f3a1-402a-a5e5-e90b444aa933'
				)
		};
		insert softwares;
	}

	@IsTest
	static void generateTrialKey() {
		Test.startTest();
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('jsonCryptlexMockLicenceCreation');
		mock.setStatusCode(201);
		mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
		Test.setMock(HttpCalloutMock.class, mock);
		CL004_TrialKeyGeneration.GenerateTrialKeyInFlexera();
		Test.stopTest();
	}

	@IsTest
	static void generateTrialKeys() {
		Test.startTest();
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('jsonCryptlexMockLicenceCreation');
		mock.setStatusCode(201);
		mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
		Test.setMock(HttpCalloutMock.class, mock);
		CL004_TrialKeyGeneration.GenerateTrialKeysInFlexera(2);
		Test.stopTest();
	}
}