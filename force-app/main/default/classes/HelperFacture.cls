public class HelperFacture {

	public static Facture__c createFactureFromOrder(Order order) {
		Facture__c facture = new Facture__c();
		facture.Commande_lie__c = order.Id;
		facture.Affichage_Nom_du_compte__c = 'Nom du compte seul';
		if (! 'fr'.equalsIgnoreCase(order.Account.BillingCountryCode)) facture.GenerateFactureEN__c = true;
		facture.PayedWithStripe__c = true;

		return facture;
	}

	public static Messaging.EmailFileAttachment getPDFFactureAttachmentFor(Facture__c facture) {

		// Choix du compte bancaire à référencer
		PageReference pgPDF;
		if (!facture.GenerateFactureEN__c) pgPDF = new PageReference('/apex/facture_fr?id=' + facture.Id);
			else pgPDF = new PageReference('/apex/facture_en?id=' + facture.Id);

		//Création du PDF de la facture sour forme de version d'un file
		ContentVersion v = new ContentVersion();
		if (Test.isRunningTest()) v.versionData = blob.valueOf('Unit.Test');
		else v.versionData = pgPDF.getContent();
		v.title = 'invoice-' + facture.Name + '.pdf';
		v.PathOnClient = 'invoice-' + facture.Name + '.pdf';
		v.ContentLocation = 'S';
		v.IsMajorVersion = true;
		insert v;

		// Recuperation du file généré à l'insertion de la version
		Id docId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :v.Id].ContentDocumentId;

		// Association du fichier PDF à l'object facture et au file
		ContentDocumentLink cdl = new ContentDocumentLink();
		cdl.ContentDocumentId = docId;
		cdl.LinkedEntityId = facture.Id;
		cdl.ShareType = 'I';
		insert cdl;

		// Creation d'une pience jointe avec le devis en PDF
		Blob b;
		if (Test.isRunningTest()) b = blob.valueOf('Unit.Test');
		else b = pgPDF.getContent();
		Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
		efa.setFileName('invoice.pdf');
		efa.setBody(b);

		return efa;
	}

}