public class CL004_HelperLeads_v2 {
    
    //Create a lead SF object depending on the person attributes
    //The lead must not be inserted in database because it creates a save point
    //blocking the callout for creating the trial key
    public static Lead createLeadWithoutDML(Datetime dateDownload, String firstName, String lastName,
                                            String email, String phone, String countryCode, String company,
                                            String locale, String domainCode, String position, String source,
                                            Boolean HasOptedOutOfPhone, Boolean HasOptedOutOfEmail) {
                                                Lead lead = new Lead();
                                                lead.FirstName = firstName.abbreviate(CL003_Constants.MAX_LENGTH_FIRST_NAME);
                                                lead.LastName = lastName.abbreviate(CL003_Constants.MAX_LENGTH_LAST_NAME);
                                                lead.Email = email;
                                                lead.Phone = phone;
                                                lead.CountryCode = countryCode;
                                                lead.Position__c = position;
                                                lead.Company = company == '' ? CL003_Constants.DEFAULT_COMPANY : company;
                                                lead.Langue__c = CL003_Constants.phpLocaleToSFLocale.containsKey(locale) ? CL003_Constants.phpLocaleToSFLocale.get(locale) : locale;
                                                lead.Domain__c = CL003_Constants.domainCodeToDomain.containsKey(domainCode) ? CL003_Constants.domainCodeToDomain.get(domainCode) : '';
                                                lead.LeadSource = source != null ? source : CL003_Constants.ORIGINE_DOWNLOAD;
                                                lead.HasOptedOutOfEmail = HasOptedOutOfEmail; // champ standard non utilisé par Emma 
                                                lead.No_mailling__c = HasOptedOutOfEmail; // champ non standard utilisé par Emma 
                                                lead.HasOptedOutOfPhone__c = HasOptedOutOfPhone;
                                                lead.Date_dernier_telechargement__c = dateDownload;
                                                lead.Date_premier_telechargement__c = dateDownload;
                                                
                                                return lead;
                                            }
    
    //Create a lead SF object depending on the person attributes
    public static void updateLeadWithoutDML(Lead lead, Datetime dateDownload, String firstName, String lastName, String domainCode,
                                            String source, Boolean HasOptedOutOfPhone, Boolean HasOptedOutOfEmail) {

                                                lead.FirstName = firstName.abbreviate(CL003_Constants.MAX_LENGTH_FIRST_NAME);
                                                lead.LastName = lastName.abbreviate(CL003_Constants.MAX_LENGTH_LAST_NAME);
                                                lead.LeadSource = CL003_Constants.ORIGINE_DOWNLOAD;
                                                lead.LeadSource = source != null ? source : CL003_Constants.ORIGINE_DOWNLOAD;
                                                lead.HasOptedOutOfEmail = HasOptedOutOfEmail; // champ standard non utilisé par Emma
                                                lead.No_mailling__c = HasOptedOutOfEmail; // champ non standard utilisé par Emma
                                                lead.HasOptedOutOfPhone__c = HasOptedOutOfPhone;
                                                lead.Domain__c = CL003_Constants.domainCodeToDomain.containsKey(domainCode) ? CL003_Constants.domainCodeToDomain.get(domainCode) : '';

                                                if (lead.Date_dernier_telechargement__c == null || lead.Date_dernier_telechargement__c<dateDownload)
                                                    lead.Date_dernier_telechargement__c = dateDownload;

                                                if (lead.Date_premier_telechargement__c == null)
                                                    lead.Date_premier_telechargement__c = dateDownload;
                                            }
    
    public static String createTrialKeyAndSendEmail(Lead lead, String countryCode) {
        Flexera_Key__c key;
        key = CL004_TrialKeyGeneration.GenerateTrialKeyInFlexera();
        System.debug('>>>> CL004_HelperLead - createTrialKeyAndSendEmail - Flexera_Key__c key = '+key);
        if (key != null) {
            key.isInStock__c = false;
            lead.numoKey__c = key.Name;
            if (lead.Id == null) {
                insert lead;
            } else {
                update lead;
            }
            try {
                CL004_SendEmail.sendEmailWithKey(lead.Id, countryCode);
                key.Lead__c = lead.Id;
                if (key.Id == null) {
                    insert key;
                } else {
                    update key;
                }
            } catch (Exception e) {
                System.debug('createTrialKeyAndSendEmail - Exception :'+e.getMessage());
            }
            return key.Name;
        }
        return '';
    }

    public static void sendEmailWithoutKey(String LeadId, String langue, String email) {

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        // Strings to hold the email addresses to which you are sending the email.
        String[] toAddresses = new String[] {email};
        

        // Assign the addresses for the To and CC lists to the mail object.
        mail.setToAddresses(toAddresses);

        OrgWideEmailAddress[] orgwideaddress = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName ='Jessica Bruno'];

        mail.setOrgWideEmailAddressId(orgwideaddress[0].Id);

        // Specify the address used when the recipients reply to the email.
        mail.setReplyTo('support@xlstat.com');

        // Specify the name used as the display name.
        //mail.setSenderDisplayName('The XLSTAT Team');

        mail.setTemplateId(getTemplate(langue).Id);
        mail.setTargetObjectId(LeadId);

        // Send the email you have created.
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
    public static void sendEmailWithoutKey(String LeadId, String langue, String email, String softwareCode) {
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        // Strings to hold the email addresses to which you are sending the email.
        String[] toAddresses = new String[] {email};
        
        // Assign the addresses for the To and CC lists to the mail object.
        mail.setToAddresses(toAddresses);
        
        OrgWideEmailAddress[] orgwideaddress = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName ='Jessica Bruno'];
         
        mail.setOrgWideEmailAddressId(orgwideaddress[0].Id);
        
        // Specify the address used when the recipients reply to the email. 
        mail.setReplyTo('support@xlstat.com');
        
        // Specify the name used as the display name.
        //mail.setSenderDisplayName('The XLSTAT Team');

        if (String.isNotBlank(softwareCode)) {
            mail.setTemplateId(getTemplate(langue, softwareCode).Id);
        } else {
            mail.setTemplateId(getTemplate(langue).Id);
        }

        mail.setTargetObjectId(LeadId);
            
        // Send the email you have created.
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
    private static EmailTemplate getTemplate(String locale) {
        String emailTemplateName;

        if(locale == 'fr'){
            emailTemplateName = 'REFUS_TRIAL_FR';
        } else {
            emailTemplateName = 'REFUS_TRIAL_EN';
        }

        EmailTemplate emailTemplate = [SELECT Id, Subject, Body FROM EmailTemplate WHERE Name = :emailTemplateName];
        return emailTemplate;
    }

    private static EmailTemplate getTemplate(String locale, String softwareCode) {
        String emailTemplateName;
        String softwareName = new SoftwareService().getSoftwareNameFromCode(softwareCode);

        if(locale == 'fr'){
            emailTemplateName = 'REFUS_TRIAL_FR';
        } else {
            emailTemplateName = 'REFUS_TRIAL_EN';
        }
        emailTemplateName += '_'+softwareName;

        EmailTemplate emailTemplate = [SELECT Id, Subject, Body FROM EmailTemplate WHERE Name = :emailTemplateName];
        return emailTemplate;
    }
}