public class FraisShareItCorrectionController{
    public String CountOrders{
        get{
            return String.valueof(this.o.size());
        }
    }

    private Order[] o;

    public FraisShareItCorrectionController(){
        this.o = [select Id, Frais_ShareIt__c from Order where Status != 'Version préliminaire' and Import_Auto__c = true and Provenance__c != 'ShareIt'];
    }

    public void Generate(){
        List<List<Order>> ordersToUpdate = new List<List<Order>>();
        
        List<Order> orders = new List<Order>();
        Integer max = o.size() >= 2000 ? 2000 : o.size();
        for(Integer i = 0; i < max; i++){
            Order order = o[i];
            order.Frais_ShareIt__c = 0;
            
            orders.add(order);
        }
        
        for(Integer i = 0; i < max; i++){
            o.remove(0);
        }
        
        ordersToUpdate.add(orders);
        
        for(List<Order> o : ordersToUpdate){
            update o;
        }
    }
}