@IsTest
public class TEST001_CustomerWrapper {

	@TestSetup
	public static void setup() {
	}

	@IsTest
	public static void casNewAccountPerso() {
		WebServiceOrderV2.Customer contact = new WebServiceOrderV2.Customer();
		contact.FirstName = 'prenom';
		contact.LastName = 'nom';
		contact.Email = 'test@addinsoft.com';
		contact.company = '';
		contact.countryCode = 'FR';
		contact.street1 = 'street1';
		contact.street2 = 'street2';
		contact.postalCode = '33000';
		contact.city = 'city';
		contact.language = 'FR';

		CL001_CustomerWrapper cw = new CL001_CustomerWrapper(contact);

		Boolean isQuote = false;
		String currencyIsoCode = 'EUR';
		String userDomain = '';

		Test.startTest();
		cw.InsertInSalesforce(isQuote, currencyIsoCode, userDomain);
		Test.stopTest();
	}

	@IsTest
	public static void casNewAccountPro() {
		WebServiceOrderV2.Customer contact = new WebServiceOrderV2.Customer();
		contact.FirstName = 'prenom';
		contact.LastName = 'nom';
		contact.Email = 'test@addinsoft.com';
		contact.company = 'testAccount';
		contact.countryCode = 'FR';
		contact.street1 = 'street1';
		contact.street2 = 'street2';
		contact.postalCode = '33000';
		contact.city = 'city';
		contact.language = 'FR';

		CL001_CustomerWrapper cw = new CL001_CustomerWrapper(contact);

		Boolean isQuote = false;
		String currencyIsoCode = 'EUR';
		String userDomain = '';

		Test.startTest();
		cw.InsertInSalesforce(isQuote, currencyIsoCode, userDomain);
		Test.stopTest();
	}

	@IsTest
	public static void casAccountPersoNonExistant() {
		RecordType personAccountRecordType = [SELECT Name FROM RecordType WHERE SObjectType = 'Account' and isPersonType=true LIMIT 1];
		Account personAccount = new Account();
		personAccount.FirstName = 'Fred';
		personAccount.LastName = 'Smith';
		personAccount.PersonEmail = 'test@addinsoft.com';
		personAccount.RecordType = personAccountRecordType;
		insert personAccount;

		WebServiceOrderV2.Customer contact = new WebServiceOrderV2.Customer();
		contact.FirstName = 'prenom';
		contact.LastName = 'nom';
		contact.Email = 'test@addinsoft.com';
		contact.company = '';
		contact.countryCode = 'fr';
		contact.street1 = 'street1';
		contact.street2 = 'street2';
		contact.postalCode = '33000';
		contact.city = 'city';
		contact.language = 'FR';

		CL001_CustomerWrapper cw = new CL001_CustomerWrapper(contact);

		Boolean isQuote = true;
		String currencyIsoCode = 'EUR';
		String userDomain = '';

		Test.startTest();
		cw.InsertInSalesforce(isQuote, currencyIsoCode, userDomain);
		Test.stopTest();
	}

	@IsTest
	public static void casAccountPersoExistant() {
		RecordType personAccountRecordType = [SELECT Name FROM RecordType WHERE SObjectType = 'Account' and isPersonType=true LIMIT 1];
		Account personAccount = new Account();
		personAccount.FirstName = 'Fred';
		personAccount.LastName = 'Smith';
		personAccount.PersonEmail = 'test@addinsoft.com';
		personAccount.RecordType = personAccountRecordType;
		insert personAccount;
		personAccount  = [ select Website_Id__pc from Account limit 1];

		WebServiceOrderV2.Customer personnalAccount = new WebServiceOrderV2.Customer();
		personnalAccount.FirstName = 'prenom';
		personnalAccount.LastName = 'nom';
		personnalAccount.Email = 'test@addinsoft.com';
		personnalAccount.company = '';
		personnalAccount.id = personAccount.Website_Id__pc;
		personnalAccount.countryCode = 'fr';
		personnalAccount.street1 = 'street1';
		personnalAccount.street2 = 'street2';
		personnalAccount.postalCode = '33000';
		personnalAccount.city = 'city';
		personnalAccount.language = 'FR';

		CL001_CustomerWrapper cw = new CL001_CustomerWrapper(personnalAccount);

		Boolean isQuote = true;
		String currencyIsoCode = 'EUR';
		String userDomain = '';

		Test.startTest();
		cw.InsertInSalesforce(isQuote, currencyIsoCode, userDomain);
		Test.stopTest();
	}

	@IsTest
	public static void casAccountProExistant() {
		Account account = new Account(Name = 'testAccount');
		account.BillingCountryCode = 'fr';
		insert account;

		WebServiceOrderV2.Customer contact = new WebServiceOrderV2.Customer();
		contact.FirstName = 'prenom';
		contact.LastName = 'nom';
		contact.Email = 'test@addinsoft.com';
		contact.company = '';
		contact.countryCode = 'fr';
		contact.street1 = 'street1';
		contact.street2 = 'street2';
		contact.postalCode = '33000';
		contact.city = 'city';
		contact.language = 'FR';

		CL001_CustomerWrapper cw = new CL001_CustomerWrapper(contact);

		Boolean isQuote = false;
		String currencyIsoCode = 'EUR';
		String userDomain = '';

		Test.startTest();
		cw.InsertInSalesforce(isQuote, currencyIsoCode, userDomain);
		Test.stopTest();
	}

	@IsTest
	public static void casContactExistant() {
		HelperTestData.createContactAndAccountByAccountNameAndContactEmail('testAccount', 'test@addinsoft.com');

		Contact ct = [select Website_Id__c from Contact limit 1];

		WebServiceOrderV2.Customer contact = new WebServiceOrderV2.Customer();
		contact.FirstName = 'prenom';
		contact.LastName = 'nom';
		contact.Email = 'email@adinsoft.edu';
		contact.company = 'company1';
		contact.countryCode = 'FR';
		contact.street1 = 'street1';
		contact.street2 = 'street2';
		contact.postalCode = '33000';
		contact.city = 'city';
		contact.language = 'FR';
		contact.id = ct.Website_Id__c;

		CL001_CustomerWrapper cw = new CL001_CustomerWrapper(contact);

		Boolean isQuote = false;
		String currencyIsoCode = 'EUR';
		String userDomain = '';

		Test.startTest();
		cw.InsertInSalesforce(isQuote, currencyIsoCode, userDomain);
		Test.stopTest();
	}
}