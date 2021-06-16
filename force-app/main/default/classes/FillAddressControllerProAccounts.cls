public class FillAddressControllerProAccounts{    
    public Integer CountProAccounts{
        get{
            return this.proAccounts.size();
        }
    }
    
    private List<Account> proAccounts;

    public FillAddressControllerProAccounts(){
        Contact[] contacts = [select Id, AccountId, MailingCountryCode, Pays__c from Contact where Import_Auto__c = true];
        List<Id> accountsIds = new List<Id>();
        for(Contact c : contacts){
            accountsIds.add(c.AccountId);
        }
        
        Account[] acc = [select Id, BillingCountryCode, ShippingCountryCode from Account where Id in :accountsIds];
        Map<Id, Account> accountsWithContacts = new Map<Id, Account>(acc);
        
        Map<Id, Account> accountsProToUpdate = new Map<Id, Account>();
        
        for(Contact c : contacts){
            if(c.Pays__c != null){
                String countryCodeContact = c.Pays__c.split('-')[0].trim();
                if(countryCodeContact == 'UK'){
                    countryCodeContact = 'GB';
                }else if(countryCodeContact == 'HK'){
                    countryCodeContact = 'CN';
                }
            
                if(countryCodeContact != 'PR' && countryCodeContact != 'GU'){                    
                    Account a = accountsWithContacts.get(c.AccountId);
                    a.BillingCountryCode = countryCodeContact;
                    a.ShippingCountryCode = countryCodeContact;
                    
                    if(accountsProToUpdate.containsKey(a.Id)){
                        Account accountMap = accountsProToUpdate.get(a.Id);
                        if(accountMap.BillingCountryCode == null && a.BillingCountryCode != null){
                            accountsProToUpdate.put(a.Id, a);
                        }
                    }else{
                        accountsProToUpdate.put(a.Id, a);
                    }
                }
            }
        }
        this.proAccounts = accountsProToUpdate.values();
    }
    
    public void AddAddressToProAccounts(){
        List<List<Account>> accountsToUpdate = new List<List<Account>>();
        
        List<Account> accounts = new List<Account>();
        Integer max = this.proAccounts.size() >= 2000 ? 2000 : this.proAccounts.size();
        for(Integer i = 0; i < max; i++){
            Account a = this.proAccounts[i];
            
            accounts.add(a);
        }
        
        for(Integer i = 0; i < max; i++){
            this.proAccounts.remove(0);
        }
        
        accountsToUpdate.add(accounts);
        
        for(List<Account> a : accountsToUpdate){
            update a;
        }
    }
}