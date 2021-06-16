public without sharing class CL001_UTL_OrderProcessingAcad {
    
    public static boolean isSendingKeyAuthorized (String email, String accountId, Boolean myAccount) {  
        String emailDomain = email.substringAfter('@'); 
        
        // email déjà validé à l'inscription comme Acad
        if (myAccount) return true;
        
        // validation des domaines contenus dans l'emailcontre la table domaine_EDU dans SF        
        String[] emailDomainParts = emailDomain.split('\\.');
        List<Domaine_EDU_autorise__c> domaines = [select Name from Domaine_EDU_autorise__c where Name = :emailDomain];
        Boolean emailFound = false;
        if(domaines.size() == 0 && emailDomainParts.size() > 0){
            Integer i = emailDomainParts.size() - 1;
            while(emailFound == false){
                String domaineToCheck = '';
                for(Integer j = i; j < emailDomainParts.size(); j++){
                    domaineToCheck = domaineToCheck + emailDomainParts[j];
                    if(j < emailDomainParts.size() - 1){
                        domaineToCheck = domaineToCheck + '.';
                    }
                }
                domaines = [select Name from Domaine_EDU_autorise__c where Name = :domaineToCheck];
                if(domaines.size() > 0 || i == 0){
                    emailFound = true;
                }
                i--;
            }
        }                                                  
        if(domaines.size() > 0) return true;  
        
        // client déjà client dans le passé (donc email validé comme Acad)
        List<Order> oldValidatedOrders = [SELECT Id FROM Order WHERE (Status = 'Payée' OR Status = 'Validée') AND Id = :accountId];
        return oldValidatedOrders.size() > 0;
    }    
}