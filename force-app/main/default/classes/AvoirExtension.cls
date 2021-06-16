public class AvoirExtension {

	public final Avoir__c Avoir { get; private set; }

	public OrderItem[] orderItems { get; set; }
	public Id OrderId { get; set; }
	public String State { get; set; }
	public String Country { get; set; }
	public String CountryCode { get; set; }
	public Boolean IsFr { get; private set; }
	public List<String> addinsoftCompanyLines { get; set; } // Nom et adresse de la société	
	public Boolean hasTVA { get; private set; }

	public AvoirExtension(ApexPages.StandardController stdController) {

		Avoir = [SELECT Commande_lie__r.Id, Facture_liee__r.Commande_lie__r.TotalAmountAfterDiscountWithCurrency__c,Facture_liee__r.TVA__c,
			Facture_liee__r.AmountTVAWithCurrency__c, Facture_liee__r.Name,Facture_liee__r.FR_Invoice_Code__c,Facture_liee__r.US_Invoice_Code__c,
			Facture_liee__r.TotalAmountAfterTVAWithCurrency__c,Facture_liee__r.Date__c,AddinSoftCompany__c,
	        Montant_With_Currency__c, Montant__c, Libelle__c, Commande_Lie__r.Account.Num_ro_de_TVA__c, CreatedDate, Name, Commande_Lie__r.BillingPostalCode,
			Commande_Lie__r.BillingCity, Commande_Lie__r.BillingStreet, ContactName__c, AccountName__c, Commande_Lie__r.R_f_Bon_de_commande__c,
			Commande_Lie__r.Contact_Lie__c, Commande_Lie__r.Account.Langue__pc, Commande_Lie__r.Contact_Lie__r.Langue__c,
			Commande_Lie__r.BillingStateCode, Commande_Lie__r.BillingState, Commande_Lie__r.BillingCountryCode, Commande_Lie__r.BillingCountry,
			Commande_lie__r.TaxamoAmount__c,Commande_lie__r.TaxamoTaxeAmount__c,Commande_lie__r.TaxamoTotalAmount__c, US_Credit_Code__c, FR_Credit_Code__c
		FROM Avoir__c WHERE Id = :stdController.getId() limit 1];

		System.debug(Avoir.AddinSoftCompany__c);
		boolean isUs = ParametersForOrders.US_COMPANY.equalsIgnoreCase(Avoir.AddinSoftCompany__c);
		
		System.debug(isUs);
		addinsoftCompanyLines = HelperQuote.getEnAddinsoftCompanyLines(isUs);

		System.debug(addinsoftCompanyLines);

		hasTVA = Avoir.Facture_liee__r.TVA__c > 0;

		IsFr = Avoir.Commande_Lie__r.Contact_Lie__c == null ? Avoir.Commande_Lie__r.Account.Langue__pc == 'FR' : Avoir.Commande_Lie__r.Contact_Lie__r.Langue__c == 'FR';

		orderItems = [Select PricebookEntry.Product2.Domaine_utilisateur_en__c, PricebookEntry.Product2.Domaine_utilisateur_Facture__c, PricebookEntry.Product2.name, PricebookEntry.Product2.Libelle_Devis__c, PricebookEntry.Product2.Type_licence_desc_en__c, PricebookEntry.Product2.Type_licence_desc__c,
		              UnitPriceWithCurrency__c, quantity, TotalPriceAfterDiscountWithCurrency__c, TotalPriceWithCurrency__c, Percent_Discount_Facture__c,
					  TaxamoTaxeRate__c, TaxamoAmount__c, TaxamoTaxeAmount__c,TaxamoTotalAmount__c From OrderItem where OrderId = :Avoir.Commande_lie__r.Id];

		if (IsFr) {
			State = Avoir.Commande_Lie__r.BillingState;
			Country = Avoir.Commande_Lie__r.BillingCountry;
		} else {
			Country = HelperQuote.getEnNameForCountryCode(Avoir.Commande_Lie__r.BillingCountryCode);
			if (Avoir.Commande_Lie__r.BillingStateCode != null) State = HelperQuote.getEnTranslationForState(Avoir.Commande_Lie__r.BillingCountryCode, Avoir.Commande_Lie__r.BillingStateCode);
		}
		CountryCode = Avoir.Commande_Lie__r.BillingCountryCode;
	}
}