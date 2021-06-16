@isTest
public class TestQuoteExtensionFr  {

	@TestSetup
	public static void setUp() {
		HelperTestData.createQuoteWithProductWithContact();
	}

	@IsTest
	public static void testGenerationQuoteFr() {
		Quote quote = [select BillingStateCode,BillingCountryCode,Domaine_utilisateur__c,CompanyDiscountDisplayed__c,Opportunity.Account.Num_ro_de_TVA__c,TVA__c,AddinSoftCompany__c,BillingCountry,CurrencyIsoCode,GenerateFactureEN__c from Quote limit 1];
		Test.setCurrentPage(Page.Quote_fr);
		QuoteExtensionFr ext = new QuoteExtensionFr(new ApexPages.StandardController(quote));
	}
}