public class QuoteExtensionTaxamo {

	private final Quote quote;
	public QuoteLineItem[] quoteLineItems { get; set; }

	public String State { get; set; } // Nom de l'Etat traduit
	public String Country { get; set; } // Nom de Pays traduit
	public String CountryCode { get; set; } // Code Pays pour le format de page
	public Boolean hasTVACustomer { get; set; } // Le client a t il un nimo de TVA
	public Boolean isDiscountCompanyDisplayed { get; set; } // Affichage d'un discount pour les companies

	public QuoteExtensionTaxamo(ApexPages.StandardController stdController) {
		if (!Test.isRunningTest()) stdController.addFields(new List<String> { 'TaxamoAmount__c', 'TaxamoTaxeAmount__c', 'TaxamoTotalAmount__c', 'Opportunity.Account.Num_ro_de_TVA__c', 'CompanyDiscountDisplayed__c', 'Domaine_utilisateur__c', 'AddinSoftCompany__c', 'GenerateFactureEN__c' });
		quote = (Quote) stdController.getRecord();

		quoteLineItems = [Select PricebookEntry.Product2.Libelle_Devis__c, PricebookEntry.Product2.Type_licence__c,
		                  PricebookEntry.Product2.Domaine_utilisateur_en__c, PricebookEntry.Product2.name,
		                  PricebookEntry.Product2.Type_licence_desc__c, PricebookEntry.Product2.Type_licence_desc_EN__c,
		                  TaxamoTotalAmount__c, TaxamoAmount__c, TaxamoTaxeAmount__c, TaxamoTaxeRate__c,
		                  UnitPriceWithCurrency__c, quantity, TotalPriceAfterDiscountWithCurrency__c, Total_Price__c,
		                  Percent_Discount_Facture__c, TotalPriceWithCurrency__c, Unit_Price_Catalogue__c From QuoteLineItem where Quote.Id = :quote.Id];

		// TVA client
		hasTVACustomer = Quote.Opportunity.Account != null && Quote.Opportunity.Account.Num_ro_de_TVA__c != null && Quote.Opportunity.Account.Num_ro_de_TVA__c.length() > 0;

		// Discount Company
		isDiscountCompanyDisplayed = quote.CompanyDiscountDisplayed__c && quote.Domaine_utilisateur__c == 'Company';

		// Traduction du nom de l'etat et du pays
		Country = HelperQuote.getEnNameForCountryCode(quote.BillingCountryCode);
		if (quote.BillingStateCode != null) State = HelperQuote.getEnTranslationForState(quote.BillingCountryCode, quote.BillingStateCode);

		// Code Pays pour le format de lettre
		CountryCode = quote.BillingCountryCode;
	}
}