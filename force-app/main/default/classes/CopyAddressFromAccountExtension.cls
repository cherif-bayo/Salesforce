public class CopyAddressFromAccountExtension{
    public final Order order {get; set;}
    public Boolean NotChanged {get; set;}
    
    public CopyAddressFromAccountExtension(ApexPages.StandardController stdController) {
        this.order = [select Id, AccountId, BillingCity, BillingPostalCode, BillingCountry, BillingStreet, BillingState, ShippingCity, ShippingPostalCode, ShippingCountry, ShippingStreet, ShippingState from Order where Id = :stdController.getId()];
        
         Account account = [select BillingCity, BillingPostalCode, BillingCountry, BillingStreet, BillingState, ShippingCity, ShippingPostalCode, ShippingCountry, ShippingStreet, ShippingState from Account where Id = :this.order.AccountId limit 1];
         
         this.order.BillingCity = account.BillingCity;
         this.order.BillingPostalCode = account.BillingPostalCode;
         this.order.BillingCountry = account.BillingCountry;
         this.order.BillingStreet = account.BillingStreet;
         this.order.BillingState = account.BillingState;
         
         this.order.ShippingCity = account.ShippingCity == null ? account.BillingCity : account.ShippingCity;
         this.order.ShippingPostalCode = account.ShippingPostalCode == null ? account.BillingPostalCode : account.ShippingPostalCode;
         this.order.ShippingCountry = account.ShippingCountry == null ? account.BillingCountry : account.ShippingCountry;
         this.order.ShippingStreet = account.ShippingStreet == null ? account.BillingStreet : account.ShippingStreet;
         this.order.ShippingState = account.ShippingState == null ? account.BillingState : account.ShippingState;     
         
         this.NotChanged = true;                               
    }

    public void copyAddress() {
        if(this.NotChanged == true){
            try{
                update order;
            
                this.NotChanged = false;
                
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, 'Adresse importée.'));
            }catch(Exception e){
                ApexPages.addMessages(e);
            }
        }
    }
}