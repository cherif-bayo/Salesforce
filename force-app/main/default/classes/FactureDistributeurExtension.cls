public class FactureDistributeurExtension{

    private final Facture_Distributeur__c facture;
    
    public String State {get; set;}
    public String Country {get; set;}
    public String CountryCode {get; set;}
	public Boolean hasTVA { get; set; } // faut il afficher la tva	
	public Boolean hasTVACustomer { get; set; } // Le client a t il un nimo de TVA
	public List<String> addinsoftCompanyLines { get; set; } // Nom et adresse de la société	
	public List<String> bankAccountLines { get; set; } // Nom et domiciliation du compte bancaire	
    
    public FactureDistributeurExtension(ApexPages.StandardController stdController) {
		String factureId = stdController.getRecord().Id;
        facture = [SELECT CurrencyIsoCode, TVA__c, PeriodeEN__c, BillingCountry__c, BillingState__c, 
			Compte_Lie__r.BillingCountryCode, Compte_Lie__r.num_ro_de_TVA__c FROM Facture_Distributeur__c WHERE Id = :factureId limit 1];

		List<String> USBilledCountriesCode = System.Label.USBilledCountriesCode.split(';');
		boolean isUs = USBilledCountriesCode.contains(facture.Compte_Lie__r.BillingCountryCode); 

		// Lignes d'adresses de la société Addinsoft ou Addinsoft Inc.
		addinsoftCompanyLines = HelperQuote.getEnAddinsoftCompanyLines(isUs);

		// Gestion du compte bancaire à utiliser
		bankAccountLines = HelperQuote.getEnBankAccountLines(isUs,facture.BillingCountry__c,facture.CurrencyIsoCode);

		// Affichage des TVA 
		hasTVA = facture.TVA__c > 0;

		// TVA client
		hasTVACustomer = facture.Compte_Lie__r.Num_ro_de_TVA__c != null && facture.Compte_Lie__r.Num_ro_de_TVA__c.length() >0;

		// Traduction du nom de l'etat et du pays
		Country = HelperQuote.getEnNameForCountryCode(facture.BillingCountry__c);
		if (facture.BillingState__c != null) State = HelperQuote.getEnTranslationForState(facture.Compte_Lie__r.BillingCountryCode, facture.BillingState__c);

		// Code Pays pour le format de lettre
		CountryCode = facture.Compte_Lie__r.BillingCountryCode;
    }
}