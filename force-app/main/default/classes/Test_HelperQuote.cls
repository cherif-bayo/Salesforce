@isTest
public class Test_HelperQuote  {

	@IsTest
	public static void mainTest() {
		HelperQuote.getEnAddinsoftCompanyLines(false);
		HelperQuote.getEnAddinsoftCompanyLines(true);
		HelperQuote.getEnNameForCountryCode('ES');
		HelperQuote.getEnTranslationForState('EU','AK');
		HelperQuote.getFrBankAccountLines('Canada', 'USD');
		HelperQuote.getFrBankAccountLines('France','EUR');
		HelperQuote.getFrBankAccountLines('Espagne','EUR');
		HelperQuote.getEnBankAccountLines(true,'EU','USD');
		HelperQuote.getEnBankAccountLines(false,'Canada','USD');
		HelperQuote.getEnBankAccountLines(false,'Irlande','GBP');
		HelperQuote.getEnBankAccountLines(false,'Espagne','EUR');
		HelperQuote.getEnBankAccountLines(false,'France','EUR');
	}
}