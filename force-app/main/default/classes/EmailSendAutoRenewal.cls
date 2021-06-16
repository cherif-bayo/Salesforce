public class EmailSendAutoRenewal{
    public static void Send(String contactId, String orderId){
        Contact[] contacts = [SELECT Id, Langue__c, Name, Email FROM Contact WHERE Id = :contactId];
        
        if(contacts.size() > 0){
            Contact contact = contacts[0];
        
            List<EmailMessageWrapper> listEmailMessageWrapper = new List<EmailMessageWrapper>();
                    
            Map<String, String> mapSubjectParams = new Map<String, String> {};
        
            Map<String, String> mapBodyParams = new Map<String, String> {
                '{!ContactName}' => contact.Name
            };
            
            Boolean isFr = contact.Langue__c == 'FR';
        
            String subject = isFr ? 'XLSTAT - Renouvellement automatique' : 'XLSTAT - Automatic renewal';
            
            listEmailMessageWrapper.add(new EmailMessageWrapper('sales@xlstat.com', contact.Email, null, null, subject, mapSubjectParams, null, mapBodyParams));
            
            String templateName = isFr ? 'Mail Autorenwal FR' : 'Mail Autorenwal US';
            UtilityClassV2 utilityClass = new UtilityClassV2(listEmailMessageWrapper, templateName, orderId);
            
            List<Email__c> emailsToInsert = new List<Email__c>();
            List<Messaging.SendEmailResult> results = utilityClass.sendEmail(listEmailMessageWrapper);
            
            for(Integer i = 0; i < results.size(); i++){
                Messaging.SendEmailResult result = results[i];
                if(result.isSuccess()){
                    Email__c email = new Email__c();
                    email.Address__c = contact.Email;
                    email.Contact__c = contact.Id;
                    email.Order__c = orderId;
                    email.Type__c = 'Renewal';
                    email.Subject__c = subject;
                    emailsToInsert.add(email);                     
                }
            }
            
            insert emailsToInsert;
        }
    }
}