/**
 * Class Extending License key and sending email to user without creating new key .
 */

public  without sharing class CL001_UTL_ExtendingKey {

    public static String TEMPLATE_NAME_PREFIX = 'Renewal Annual ';
    public static List<Flexera_Key__c> keys;

    public static void extend (Order order) {
        keys = [SELECT Name, Date_limite__c, Modules__c, Entitlement_Id__c,Contact__r.Email, Contact__r.FirstName, Contact__r.LastName,  Contact__r.Langue__c,Nb_activations_allowed__c  FROM Flexera_Key__c WHERE Order__c = :order.CustomOriginalOrder__c];
        for (Flexera_Key__c key :keys) {
            CryptlexFacade.renewingAnnualKey(key.Entitlement_Id__c);
            key.Order__c = order.Id;
            key.Date_limite__c = key.Date_limite__c.addYears(1);
        }
        order.Status = 'Payée';
        update order;
        if (keys.size() > 0) {
            sendEmailToCustomer(keys[0].Contact__r.Email, order.Id, keys[0].Contact__r.Langue__c);
        }

        System.debug('[CL001_UTL_ExtendingKey] keysToUpdate'+keys);
        update keys;
    }

    private static void sendEmailToCustomer(String recipient, String orderId, String langue) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        // Find Email template
        String emailTemplateName = TEMPLATE_NAME_PREFIX;
        if ('FR'.equals(langue)) emailTemplateName += 'FR';
        else emailTemplateName += 'EN';
        EmailTemplate emailTemplate = [SELECT Subject,HtmlValue FROM EmailTemplate WHERE Name = :emailTemplateName LIMIT 1];

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setReplyTo(System.Label.EmailReplySales);
        email.setToAddresses(new String[] { recipient });
        email.setWhatId(orderId);
        email.setSaveAsActivity(true);
        email.setSubject(emailTemplate.Subject);
        if(emailTemplateName.indexOf('FR') != -1){
            email.setSenderDisplayName('Equipe commerciale XLSTAT');
        }else{
            email.setSenderDisplayName('XLSTAT Sales Team');
        }

        // Merge Key names in email body
        String html = emailTemplate.HtmlValue;
        html = html.replace('{!LicenceKey}', getKeyNames());
        html = html.replace('{!Order.Contact_lie__c}', getKeyContactName());
        html = html.replace('{!LicenceModules}', getLicenceModules());
        html = html.replace('{!LicenceNbUsers}', getLicenceNbUsers());

        email.setHtmlBody(html);

        emails.add(email);
        Messaging.sendEmail(emails);
    }

    private static String getKeyNames() {
        String keyNames ='';
        for (Flexera_Key__c key :keys) {
            keyNames += key.Name +', ';
        }
        if (keyNames.length() > 1) {
            keyNames.substring(0, keyNames.length()-1);
        }
        return keyNames;
    }

    private static String getLicenceNbUsers() {
        String licenceNbUsers='';

        if (keys.size()>0) {
            licenceNbUsers = String.valueOf(keys[0].Nb_activations_allowed__c);
        }

        return licenceNbUsers;
    }

    private static String getLicenceModules() {
        String licenceModules='';

        for (Flexera_Key__c key :keys) {
            licenceModules += key.Modules__c +', ';
        }
        if (licenceModules.length() > 1) {
            licenceModules.substring(0, licenceModules.length()-1);
        }

        return licenceModules;
    }

    private static String getKeyContactName() {
        String keyContactName='';

        if (keys.size()>0) {
            keyContactName = keys[0].Contact__r.firstName + ' '+  keys[0].Contact__r.LastName;
        }

        return keyContactName;
    }
}