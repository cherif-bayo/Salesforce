global class OrderCheckPersonCompanyDomainBatchable implements Database.Batchable<sObject>, Database.AllowsCallouts{
    
    global OrderCheckPersonCompanyDomainBatchable(){
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT AccountId, Client_Final__c, Contact_Lie__c, Client_Final__r.Email, Contact_Email__c, HasPersonAccountAndCompanyDomain__c FROM Order WHERE HasPersonAccountAndCompanyDomain__c = true';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Order> orders){
        Set<String> domains = new Set<String>();
        for(Domaine_general__c domain : [SELECT Name FROM Domaine_general__c]){
            domains.add(domain.Name);
        }
        
        for(Order order : orders){
            if(order.Contact_Email__c != null){  
                Account[] accounts;
                if(order.Contact_Lie__c != null){
                    accounts = [SELECT IsPersonAccount FROM Account WHERE PersonContactId = :order.Contact_Lie__c];
                }else{
                    accounts = [SELECT IsPersonAccount FROM Account WHERE Id = :order.AccountId];
                }
                      
                if(accounts.size() > 0){
                    if(accounts[0].IsPersonAccount){
                        String emailDomainClientLie = order.Contact_Email__c.substringAfter('@');
                        String emailDomainClientLie2 = emailDomainClientLie.substringBefore('.');
                        
                        if(domains.contains(emailDomainClientLie) == true || domains.contains(emailDomainClientLie2) == true){
                            order.HasPersonAccountAndCompanyDomain__c = false;
                        }
                    }else{
                        order.HasPersonAccountAndCompanyDomain__c = false;
                    }
                }else{
                    order.HasPersonAccountAndCompanyDomain__c = false;
                }
            }
            
            if(order.Client_Final__r.Email != null){
                order.HasPersonAccountAndCompanyDomain__c = true;
                Account[] accounts = [SELECT IsPersonAccount FROM Account WHERE PersonContactId = :order.Client_Final__c];
            
                if(accounts.size() > 0){
                
                    String emailDomainClientFinal = order.Client_Final__r.Email.substringAfter('@');
                    String emailDomainClientFinal2 = emailDomainClientFinal.substringBefore('.');
                    
                    if(domains.contains(emailDomainClientFinal2) == true || domains.contains(emailDomainClientFinal) == true){
                        order.HasPersonAccountAndCompanyDomain__c = false;
                    }
                }else{
                    order.HasPersonAccountAndCompanyDomain__c = false;
                }
            }
            
            if(order.Contact_Email__c == null && order.Client_Final__r.Email == null){
                order.HasPersonAccountAndCompanyDomain__c = false;
            }
        }
        
        update orders;
    }

    global void finish(Database.BatchableContext BC){}
}