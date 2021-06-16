public class CL004_HelperContacts {

    public static void updateContactWithDateDownload (Contact contact, DateTime dateDownload) {

        contact.LeadSource = CL003_Constants.ORIGINE_DOWNLOAD;              
  
        if(contact.Piste_date_dernier_t_l_chargement__c == null || contact.Piste_date_dernier_t_l_chargement__c < dateDownload)
            contact.Piste_date_dernier_t_l_chargement__c = dateDownload;

        if(contact.Piste_premier_telechargement__c == null)
            contact.Piste_premier_telechargement__c = dateDownload;    

        update Contact;    
    }
    
}