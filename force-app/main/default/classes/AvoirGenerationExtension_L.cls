public class AvoirGenerationExtension_L {
    public Avoir__c avoir { get; set; }

    public AvoirGenerationExtension_L(ApexPages.StandardController standardController) {
        avoir = [
                select Name, Commande_Lie__r.Contact_Lie__c, Commande_Lie__r.Contact_Lie__r.Langue__c,
                        Commande_Lie__r.Account.Langue__pc, commande_Lie__r.AddinsoftCompany__c
                from Avoir__c
                where Id = :standardController.getId()
                limit 1
        ];
    }

    public PageReference Generate() {
        boolean IsFr = avoir.Commande_Lie__r.Contact_Lie__c == null ? 'FR'.equalsIgnoreCase(avoir.Commande_Lie__r.Account.Langue__pc) : 'FR'.equalsIgnoreCase(avoir.Commande_Lie__r.Contact_Lie__r.Langue__c);
        System.debug('[AvoirGenerationExtension_L] AvoirGenerationExtension_L=' + IsFr);

        PageReference pgPDF;
        if (IsFr) {
            pgPDF = new PageReference('/apex/Avoir_fr?id=' + avoir.Id);
        } else if (ParametersForOrders.US_COMPANY.equals(avoir.commande_Lie__r.AddinsoftCompany__c)) {
            System.debug('passe US');
            pgPDF = new PageReference('/apex/Avoir_taxamo?id=' + avoir.Id);
        } else {
            pgPDF = new PageReference('/apex/Avoir_en?id=' + avoir.Id);
        }
        //Création du PDF de la facture sour forme de version d'un file
        ContentVersion v = new ContentVersion();
        if (Test.isRunningTest()) v.versionData = blob.valueOf('Unit.Test'); else v.versionData = pgPDF.getContent();
        v.title = 'Avoir n° ' + avoir.Name;
        v.PathOnClient = avoir.Name + '.pdf';
        v.ContentLocation = 'S';
        v.IsMajorVersion = true;
        insert v;

        // Recuperation du file généré à l'insertion de la version
        Id docId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :v.Id].ContentDocumentId;

        // Association du fichier PDF à l'object facture et au file
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = docId;
        cdl.LinkedEntityId = avoir.Id;
        cdl.ShareType = 'I';
        insert cdl;

        PageReference pgOut = new PageReference('/' + avoir.id);
        pgOut.setRedirect(true);
        return pgOut;
    }
}