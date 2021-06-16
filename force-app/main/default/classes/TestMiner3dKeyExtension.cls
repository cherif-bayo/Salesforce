@isTest
global class TestMiner3dKeyExtension {

	@isTest
	public static void testKeyCreation() {

		PageReference aPage = Page.NewMiner3dKey;
		test.setCurrentPage(aPage);

		CleMiner3D__c key = new CleMiner3D__c(Proprietaire__c = 'propriétaire', solution__c='TRIAL', DateLimite__c = Date.today().addYears(1));
		Apexpages.StandardController sc = new Apexpages.standardController(key);

		Miner3dKeyExtension ext = new Miner3dKeyExtension(sc);

		Test.setMock(HttpCalloutMock.class, new MockMiner3dKeyGenerator());

		PageReference nextPage = ext.save();

		List<CleMiner3D__c> keys = [select Id from CleMiner3D__c];
	}

}