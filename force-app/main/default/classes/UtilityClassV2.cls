/**
 * Created by RCOR on 10/11/2020.
 */

public with sharing class UtilityClassV2 {

    private List<EmailMessageWrapper> listEmailMessageWrapper;
    private String emailTemplateName;
    private Id whatId;

    public String HtmlBody {get; set;}


    public UtilityClassV2(List<EmailMessageWrapper> listEmailMessageWrapper, String emailTemplateName, Id whatId){
        this.emailTemplateName = emailTemplateName;
        this.listEmailMessageWrapper = listEmailMessageWrapper;
        this.whatId = whatId;

        System.debug('UtilityClass - emailTemplateName = '+emailTemplateName);
        for (EmailMessageWrapper emailMessageWrapper : listEmailMessageWrapper) {
            if (Test.isRunningTest()) {}
            else {
                EmailTemplate emailTemplate = [SELECT Id, Subject, HtmlValue, Body FROM EmailTemplate WHERE Name = :emailTemplateName];
                System.debug('UtilityClass - EmailTemplate emailTemplate = '+emailTemplate);
                this.HtmlBody = emailTemplate.HtmlValue;
                if(this.HtmlBody != null){
                    for (String key : emailMessageWrapper.ParameterBodyMap.keySet()) {
                        this.HtmlBody = HtmlBody.replace(key, (emailMessageWrapper.ParameterBodyMap.get(key) == null) ? '' : emailMessageWrapper.ParameterBodyMap.get(key));
                    }
                }
            }
        }
    }

    public List<Messaging.SendEmailResult> sendEmail(List<EmailMessageWrapper> listEMW) {
        if(listEMW != null){
            this.listEmailMessageWrapper = listEMW;
        }
        List<Messaging.SingleEmailMessage> listSingleEmailMessages = new List<Messaging.SingleEmailMessage>();
        EmailTemplate emailTemplate = [SELECT Id, Subject, HtmlValue, Body FROM EmailTemplate WHERE Name = :emailTemplateName];
        System.debug('UtilityClass - Send - EmailTemplate emailTemplate = '+emailTemplate);
        for (EmailMessageWrapper emailMessageWrapper : listEmailMessageWrapper) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            if(emailMessageWrapper.FromAddress != null && emailMessageWrapper.FromAddress.length() > 0)
                mail.setReplyTo(emailMessageWrapper.FromAddress);
            if(emailMessageWrapper.ToAddress != null && emailMessageWrapper.ToAddress.length() > 0)
                mail.setToAddresses(new String[] { emailMessageWrapper.ToAddress });
            else
                    mail.setTargetObjectId(emailMessageWrapper.ToAddressId);
            if(emailMessageWrapper.BccAddress != null && emailMessageWrapper.BccAddress.length() > 0)
                mail.setBccAddresses(new String[] {emailMessageWrapper.BccAddress });
            String subject = null;
            if(emailMessageWrapper.Subject != null && emailMessageWrapper.Subject.length() > 0) {
                mail.setSubject(emailMessageWrapper.Subject);
                subject = emailMessageWrapper.Subject;
            }
            else
                    subject = emailTemplate.Subject;

            for(String key: emailMessageWrapper.ParameterSubjectMap.keySet())
                subject = subject.replace(key, (emailMessageWrapper.ParameterSubjectMap.get(key) == null ? '' : emailMessageWrapper.ParameterSubjectMap.get(key)));

            mail.setSubject(subject);
            this.HtmlBody = emailTemplate.HtmlValue;
            String plainBody = emailTemplate.Body;
            for (String key : emailMessageWrapper.ParameterBodyMap.keySet()) {
                if(this.HtmlBody != null){
                    this.HtmlBody = HtmlBody.replace(key, (emailMessageWrapper.ParameterBodyMap.get(key) == null) ? '' : emailMessageWrapper.ParameterBodyMap.get(key));
                }
                plainBody = plainBody.replace(key, (emailMessageWrapper.ParameterBodyMap.get(key) == null) ? '' : emailMessageWrapper.ParameterBodyMap.get(key));
            }

            if(this.HtmlBody != null){
                mail.setHtmlBody(HtmlBody);
            }
            mail.setSaveAsActivity(true);
            mail.setPlainTextBody(plainBody);

            if(emailMessageWrapper.EmailAttachments != null){
                mail.setFileAttachments(emailMessageWrapper.EmailAttachments);
            }

            if(emailTemplateName.indexOf('FR') != -1){
                mail.setSenderDisplayName('Equipe commerciale XLSTAT');
            }else{
                mail.setSenderDisplayName('XLSTAT Sales Team');
            }
            System.debug('>>>> UtilityClass - whatId = '+whatId);
            mail.setWhatId(whatId);
            System.debug('>>>> UtilityClass - SingleEmailMessage mail = '+mail);
            listSingleEmailMessages.add(mail);
        }
        List<Messaging.SendEmailResult> listEmailResult = null;
        listEmailResult = Messaging.sendEmail(listSingleEmailMessages);
        System.debug('>>>> UtilityClass - listEmailResult = '+listEmailResult);
        return listEmailResult;
    }
}