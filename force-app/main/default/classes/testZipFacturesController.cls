@isTest
public class testZipFacturesController {

	@testSetup
	static void method_dataSetup() {

		insert new ZipFactureQueryLimit__c(Name = 'limit', VALUE_LIMIT__c = 10);

		Account account = new Account(Name = 'test', BillingCountry = 'France');
		insert account;

		Contact contact = new Contact(LastName = 'test', AccountId = account.id, email = 'test@addissoft.com');
		insert contact;

		Id orderId = HelperTestData.createOrderWithProductWithContact(contact);

		Facture__c facture = new Facture__c();
		facture.Commande_lie__c = orderId;
		insert facture;

		// Creation d'une version de fichier
		ContentVersion v = new ContentVersion();
		v.versionData = blob.valueOf('Unit.Test');
		v.title = 'Facture n° ' + facture.Name;
		v.PathOnClient = facture.Name + '.pdf';
		v.ContentLocation = 'S';
		v.IsMajorVersion = true;
		insert v;
		System.debug('v :' + v);

		// Recuperation du file généré à l'insertion de la version
		Id docId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :v.Id].ContentDocumentId;
		System.debug('docId :' + docId);

		// Association du fichier PDF à l'object facture et au file
		ContentDocumentLink cdl = new ContentDocumentLink();
		cdl.ContentDocumentId = docId;
		cdl.LinkedEntityId = facture.Id;
		cdl.ShareType = 'V';
		insert cdl;
		System.debug('cdl :' + cdl);
	}

	public static testMethod void testMain() {
		PageReference pageRef = Page.zipAttachments;
		Test.setCurrentPage(pageRef);

		ZipFacturesController controller = new ZipFacturesController();
		controller.emptyOrder.EffectiveDate = Date.today().addDays(- 1);
		controller.emptyOrder.EndDate = Date.today().addDays(1);

		Test.startTest();
		controller.Show();
		controller.GetRenderPrevious();
		controller.GetRenderNext();
		controller.GetCurrentPage();
		controller.GetMaxPage();
		controller.uploadZip();
		controller.Next();
		controller.Previous();

		controller.testFiles();
		Test.stopTest();
	}
}