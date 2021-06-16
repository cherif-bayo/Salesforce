public class FlexeraAddExistingKeyToOrderController{
    public String orderId {get; set;}
    private String contactId;
    
    public String SearchText { get; set; }
    
    private void updateLicenseKeys(){   
        this.WrapperKeys = new List<WrapperKey>();
        
        Order order = [select Client_final__c, Contact_lie__c, AccountId from Order where Id = :this.orderId];
        if(order.Client_final__c != null){
            this.contactId = order.Client_final__c;
        }else if(order.Contact_lie__c != null){
            this.contactId = order.Contact_lie__c;
        }else{
            Account account = [select IsPersonAccount, PersonContactId from Account where Id = :order.AccountId];
            if(account.IsPersonAccount == true){
                this.contactId = account.PersonContactId;
            }
        }
        
        if(this.contactId != null){   
            List<Flexera_Key__c> keys = new List<Flexera_Key__c>();       
            if(String.IsEmpty(this.SearchText) || this.SearchText == null){
                keys = [SELECT Is_Network__c, Has_Student_Ext__c, Name, Campaign__c, Order__c, Order__r.OrderNumber, Contact__c, Contact__r.Name, Date_limite__c, Domaine_utilisateur__c, Expiration__c, Modules__c, Nb_activations__c, Nb_activations_allowed__c, Quantity__c, Type_client__c, Type_licence__c, XLSTAT_Options__c, XLSTAT_Solution__c, Version__r.Name, Entitlement_Id__c FROM Flexera_Key__c where Contact__c = :this.contactId and Order__c != :this.orderId];
            }else{
                keys = [SELECT Is_Network__c, Has_Student_Ext__c, Name, Campaign__c, Order__c, Order__r.OrderNumber, Contact__c, Contact__r.Name, Date_limite__c, Domaine_utilisateur__c, Expiration__c, Modules__c, Nb_activations__c, Nb_activations_allowed__c, Quantity__c, Type_client__c, Type_licence__c, XLSTAT_Options__c, XLSTAT_Solution__c, Version__r.Name, Entitlement_Id__c FROM Flexera_Key__c where Name = :searchtext and Order__c != :this.orderId];
            }
                
            for(Flexera_Key__c key: keys){
                WrapperKey wrapperKey = new WrapperKey();
                wrapperKey.Key = key;
                wrapperKey.IsSelected = false;
                
                this.WrapperKeys.add(wrapperKey);
            }
        }
    }

    public List<WrapperKey> WrapperKeys {get; set;}

    public class WrapperKey{
        public Flexera_Key__c Key {get; set;}
        public Boolean IsSelected {get; set;}
    }
    
    public FlexeraAddExistingKeyToOrderController(){    
        this.orderId = ApexPages.currentPage().getParameters().get('order_id');
        
        if(this.orderId != null){
            this.updateLicenseKeys();
        }
    }

    public PageReference Add() {        
        List<Flexera_Key__c> keysToAddToContact = new List<Flexera_Key__c>();
        for(WrapperKey wrapperKey : WrapperKeys){
            if(wrapperKey.IsSelected == true){
                Flexera_Key__c key = wrapperKey.Key.clone(false, true);
                key.Order__c = this.orderId;
                
                keysToAddToContact.add(key);
            }
        }
        
        insert keysToAddToContact;
    
        return new PageReference('/' + this.orderId);
    }
    
    public PageReference Cancel(){
        return new PageReference('/' + this.orderId);
    }
    
     public PageReference Search() {
        this.updateLicenseKeys(); 
        
        return null;
    }
}