trigger insertUpdateAccountRevendeur on Order (before insert, before update) {
    Set<String> accountIds = new Set<String>();
    Set<String> clientFinalIds = new Set<String>();
    
    for(Order order : Trigger.new){
        accountIds.add(order.AccountId);
        clientFinalIds.add(order.Client_final__c);
    }
    
    Account[] accounts = [select Id, Type from Account where Id in :accountIds];
    Contact[] contacts = [select Id, AccountId from Contact where Id in :clientFinalIds];

    for(Order order : Trigger.new){
        order.AccountPro__c = null;
        Account account;
        
        for(Account ac: accounts){
            if(ac.Id == order.AccountId){
                account = ac;
                break;
            }
        }
        //Account account = [select Type from Account where Id = :order.AccountId];
    
        if(account != null){
            if(account.Type == 'Revendeur' || account.Type == 'Distributeur' || account.Type == 'Editeur'){
                if(order.Client_final__c != null){
                    Contact contactClientFinal;
                    for(Contact c : contacts){
                        if(c.Id == order.Client_final__c){
                            contactClientFinal = c;
                            break;
                        }
                    }
                
                    //Contact contactClientFinal =  [select AccountId from Contact where Id = :order.Client_final__c];
                    order.AccountPro__c = contactClientFinal.AccountId;
                }
            }
        }
    }
}