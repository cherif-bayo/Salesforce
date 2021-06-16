public class CL004_HelperDownloads_v2 {
    public static Telechargement__c createDownloadWithLeadId (DateTime dateDownload, String osDownload, String leadId) {

        Telechargement__c telechargement = new Telechargement__c (
            Date__c 		= dateDownload,
            Lead__c 		= leadId,
            osDownload__c 	= osDownload
        );        
        insert telechargement;
        System.debug('>>>> CL004_HelperDowloads_v2 - createDownloadWithLeadId - telechargeletn = '+telechargement);
        return telechargement;
    }


    public static Telechargement__c createDownloadWithContactId (DateTime dateDownload, String osDownload, String contactId) {

        Telechargement__c telechargement = new Telechargement__c (
            Date__c    		= dateDownload,                                                            
            Contact__c 		= contactId,
            osDownload__c 	= osDownload
        );        
        insert telechargement;
        System.debug('>>>> CL004_HelperDowloads_v2 - createDownloadWithContactId - telechargeletn = '+telechargement);
        return telechargement;
    }
}