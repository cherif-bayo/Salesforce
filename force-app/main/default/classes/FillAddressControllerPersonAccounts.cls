public class FillAddressControllerPersonAccounts{    
    public Integer CountPersonAccounts{
        get{
            return this.personAccounts.size();
        }
    }

    private Account[] personAccounts;

    public FillAddressControllerPersonAccounts(){        
        this.personAccounts = [select Id, Pays__pc, BillingCountryCode, ShippingCountryCode from Account where IsPersonAccount = true and Import_Auto__c = true];
    }
    
    public void AddAddressToPersonAccounts(){
        List<List<Account>> accountsToUpdate = new List<List<Account>>();
        
        List<Account> accounts = new List<Account>();
        Integer max = this.personAccounts.size() >= 2000 ? 2000 : this.personAccounts.size();
        for(Integer i = 0; i < max; i++){
            Account a = this.personAccounts[i];
            
            if(a.Pays__pc != null){
                String countryCodeAccount = a.Pays__pc.split('-')[0].trim();
                if(countryCodeAccount == 'UK'){
                    countryCodeAccount = 'GB';
                }else if(countryCodeAccount == 'HK'){
                    countryCodeAccount = 'CN';
                }
            
                if(countryCodeAccount != 'PR' && countryCodeAccount != 'GU'){
                    a.BillingCountryCode = countryCodeAccount;
                    a.ShippingCountryCode = countryCodeAccount;
                    
                    accounts.add(a);
                }
            }
        }
        
        for(Integer i = 0; i < max; i++){
            this.personAccounts.remove(0);
        }
        
        accountsToUpdate.add(accounts);
        
        for(List<Account> a : accountsToUpdate){
            update a;
        }
    }
}