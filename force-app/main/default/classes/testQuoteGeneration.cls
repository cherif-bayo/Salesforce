@isTest
public class testQuoteGeneration {

	@TestSetup
	public static void setUp() {
		HelperTestData.createQuoteWithProductWithContact();
	}

	@IsTest
	public static void testGenerationQuoteFr() {
		Quote quote = [select CurrencyIsoCode,GenerateFactureEN__c from Quote limit 1];
		Test.setCurrentPage(Page.quoteGeneration);
		QuoteGenerationController controller = new QuoteGenerationController(new ApexPages.StandardController(quote));
		controller.Generate();
	}
}