@isTest
public class FactureSendEmailExtensionTest_L {

	@IsTest(SeeAllData=true) // Pour tester que les templates d'email utilisés sont présents dans l'org
	public static void test() {

		Account account = new Account(Name = 'test');
		insert account;
		Contact contact = new Contact(LastName = 'test', AccountId = account.id, email = 'test@addissoft.com');
		insert contact;
		Id orderId = HelperTestData.createOrderWithProductWithContact(contact);
		Facture__c facture = new Facture__c();
		facture.Commande_lie__c = orderId;
		insert facture;

		/***********/
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
		/************/

		Test.setCurrentPage(Page.FactureSendEmail_L);
		Test.startTest();
		FactureSendEmailExtension_L controller = new FactureSendEmailExtension_L(new ApexPages.StandardController(facture));
		controller.Preview();
		controller.Send();
		controller.Cancel();
		Test.stopTest();
	}
}