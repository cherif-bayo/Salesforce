@isTest
public class TestQuoteExtensionEn  {

	@TestSetup
	public static void setUp() {
		HelperTestData.createQuoteWithProductWithContact();
	}

	@IsTest
	public static void testGenerationQuoteEn() {
		Quote quote = [select BillingStateCode,BillingCountryCode,Domaine_utilisateur__c,CompanyDiscountDisplayed__c,Opportunity.Account.Num_ro_de_TVA__c,TVA__c,AddinSoftCompany__c,BillingCountry,CurrencyIsoCode,GenerateFactureEN__c from Quote limit 1];
		Test.setCurrentPage(Page.Quote_en);
		QuoteExtensionEn ext = new QuoteExtensionEn(new ApexPages.StandardController(quote));
	}
}