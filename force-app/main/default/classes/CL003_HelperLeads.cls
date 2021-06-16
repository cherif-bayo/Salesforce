public with sharing class CL003_HelperLeads {

    //Create a lead SF object depending on the person attributes
    public static Lead createLead(Date dateDownload, String firstName, String lastName, 
                                  String email, String phone, String countryCode, String company,
                                  String locale, String domainCode, String position){
        Lead lead = new Lead();
   
        lead.firstName      = firstName.abbreviate(CL003_Constants.MAX_LENGTH_FIRST_NAME);
        lead.lastName       = lastName.abbreviate(CL003_Constants.MAX_LENGTH_LAST_NAME);
        lead.email          = email;
        lead.phone          = phone;
        lead.countryCode    = countryCode;  
        lead.position__c	= position;
        lead.company        = company == '' ? CL003_Constants.DEFAULT_COMPANY : company;        
        lead.langue__c      = CL003_Constants.phpLocaleToSFLocale.containsKey(locale)?CL003_Constants.phpLocaleToSFLocale.get(locale):locale;
        lead.domain__c      = CL003_Constants.domainCodeToDomain.containsKey(domainCode) ? CL003_Constants.domainCodeToDomain.get(domainCode) : '';
        lead.leadSource     = CL003_Constants.ORIGINE_DOWNLOAD;
        
        lead.Date_dernier_telechargement__c = dateDownload;
        lead.Date_premier_telechargement__c = dateDownload;
        
        insert lead;
                                      
        return lead;
    }

    //Create a lead SF object depending on the person attributes
    public static void updateLead (Lead lead, Date dateDownload, String firstName, String lastName, String domainCode){

        lead.firstName  = firstName.abbreviate(CL003_Constants.MAX_LENGTH_FIRST_NAME);
        lead.lastName   = lastName.abbreviate(CL003_Constants.MAX_LENGTH_LAST_NAME);                  
        lead.LeadSource = CL003_Constants.ORIGINE_DOWNLOAD;
        lead.Domain__c  = CL003_Constants.domainCodeToDomain.containsKey(domainCode) ? CL003_Constants.domainCodeToDomain.get(domainCode) : '';

        if (lead.Date_dernier_telechargement__c == null || lead.Date_dernier_telechargement__c < dateDownload)
            lead.Date_dernier_telechargement__c = dateDownload;

        if(lead.Date_premier_telechargement__c == null) 
            lead.Date_premier_telechargement__c = dateDownload;

        update lead;
    }
}