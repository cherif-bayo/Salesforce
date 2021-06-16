public class DateFactureToOrder{    
    public Integer CountOrder{
        get{
            return this.orders.size();
        }
    }
    
    private List<Order> orders;

    public DateFactureToOrder(){
        Facture__c[] factures = [select Id, Date__c, Commande_Lie__c from Facture__c order by Date__c desc];
        Map<Id, Date> dateFacturesByOrderId = new Map<Id, Date>();
        for(Facture__c facture : factures){
            if(dateFacturesByOrderId.containsKey(facture.Commande_Lie__c) == false){
                dateFacturesByOrderId.put(facture.Commande_Lie__c, facture.Date__c);
            }
        }
        
        this.orders = [select Id, Date_facture__c from Order where Id in :dateFacturesByOrderId.keySet()];
        
        for(Order order : this.orders){
           order.Date_facture__c = dateFacturesByOrderId.get(order.Id);
        }
    }
    
    public void AddDateFactureToOrder(){
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