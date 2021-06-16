public class FactureExtensionTaxamo  {

	private final Facture__c facture;
	public OrderItem[] orderItems { get; set; }

	public String State { get; set; } // Nom de l'Etat traduit
	public String Country { get; set; } // Nom de Pays traduit
	public String CountryCode { get; set; } // Code Pays pour le format de page
	public Boolean hasTVACustomer { get; set; } // Le client a t il un nimo de TVA

	public FactureExtensionTaxamo (ApexPages.StandardController stdController) {
		if (!Test.isRunningTest()) stdController.addFields(new List<String> {'US_Invoice_Code__c','BillingCountryCode__c','BillingState__c','Commande_lie__r.TaxamoAmount__c',
		'Commande_lie__r.TaxamoTaxeAmount__c','Commande_lie__r.TaxamoTotalAmount__c','Numero_de_TVA__c','BillingCountry__c','AddinSoftCompany2__c',
		'Commande_lie__r.HasDiscount__c','Commande_Lie__r.BillingCountryCode','Commande_lie__r.CurrencyIsoCode'});
		facture = (Facture__c) stdController.getRecord();

		orderItems = [Select PricebookEntry.Product2.Domaine_utilisateur_en__c, PricebookEntry.Product2.Type_licence__c, PricebookEntry.Product2.Domaine_utilisateur_Facture__c, 
		PricebookEntry.Product2.name, PricebookEntry.Product2.Libelle_Devis__c, PricebookEntry.Product2.Type_licence_desc_en__c,TaxamoTaxeRate__c, TaxamoTaxeAmount__c, 
		TaxamoTotalAmount__c, TaxamoAmount__c, PricebookEntry.Product2.Type_licence_desc__c,UnitPriceWithCurrency__c, quantity, TotalPriceAfterDiscountWithCurrency__c, TotalPriceWithCurrency__c, 
		Percent_Discount_Facture__c From OrderItem where OrderId = :facture.Commande_lie__r.Id];

		// TVA client
		hasTVACustomer = facture.Numero_de_TVA__c != null && facture.Numero_de_TVA__c.length() >0;

		// Traduction du nom de l'etat et du pays
		Country = HelperQuote.getEnNameForCountryCode(facture.BillingCountryCode__c);
		if (facture.BillingState__c != null) State = HelperQuote.getEnTranslationForState(facture.BillingCountryCode__c, facture.BillingState__c);

		// Code Pays pour le format de lettre
		CountryCode = facture.Commande_Lie__r.BillingCountryCode;
	}

}