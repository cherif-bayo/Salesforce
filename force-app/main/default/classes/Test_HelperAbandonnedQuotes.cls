@isTest
private class Test_HelperAbandonnedQuotes {

@TestSetup
	private static void setUp() {

		HelperTestData.createQuoteWithProductWithContact();
		Quote q = [select CreatedDate,TotalPrice,Devis_Abandonne_Relance__c from Quote limit 1];
        Quote o = [select Id from Quote limit 1];
        o.Website_Auto__c = true;
		update o;

		System.debug('[Test_HelperAbandonnedQuotes] quote :' + q);
	}

	@isTest
	private static void testName() {
		HelperAbandonnedQuotes helper = new HelperAbandonnedQuotes();
		helper.getProspects();

		helper.markAbonnedQuotesAsCovered();
	}
}