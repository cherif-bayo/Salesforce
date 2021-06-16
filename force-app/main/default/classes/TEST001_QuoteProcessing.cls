@isTest
public class TEST001_QuoteProcessing {

	@IsTest
	public static void testEnvoiDevis() {

		Id quoteId = HelperTestData.createQuoteWithProductWithContact();
		System.debug('[TEST001_QuoteProcessing#creationCommandeAvecClientFinal] quoteId :'+ quoteId);

		Test.startTest();
		CL001_QuoteProcessing qp = new CL001_QuoteProcessing (quoteId, 'FR', 'email@adinsoft.edu', CL001_UTL_EmailCreationForSendingQuote.QuoteType.QUOTE);
		qp.execute(null);
		Test.stopTest();
	}
}