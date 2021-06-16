public class FactureExtensionEn {
	private final Facture__c facture;
	public OrderItem[] orderItems { get; set; }

	public String State { get; set; } // Nom de l'Etat traduit
	public String Country { get; set; } // Nom de Pays traduit
	public String CountryCode { get; set; } // Code Pays pour le format de page
	public Boolean hasTVA { get; set; } // faut il afficher la tva	
	public Boolean hasTVACustomer { get; set; } // Le client a t il un nimo de TVA
	public List<String> addinsoftCompanyLines { get; set; } // Nom et adresse de la société	
	public List<String> bankAccountLines { get; set; } // Nom et domiciliation du compte bancaire	

	public FactureExtensionEn(ApexPages.StandardController stdController) {
		if (!Test.isRunningTest()) stdController.addFields(new List<String> {'FR_Invoice_Code__c','BillingCountryCode__c','PayedWithStripe__c','BillingState__c','Numero_de_TVA__c','BillingCountry__c','AddinSoftCompany2__c','Commande_lie__r.HasDiscount__c','Commande_Lie__r.BillingCountryCode','Commande_lie__r.CurrencyIsoCode'});
		facture = (Facture__c) stdController.getRecord();

		orderItems = [Select PricebookEntry.Product2.Domaine_utilisateur_en__c, PricebookEntry.Product2.Type_licence__c, PricebookEntry.Product2.Domaine_utilisateur_Facture__c, PricebookEntry.Product2.name, PricebookEntry.Product2.Libelle_Devis__c, PricebookEntry.Product2.Type_licence_desc_en__c, PricebookEntry.Product2.Type_licence_desc__c,
		              UnitPriceWithCurrency__c, quantity, TotalPriceAfterDiscountWithCurrency__c, TotalPriceWithCurrency__c, Percent_Discount_Facture__c From OrderItem where OrderId = :facture.Commande_lie__r.Id];

		boolean isUs = ParametersForOrders.US_COMPANY.equalsIgnoreCase(facture.AddinSoftCompany2__c);

		// Lignes d'adresses de la société Addinsoft ou Addinsoft Inc.
		addinsoftCompanyLines = HelperQuote.getEnAddinsoftCompanyLines(isUs);

		// Gestion du compte bancaire à utiliser
		bankAccountLines = HelperQuote.getEnBankAccountLines(isUs,facture.BillingCountry__c,facture.Commande_lie__r.CurrencyIsoCode);

		// Affichage des TVA 
		hasTVA = facture.TVA__c > 0;

		// TVA client
		hasTVACustomer = facture.Numero_de_TVA__c != null && facture.Numero_de_TVA__c.length() >0;

		// Traduction du nom de l'etat et du pays
		Country = HelperQuote.getEnNameForCountryCode(facture.BillingCountryCode__c);
		if (quote.BillingStateCode != null) State = HelperQuote.getEnTranslationForState(facture.BillingCountryCode__c, facture.BillingState__c);

		// Code Pays pour le format de lettre
		CountryCode = facture.Commande_Lie__r.BillingCountryCode;
	}
}