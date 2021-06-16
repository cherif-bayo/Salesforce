@isTest
public class testContactToPersonAccountExtension {

	@TestSetup
	public static void setup() {
		HelperTestData.createContactAndAccountByAccountNameAndContactEmail('test', 'test@test.fr');
	}

	public static testMethod void testMain() {
		Contact contact = [SELECT Id FROM Contact limit 1];

		ApexPages.StandardController sc = new ApexPages.standardController(contact);
		ContactToPersonAccountExtension ext = new ContactToPersonAccountExtension(sc);
		ext.Convert();
	}
}