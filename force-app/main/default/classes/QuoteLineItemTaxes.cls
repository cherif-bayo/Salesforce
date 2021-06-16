// Calcule des taxes pour le vendeur Addinsoft Inc. seulement
public class QuoteLineItemTaxes implements Queueable, Database.AllowsCallouts {
	List<Quote> quotes;
	@TestVisible Boolean makeCallout = true; // Test Queuable    

	public QuoteLineItemTaxes(List<Quote> allQuotes) {

		// List des ids de bons de commandes
		List<String> quoteIds = new List<String> ();
		for (Quote q : allQuotes) quoteIds.add(q.Id);

		// Récupération des infos nécessaires sur le quote à partir de la liste des ids
		List<Quote> quotes = [select AddinSoftCompany__c, BillingAddress, BillingStateCode, BillingPostalCode, BillingStreet,
		                      BillingCity, BillingCountry, BillingCountryCode, Opportunity.CurrencyIsoCode, us_tax_exemption_certificate_id__c, Discount_Client_Activated__c, Discount_Manuel_Activated__c
		                      from Quote where Id in :quoteIds];
		this.quotes = quotes;
		System.debug('[QuoteLineItemTaxes] creation du job pour les bons de commande suivants :' + quotes);
	}

	public void execute(QueueableContext context) {
		if (makeCallout) performCallout();
	}

	public void performCallout() {
		System.debug('[QuoteLineItemTaxes] lancement du job pour les bons de commande suivants :' + quotes);

		// List des ids de bons de commandes
		List<String> quoteIds = new List<String> ();
		for (Quote q : quotes) quoteIds.add(q.Id);

		// Récupération des lignes des bons de commandes
		List<QuoteLineItem> quoteItems = [select quoteId, LineNumber, ProductCode__c, ProductType__c, Percent_Discount_Total__c, UnitPrice, Quantity, Description
		                                  From QuoteLineItem where QuoteId in :quoteIds];

		// Récupération des devis avec les lignes de devis
		Map<String, List<QuoteLineItem>> quoteLineItemsByQuoteId = new Map<String, List<QuoteLineItem>> ();
		for (QuoteLineItem item : quoteItems) {
			if (quoteLineItemsByQuoteId.get(item.quoteId) == null) quoteLineItemsByQuoteId.put(item.quoteId, new List<QuoteLineItem> ());
			quoteLineItemsByQuoteId.get(item.quoteId).add(item);
		}

		// Traitement des lignes de devis par devis
		for (Quote quote : quotes) {

			// traitement des lignes de devis	
			Map<String, QuoteLineItem> lineItemByCustomId = new Map<String, QuoteLineItem> ();
			List<TaxamoFacade.TaxamoProductLineItem> taxamoItems = new List<TaxamoFacade.TaxamoProductLineItem> ();
			for (QuoteLineItem item : quoteLineItemsByQuoteId.get(quote.Id)) {
				TaxamoFacade.TaxamoProductLineItem taxamoItem = new TaxamoFacade.TaxamoProductLineItem();
				taxamoItem.custom_id = item.LineNumber;
				taxamoItem.product_code = item.ProductCode__c;
				taxamoItem.product_type = item.ProductType__c;
                taxamoItem.product_tax_code = '210116';
                if(quote.Discount_Manuel_Activated__c && item.Percent_Discount_Total__c != null && item.Percent_Discount_Total__c > 0){
                     // Trying to understand why this condition for quote taxamo.
                     taxamoItem.unit_price = item.UnitPrice - (item.UnitPrice * (item.Percent_Discount_Total__c / 100)); // Prix Unitaire après discount
            	}
                else if(quote.Discount_Client_Activated__c && item.Percent_Discount_Total__c != null && item.Percent_Discount_Total__c > 0){
                     // Trying to understand why this condition for quote taxamo.
                     taxamoItem.unit_price = item.UnitPrice - (item.UnitPrice * (item.Percent_Discount_Total__c / 100)); // Prix Unitaire après discount
            	}
            	else{
                	taxamoItem.unit_price = item.UnitPrice;
             	}
				 
				taxamoItem.quantity = Math.round(item.Quantity);
				taxamoItem.Description = item.Description;
				taxamoItems.add(taxamoItem);
				lineItemByCustomId.put(item.LineNumber, item);
			}

			// Récuperation de l'adresse du compte
			TaxamoFacade.TaxamoInvoiceAddress taxamoAdress = new TaxamoFacade.TaxamoInvoiceAddress();
			taxamoAdress.city = quote.BillingCity;
			taxamoAdress.country = quote.BillingCountryCode;
			taxamoAdress.postal_code = quote.BillingPostalCode;
			taxamoAdress.region = quote.BillingStateCode;
			taxamoAdress.street_name = quote.BillingStreet;

			// Parametres du service Taxamo
			TaxamoFacade.TaxamoServiceParams taxamoParams = new TaxamoFacade.TaxamoServiceParams();
			taxamoParams.currency_code = quote.Opportunity.CurrencyIsoCode;
			taxamoParams.billing_country_code = quote.BillingCountryCode;
			taxamoParams.invoice_address = taxamoAdress;

			// Ajout du taxe exemption
			if (quote.us_tax_exemption_certificate_id__c != null) {
				TaxamoFacade.Certificate c = new TaxamoFacade.Certificate();
				c.certificate_id = quote.us_tax_exemption_certificate_id__c;
				TaxamoFacade.TaxamoTaxData td = new TaxamoFacade.TaxamoTaxData();
				td.certificat = c;
				taxamoParams.tax_data = td;
			}

			// Ajout des lignes de devis
			taxamoParams.transaction_lines = taxamoItems;

			String taxamoResponse = TaxamoFacade.getTaxamoJsonResponse(taxamoParams, false); // Pas d'enregistrement de la transaction dans Taxamo
			Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(taxamoResponse);
			Map<String, Object> t = (Map<String, Object>) m.get('transaction');
			List<Object> transactions = (List<Object>) t.get('transaction_lines');
			for (Object o : transactions) {
				Map<String, Object> item = (Map<String, Object>) o;
				lineItemByCustomId.get((String) item.get('custom_id')).TaxamoAmount__c = (Decimal) item.get('amount');
				lineItemByCustomId.get((String) item.get('custom_id')).TaxamoTaxeAmount__c = (Decimal) item.get('tax_amount');
				lineItemByCustomId.get((String) item.get('custom_id')).TaxamoTaxeRate__c = (Decimal) item.get('tax_rate');
				lineItemByCustomId.get((String) item.get('custom_id')).TaxamoTotalAmount__c = (Decimal) item.get('total_amount');
				System.debug('[QuoteLineItemTaxes] Transaction Line' + item);
			}

			// Ajout du total des taxes Taxamo sur le devis
			quote.TaxamoAmount__c = (Decimal) t.get('amount');
			quote.TaxamoTaxeAmount__c = (Decimal) t.get('tax_amount');
			quote.TaxamoTotalAmount__c = (Decimal) t.get('total_amount');
		}

		update quoteItems;
		update quotes;
	}
}