/**
 * Created by RCOR on 21/10/2020.
 */

public without sharing class SendFlexeraKeyEmailGenericProduct {

    private static String COUNTRY_FRANCE = 'FR';
    private static String LANGUAGE_FRANCE = 'FR';
    private static String LANGUAGE_OTHER = 'EN';

    private static String EMAIL_SENDER = 'XLSTAT Sales team';
    private static String TEMPLATE_PREFIX = 'ORDER_OK_';
    private static String TEMPLATE_SUFFIX = '_GENERIC';

    public Flexera_Key__c flexeraKey;
    public Order order { get; set; }
    public List<Contact> contact { get; set; }

    private Boolean isUpdate;


    public SendFlexeraKeyEmailGenericProduct(Boolean isUpdate, Flexera_Key__c flexeraKey, Order order) {
        this.isUpdate = isUpdate;
        this.flexeraKey = flexeraKey;
        this.order = order;
    }

    public Boolean Send() {
        System.debug('>>>> SendFlexeraKeyEmailGenericProduct - Send() - flexeraKey = '+flexeraKey);
        OrgWideEmailAddress owea = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName = :EMAIL_SENDER LIMIT 1];
        Contact contact = [SELECT Langue__c, FirstName, LastName, Email FROM Contact WHERE Id = :flexeraKey.Contact__c LIMIT 1];
        String countryCode = contact.Langue__c == COUNTRY_FRANCE ? LANGUAGE_FRANCE : LANGUAGE_OTHER;
        String solution = flexeraKey.XLSTAT_Solution__c.toUpperCase();
        String templateName = TEMPLATE_PREFIX+countryCode+TEMPLATE_SUFFIX+'_'+solution;
        EmailTemplate emailTemplate = [SELECT Id, Subject, Body, HtmlValue FROM EmailTemplate WHERE DeveloperName = :templateName LIMIT 1];
        List<Messaging.SingleEmailMessage> mailsToSend = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setOrgWideEmailAddressId(owea.Id);
        email.setTargetObjectId(this.flexeraKey.Contact__c);
        email.setTemplateId(emailTemplate.Id);
        email.setWhatId(this.flexeraKey.Id);
        email.setCcAddresses(new List<String>{'sales@xlstat.com'});
        email.setBccAddresses(new List<String>{'sales@xlstat.com'});
        //email.setCcAddresses(new List<String>{'cbayo@xlstat.com'});
        //email.setBccAddresses(new List<String>{'cbayo@xlstat.com'});
        email.setBccSender(true);
        mailsToSend.add(email);
        List<Messaging.SendEmailResult> results = Messaging.sendEmail(mailsToSend);
        Boolean isSuccessfull = true;
        for (Messaging.SendEmailResult result : results) {
            if (result.isSuccess() == false) {
                System.debug('>>>> ORDER - Send Email Failure : '+result.getErrors());
                return false;
            }
        }
        // @TODO: createCustomEmail
        String EmailDelivery = System.Label.KeyDelivery;
        Email__c customEmail = new Email__c();
        customEmail.Address__c = contact.Email;
        customEmail.Contact__c = contact.Id;
        customEmail.Type__c = EmailDelivery;
        customEmail.Nalpeiron_Key__c = this.flexeraKey.Name;
        customEmail.Order__c = this.order.Id;
        customEmail.Subject__c = flexeraKey.XLSTAT_Solution__c.toUpperCase();
        insert customEmail;

        return isSuccessfull;
    }


}