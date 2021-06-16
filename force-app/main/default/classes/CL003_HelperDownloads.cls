public with sharing class CL003_HelperDownloads {

    public static Telechargement__c createDownloadWithLeadId (Date dateDownload, String leadId) {

        Telechargement__c telechargement = new Telechargement__c (
            Date__c = dateDownload,
            Lead__c = leadId
        );
        
        insert telechargement;
        
        return telechargement;
    }


    public static Telechargement__c createDownloadWithContactId (Date dateDownload, String contactId) {

        Telechargement__c telechargement = new Telechargement__c (
            Date__c    = dateDownload,                                                            
            Contact__c = contactId
        );
        
        insert telechargement;
        
        return telechargement;
    }
}