public with sharing class CL004_SendEmail {

    // XLSTAT
    public static void sendEmailWithKey(Id contactOrLeadId, String countryCode) {
        EmailTemplate emt = getEmailTemplateForTrialKey(countryCode);
        System.debug('>>>> CL004_SendEmail - sendEmailWithKey XLSTAT - emt = '+emt);
        System.debug('>>>> CL004_SendEmail - sendEmailWithKey XLSTAT - contactOrLeadId = '+contactOrLeadId);
        if (emt != null) {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setOrgWideEmailAddressId(getEmailSenderForTrialKey());
            email.setTargetObjectId(contactOrLeadId);
            email.setTemplateId(emt.Id);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
        } else {
            throw new SendEmailException('Email template not found : contactOrLeadId='+contactOrLeadId+' - countryCode='+countryCode);
        }
    }

    private static EmailTemplate getEmailTemplateForTrialKey(String CountryCode) {
        String templateName = Parameters.getString('Trial_Template_DeveloperName');
        String languages = Parameters.getString('Trial_Email_Languages');
        String defaultLanguage = Parameters.getString('Trial_Email_Default_Language');

        String localisedTemplateName = templateName;
        if (languages.contains(CountryCode)) {
            localisedTemplateName += CountryCode;
        } else {
            localisedTemplateName += defaultLanguage;
        }
        System.debug('>>>> localisedTemplateName XLSTAT = '+localisedTemplateName);
        EmailTemplate emt;
        List<EmailTemplate> emts = [SELECT Id, Subject, Body, HtmlValue FROM EmailTemplate WHERE DeveloperName = :localisedTemplateName];
        if (emts.size() > 0) {
            emt = emts[0];
        }
        System.debug('email template :'+emt);
        return emt;
    }


    // GENERIC
    public static void sendEmailWithKey(Lead lead, String countryCode, String softwareCode) {
        EmailTemplate emt = getEmailTemplateForTrialKey(countryCode, softwareCode);
        System.debug('>>>> CL004_SendEmail - sendEmailWithKey XLRISK - emt = '+emt);
        if (emt != null) {
            if (emt.HtmlValue != null) {
                emt.HtmlValue = emt.HtmlValue.replace('{!Lead.FirstName}', lead.FirstName);
                emt.HtmlValue = emt.HtmlValue.replace('{!Lead.numoKey__c}', lead.numoKey__c);
            }
            if (emt.Body != null) {
                emt.Body = emt.Body.replace('{!Lead.FirstName}', lead.FirstName);
                emt.Body = emt.Body.replace('{!Lead.numoKey__c}', lead.numoKey__c);
            }
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setOrgWideEmailAddressId(getEmailSenderForTrialKey());
            email.setTargetObjectId(lead.Id);
            email.setTemplateId(emt.Id);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
        } else {
            throw new SendEmailException('Email template not found : lead='+lead+' - countryCode='+countryCode+' - softwareCode='+softwareCode);
        }
    }

    private static EmailTemplate getEmailTemplateForTrialKey(String CountryCode, String softwareCode) {
        String templateName = Parameters.getString('Trial_Template_DeveloperName'); 
        String languages = Parameters.getString('Trial_Email_Languages');
        String defaultLanguage = Parameters.getString('Trial_Email_Default_Language');
        String softwareName = new SoftwareService().getSoftwareNameFromCode(softwareCode);
        
        String localisedTemplateName = templateName;
        localisedTemplateName += softwareName.toUpperCase()+'_';
        if (languages.contains(CountryCode)) { localisedTemplateName += CountryCode; }
        else { localisedTemplateName += defaultLanguage; }
        System.debug('>>>> localisedTemplateName GENERIC = '+localisedTemplateName);
        EmailTemplate emt;
        List<EmailTemplate> emts = [SELECT Id, Subject, Body, HtmlValue FROM EmailTemplate WHERE DeveloperName = :localisedTemplateName];
        if (emts.size() > 0) {
            emt = emts[0];
            System.debug('email template :'+emt);
        } else {
            throw new SendEmailException('template '+localisedTemplateName+' not found');
        }
        return emt;
    }


    private static Id getEmailSenderForTrialKey() {
        String emailSender = Parameters.getString ('Trial_Email_Sender'); 
        OrgWideEmailAddress owa = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName = :emailSender];
        
        return owa.Id;
    }

    public class SendEmailException extends Exception {}
}