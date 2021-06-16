global class StripeExpiredLicenseEmailBatchable implements Database.Batchable<sObject>, Database.AllowsCallouts{        
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        Date dateSendEmail = Date.today().addDays(3);
        String query = 'SELECT Order__c, Contact__c, Contact__r.Second_mail__c, Contact__r.Code_MyAccount__c, Order__r.CustomerPortal__c, Date_Limite__c, Modules__c, Contact__r.Email, Contact__r.Compte_MyAccount_cree__c, Contact__r.Langue__c, Order__r.Account.Type, Domaine_Utilisateur__c, Type_Licence__c, Name, Date_relance__c, Date_Relance_J_3__c, Order__r.Provenance__c, Expiration__c, Quantity__c FROM Flexera_Key__c WHERE Date_Limite__c = :dateSendEmail AND Relance_manuelle__c = false';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Flexera_Key__c> keys){
        Map<Id, Texte_Email__c> textesEmailById = new Map<Id, Texte_Email__c>([SELECT Id, Texte__c FROM Texte_Email__c]);
        List<Email__c> emailsToInsert = new List<Email__c>();
        
        
        for(Flexera_Key__c key : keys){
            try {
                Boolean hasRelance = key.Date_Relance_J_3__c != null;
                if(hasRelance == true){
                    hasRelance = key.Date_Relance_J_3__c.year() == Date.today().year();
                }
                
                if(hasRelance == false){
                    if(key.Domaine_Utilisateur__c != 'Student' && key.Order__r.Account.Type == 'Client'){
                        
                        Date dateNotSendEmail = Date.today().addDays(16);
                        Map<Date, Flexera_Key__c> keysWithSiblings = new Map<Date, Flexera_Key__c>();
                            for (Flexera_Key__c keyDate: keys) {
                                keysWithSiblings.put(keyDate.Date_limite__c, keyDate);
                            }
						
                         // Check if the same key exist with different user and date limite or relance manuelle true
                        Flexera_Key__c[] keysWithSameNameAndManual = [SELECT Id, Date_limite__c FROM Flexera_Key__c WHERE Name = :key.Name AND (Relance_manuelle__c = true OR Date_limite__c > :dateNotSendEmail)];
                        
                        if(keysWithSameNameAndManual.size() == 0 ){
                            String templateName;
                            Converter.Locale locale;
                            if(key.Contact__r.Langue__c == 'FR'){
                                templateName = 'Expiring key FR ';
                                locale = Converter.Locale.FR;
                            }else{
                                templateName = 'Expiring key EN ';
                                locale = Converter.Locale.US;
                            }
                            Boolean sendEmail = false;
                            
                            if(key.Expiration__c == 'Expiring' && key.Order__r.Provenance__c == 'Stripe'){
                                templateName += 'Stripe ';
                                sendEmail = true;
                            }
                            
                            if(sendEmail == true){
                                
                                if(key.Quantity__c > 5){
                                    templateName += 'Superior5';
                                }else{
                                    templateName += 'Inferior5 ';
                                    
                                    if(key.Contact__r.Compte_MyAccount_cree__c == true){
                                        templateName += 'MyAccount';
                                       
                                    }else{
                                        templateName += 'NotMyAccount';
                                    }
                                }
                                
                                Map<String, String> mapSubjectParams = new Map<String, String> {
                                };
                                    
                                    Map<String, String> mapBodyParams = new Map<String, String> {
                                        	'{!Modules}' => key.Modules__c,
                                            '{!DateLimit}' => Converter.DateToLocaleDate(key.Date_Limite__c, locale),
                                            '{!Quantity}' => String.valueof(key.Quantity__c.round()) + ' ' + (key.Quantity__c > 1 ? (key.Contact__r.Langue__c == 'FR' ? 'utilisateurs' : 'users') : (key.Contact__r.Langue__c == 'FR' ? 'utilisateur' : 'user')),
                                            '{!MyAccountCode}' => key.Contact__r.Code_MyAccount__c,
                                            '{!CustomerPortalOnKey}' => key.Order__r.CustomerPortal__c
                                            };
                                                
                                                List<EmailMessageWrapper> listEmailMessageWrapper = new List<EmailMessageWrapper>();
                                listEmailMessageWrapper.add(new EmailMessageWrapper('sales@xlstat.com', key.Contact__r.Email, null, null, null, mapSubjectParams, null, mapBodyParams));
                                if(key.Contact__r.Second_mail__c != null){
                                    listEmailMessageWrapper.add(new EmailMessageWrapper('sales@xlstat.com', key.Contact__r.Second_mail__c, null, null, null, mapSubjectParams, null, mapBodyParams));
                                }
                                System.debug('Used template: '+templateName);
                                UtilityClassV2 utilityClass = new UtilityClassV2(listEmailMessageWrapper, templateName, key.Order__c);
                                List<Messaging.SendEmailResult> results = utilityClass.sendEmail(listEmailMessageWrapper);
                                Boolean successSendEmail = true;
                                for(Integer i = 0; i < results.size(); i++){
                                    Messaging.SendEmailResult result = results[i];
                                    if(result.isSuccess() == false){
                                        successSendEmail = false;
                                        break;
                                    }else{
                                        Email__c email = new Email__c();
                                        email.Address__c = key.Contact__r.Email;
                                        email.Contact__c = key.Contact__c;
                                        email.Nalpeiron_Key__c = key.Name;
                                        email.Order__c = key.Order__c;
                                        email.Type__c = 'Expiration';
                                        email.Subject__c = 'Expiration/Renouvellement clé licence';
                                        emailsToInsert.add(email);    
                                        
                                        if(key.Contact__r.Second_mail__c != null){
                                            Email__c email2 = email.clone(false, true);
                                            email2.Address__c = key.Contact__r.Second_mail__c;
                                            
                                            emailsToInsert.add(email2);
                                        } 
                                    }
                                }
                                
                                if(successSendEmail){
                                    key.Date_Relance_J_3__c = Date.today();      
                                }
                            }
                        }
                    }
                }
            } catch (Exception e) {
                BatchStatus__c bs = new BatchStatus__c(BatchName__c='FlexeraExpiredLicenseEmailBatchable',
                                                       Message__c=e.getMessage(),
                                                       Exception__c=e.getStackTraceString());
                insert bs;
            }    
        }        
        try {
            update keys;
            insert emailsToInsert;    
        } catch (Exception e) {
            BatchStatus__c bs = new BatchStatus__c(BatchName__c='FlexeraExpiredLicenseEmailBatchable',
                                                   Message__c=e.getMessage(),
                                                   Exception__c=e.getStackTraceString());
            insert bs;
        }                    
    }
    
    global void finish(Database.BatchableContext BC){
        // Get the ID of the AsyncApexJob representing this batch job
        // from Database.BatchableContext.
        // Query the AsyncApexJob object to retrieve the current job's information.
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
                          TotalJobItems, CreatedBy.Email
                          FROM AsyncApexJob WHERE Id =
                          :BC.getJobId()];        
        String body = '<h1>The batch Apex job processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.</h1><h2> See bach status error records.</h2>';         
        String[] toAddresses = new String[] {Label.emailAdmin};  
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();            
        mail.setToAddresses(toAddresses);
        mail.setSubject('Errors in FlexeraExpiredLicenseEmailBatchable');            
        mail.setHtmlBody(body);
        if (Integer.valueOf(a.NumberOfErrors)>0) {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });            
        }
    }
    
    private class CustomException extends Exception {}
}