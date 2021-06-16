@isTest
public class Test_SendEmailConfirmationStudent {

	@TestSetup
	public static void setUp() {
		HelperTestData.createContactAndAccountByAccountNameAndContactEmail('test','test@test.fr');
		Contact ct = [select AccountId from Contact limit 1];
		HelperTestData.createOrderWithProductWithContact(ct);
	}

	@IsTest
	public static void testMain() {
		Order o = [select Id from Order limit 1];
		List<FlexeraController.ResultGenerateKey> resultsFlexeraGeneratedKey = new List <FlexeraController.ResultGenerateKey>();
		SCH001_SendEmailConfirmationStudent sc = new SCH001_SendEmailConfirmationStudent(o,resultsFlexeraGeneratedKey);
		sc.execute(null);
	}
}