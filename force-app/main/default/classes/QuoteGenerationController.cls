public with sharing class QuoteGenerationController {
	public Quote quote { get; set; }

	public QuoteGenerationController(ApexPages.StandardController stdController) {
		if (!Test.isRunningTest()) stdController.addFields(new List<String> { 'CurrencyIsoCode','GenerateFactureEN__c','AddinSoftCompany__c'});
		quote = (Quote) stdController.getRecord();
	}

	public PageReference Generate() {
		try {
			// Choix du compte bancaire à référencer
			PageReference pg;
			if (quote.currencyIsoCode == 'JPY') pg = new PageReference('/apex/quote_jp?id=' + quote.Id);
			else if (ParametersForOrders.US_COMPANY.equals(quote.AddinSoftCompany__c)) pg = new PageReference('/apex/quote_Taxamo?id=' + quote.Id);
			else if (!quote.GenerateFactureEN__c) pg = new PageReference('/apex/quote_fr?id=' + quote.Id);
			else pg = new PageReference('/apex/quote_en?id=' + quote.Id);

			// Creation de l'edition du devis
			QuoteDocument quotedoc = new QuoteDocument();
			if (Test.isRunningTest()) quotedoc.Document = blob.valueOf('Unit.Test');
			else quotedoc.Document = pg.getContent();
			quotedoc.QuoteId = quote.Id;
			insert quotedoc;

			// Redirection vers la page du devis
			PageReference pageRef = new PageREference('/' + quote.Id);
			pageRef.setRedirect(true);
			return pageRef;
		} catch(Exception e) {
			ApexPages.addMessages(e);
		}

		return null;
	}
}