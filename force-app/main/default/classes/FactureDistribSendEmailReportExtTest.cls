@isTest
public class FactureDistribSendEmailReportExtTest {

	@testSetup
	public static void setUp() {
		Account acc = new Account(Name = 'test', Billingcountry = 'France', Type = 'Distributeur');
		insert acc;

		Contact ct = new Contact(LastName = 'test', Email = 'test@test.fr', accountId = acc.Id);
		insert ct;

		HelperTestData.createOrderWithProductWithContact(ct);

		Facture_Distributeur__c facture = new Facture_Distributeur__c(Compte_Lie__c = acc.Id,
		                                                              Montant_commandes_selectionnees__c = 100,
		                                                              CurrencyIsoCode = 'EUR',
																	  Montant_libre__c = 100,
																	  Deduction__c = 10);
		insert facture;

		Order o = [Select Id from Order];
		o.Ref_Facture_distributeur__c = facture.Id;
		o.TotalAmountAfterDiscountEUR__c = 100;
		update o;
	}


	@isTest
	public static void testMain() {
		List<String> accountIds = new List<String> ();
		for (Account account :[SELECT Id FROM Account WHERE Type = 'Distributeur']) {
			accountIds.add(account.Id);
		}

		Facture_Distributeur__c facture = [SELECT Id, GenerateFactureEN__c, Montant_libre__c, Deduction__c FROM Facture_Distributeur__c limit 1];

		if (facture.Montant_libre__c == 0) {
			facture.Montant_libre__c = 100;
		}
		if (facture.Deduction__c == 0) {
			facture.Deduction__c = 250;
		}
		update facture;

		ApexPages.StandardController sc = new ApexPages.standardController(facture);
		FactureDistribSendEmailReportExtension ext = new FactureDistribSendEmailReportExtension(sc);
		ext.Email = ext.Emails[0].getValue();
		ext.Send();

		facture.GenerateFactureEN__c = !facture.GenerateFactureEN__c;
		update facture;

		sc = new ApexPages.standardController(facture);
		ext = new FactureDistribSendEmailReportExtension(sc);
		ext.Email = ext.Emails[0].getValue();
		ext.Send();
	}
}