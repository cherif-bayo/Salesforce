@isTest
public class FactureDistribSendEmailExtensionTest_L {

	@isTest
	public static void testMain() {
		Account acc = new Account(Name = 'test', type = 'Distributeur');
		insert acc;

		Contact ct1 = new Contact(LastName = 'test1', accountId = acc.Id, email = 'test@test.fr');
		insert ct1;

		Contact ct2 = new Contact(LastName = 'test2', accountId = acc.Id, email = 'test2@test.fr');
		insert ct2;

		Facture_Distributeur__c facture = new Facture_Distributeur__c(Compte_lie__c = acc.Id);
		insert facture;

		ContentVersion v = new ContentVersion();
		v.versionData = blob.valueOf('Unit.Test');
		v.title = 'Facture n° ' + facture.Name;
		v.PathOnClient = facture.Name + '.pdf';
		v.ContentLocation = 'S';
		v.IsMajorVersion = true;
		insert v;

		Id docId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :v.Id].ContentDocumentId;

		ContentDocumentLink cdl = new ContentDocumentLink();
		cdl.ContentDocumentId = docId;
		cdl.LinkedEntityId = facture.Id;
		cdl.ShareType = 'I';
		insert cdl;
		List<String> accountIds = new List<String> ();
		for (Account account :[SELECT Id FROM Account WHERE type = 'Distributeur']) {
			accountIds.add(account.Id);
		}

		facture = [SELECT Id, GenerateFactureEN__c FROM Facture_Distributeur__c WHERE Compte_Lie__c IN :accountIds limit 1];

		ApexPages.StandardController sc = new ApexPages.standardController(facture);
		FactureDistributeurSendEmailExtension_L ext = new FactureDistributeurSendEmailExtension_L(sc);
		ext.email = 'lbeaubier@xlstat.com';
		ext.Send();

		facture.GenerateFactureEN__c = !facture.GenerateFactureEN__c;
		update facture;

		sc = new ApexPages.standardController(facture);
		ext = new FactureDistributeurSendEmailExtension_L(sc);
		ext.email = 'lbeaubier@xlstat.com';
		ext.Send();
	}
}