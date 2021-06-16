public class CL004_HelperDownloads {
    public static Telechargement__c createDownloadWithLeadId (DateTime dateDownload, String leadId) {

        Telechargement__c telechargement = new Telechargement__c (
            Date__c = dateDownload,
            Lead__c = leadId
        );        
        insert telechargement;
        
        return telechargement;
    }


    public static Telechargement__c createDownloadWithContactId (DateTime dateDownload, String contactId) {

        Telechargement__c telechargement = new Telechargement__c (
            Date__c    = dateDownload,                                                            
            Contact__c = contactId
        );        
        insert telechargement;
        
        return telechargement;
    }
}