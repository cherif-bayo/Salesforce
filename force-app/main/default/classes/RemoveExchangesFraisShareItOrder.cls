public class RemoveExchangesFraisShareItOrder{   
    public Integer CountOrder{
        get{
            return this.orders.size();
        }
    }
    
    private List<Order> orders;

    public RemoveExchangesFraisShareItOrder(){   
        this.orders = [SELECT Frais_ShareItEUR__c, Frais_ShareItGBP__c, Frais_ShareItJPY__c, Frais_ShareItUSD__c FROM Order WHERE Frais_ShareItEUR__c != null];
        
        for(Order order : this.orders){
            order.Frais_ShareItEUR__c = 0;
            order.Frais_ShareItGBP__c = 0;
            order.Frais_ShareItJPY__c = 0;
            order.Frais_ShareItUSD__c = 0;
        }
    }
    
    public void UpdateOrders(){
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