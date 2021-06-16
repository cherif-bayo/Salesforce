public class FactureGenerationExtension_L {
	public Facture__c facture { get; set; }

	public FactureGenerationExtension_L(ApexPages.StandardController standardController) {
		facture = [select Name, US_Invoice_Code__c, FR_Invoice_Code__c, commande_Lie__r.AddinsoftCompany__c,GenerateFactureEN__c from Facture__c where Id = :standardController.getId() limit 1];
	}

	public PageReference Generate() {
		// Choix du compte bancaire à référencer
		String invoiceTitle;

		PageReference pgPDF;
		if (ParametersForOrders.US_COMPANY.equals(facture.commande_Lie__r.AddinsoftCompany__c)) {
			invoiceTitle = 'Invoice ' + facture.US_Invoice_Code__c;
			pgPDF = new PageReference('/apex/facture_taxamo?id=' + facture.Id);
		}
		else {
			invoiceTitle = 'Facture ' + facture.FR_Invoice_Code__c;
			if (!facture.GenerateFactureEN__c) pgPDF = new PageReference('/apex/facture_fr?id=' + facture.Id);
			else pgPDF = new PageReference('/apex/facture_en?id=' + facture.Id);
		}

		//Création du PDF de la facture sour forme de version d'un file
		ContentVersion v = new ContentVersion();
		if (Test.isRunningTest()) v.versionData = blob.valueOf('Unit.Test');
		else v.versionData = pgPDF.getContent();
		v.title = invoiceTitle;
		v.PathOnClient = invoiceTitle.replaceAll(' ','-') + '.pdf';
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

		PageReference pgOut = new PageReference('/' + facture.id);
		pgOut.setRedirect(true);
		return pgOut;
	}
}