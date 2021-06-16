public class FillAddressControllerOrders{    
    public Integer CountOrder{
        get{
            return this.orders.size();
        }
    }
    
    private List<Order> orders;

    public FillAddressControllerOrders(){
        Account[] accounts = [select Id, BillingCountryCode from Account];
        Map<Id, Account> mapAccounts = new Map<Id, Account>(accounts);
        
        this.orders = [select Id, AccountId, Import_Auto__c, BillingCountryCode, ShippingCountryCode from Order where AccountId in :mapAccounts.keySet() and Import_Auto__c = true];
        
        for(Order order : this.orders){
            Account account = mapAccounts.get(order.AccountId);
            
            order.BillingCountryCode = account.BillingCountryCode;
            order.ShippingCountryCode = account.BillingCountryCode;       
        }
    }
    
    public void AddAddressToOrders(){
        List<List<Order>> ordersToUpdate = new List<List<Order>>();
        
        List<Order> os = new List<Order>();
        Integer max = this.orders.size() >= 2000 ? 2000 : this.orders.size();
        for(Integer i = 0; i < max; i++){
            Order order = this.orders[i];     
            
            os.add(order);
        }
        
        for(Integer i = 0; i < max; i++){
            this.orders.remove(0);
        }
        
        ordersToUpdate.add(os);
        
        for(List<Order> o : ordersToUpdate){
            update o;
        }
    }
}