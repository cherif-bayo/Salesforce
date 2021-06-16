public class FactureExtensionFr {
	private final Facture__c facture;
	public OrderItem[] orderItems { get; set; }

	public Boolean hasTVA { get; set; } // faut il afficher la tva sur le devis
	public Boolean hasTVACustomer { get; set; } // Le client a t il un nimo de TVA
	public List<String> bankAccountLines { get; set; } // Nom et domiciliation du compte bancaire	

	public FactureExtensionFr(ApexPages.StandardController stdController) {
		if (!Test.isRunningTest()) stdController.addFields(new List<String> {'FR_Invoice_Code__c','PayedWithStripe__c','BillingState__c','Numero_de_TVA__c','BillingCountry__c','AddinSoftCompany2__c','Commande_lie__r.HasDiscount__c','Commande_Lie__r.BillingCountryCode','Commande_lie__r.CurrencyIsoCode'});
		facture = (Facture__c) stdController.getRecord();

		orderItems = [Select PricebookEntry.Product2.Domaine_utilisateur__c, PricebookEntry.Product2.Domaine_utilisateur_en__c, PricebookEntry.Product2.Type_licence__c, PricebookEntry.Product2.Domaine_utilisateur_Facture__c, PricebookEntry.Product2.Libelle_Devis__c, PricebookEntry.Product2.name, PricebookEntry.Product2.Type_licence_desc_en__c, PricebookEntry.Product2.Type_licence_desc__c,
		              UnitPriceWithCurrency__c, quantity, TotalPriceAfterDiscountWithCurrency__c, TotalPriceWithCurrency__c, Percent_Discount_Facture__c From OrderItem where OrderId = :facture.Commande_lie__r.Id];

		// Gestion du compte bancaire
		bankAccountLines = HelperQuote.getFrBankAccountLines(facture.BillingCountry__c, facture.Commande_lie__r.CurrencyIsoCode);

		// Affichage des TVA 
		hasTVA = facture.TVA__c > 0;

		// TVA client
		hasTVACustomer = ''.equalsIgnoreCase(facture.Numero_de_TVA__c);
	}
}