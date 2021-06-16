@isTest
class Test_InitSandbox {

	@isTest
	static void testMySandboxPrep() {

		Test.startTest();
		Test.testSandboxPostCopyScript(new InitSandbox(), UserInfo.getOrganizationId(), UserInfo.getOrganizationId(), UserInfo.getOrganizationName());
		Test.stopTest();		
	}
}