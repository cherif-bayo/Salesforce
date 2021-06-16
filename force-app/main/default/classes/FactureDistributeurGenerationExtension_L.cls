public class FactureDistributeurGenerationExtension_L {

	public Facture_distributeur__c Facture { get; set; }

	public FactureDistributeurGenerationExtension_L(ApexPages.StandardController standardController) {
		Facture = [select Id, Name from Facture_distributeur__c where Id = :standardController.getId() limit 1];
	}

	public PageReference Generate() {
		PageReference pgPDF = new PageReference('/apex/factureDistributeur?id=' + facture.Id);

		//Création du PDF de la facture sour forme de version d'un file
		ContentVersion v = new ContentVersion();
		if (Test.isRunningTest()) v.versionData = blob.valueOf('Unit.Test');
		else v.versionData = pgPDF.getContent();
		v.title = 'Facture Distributeur n° ' + facture.Name;
		v.PathOnClient = facture.Name + '.pdf';
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