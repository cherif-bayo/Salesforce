public class AvoirToOrder{    
    public Integer CountOrder{
        get{
            return this.orders.size();
        }
    }
    
    private List<Order> orders;

    public AvoirToOrder(){
        Avoir__c[] avoirs = [select Id, Name, Montant__c, CreatedDate, Commande_Lie__c from Avoir__c order by CreatedDate desc];
        Map<Id, Avoir__c> dateAvoirsByOrderId = new Map<Id, Avoir__c>();
        for(Avoir__c avoir : avoirs){
            if(dateAvoirsByOrderId.containsKey(avoir.Commande_Lie__c) == false){
                dateAvoirsByOrderId.put(avoir.Commande_Lie__c, avoir);
            }
        }
        
        this.orders = [select Id, Avoir_Date__c, Avoir_Montant__c, Avoir_Ref__c from Order where Id in :dateAvoirsByOrderId.keySet()];
        
        for(Order order : this.orders){
           order.Avoir_Date__c = dateAvoirsByOrderId.get(order.Id).CreatedDate;
           order.Avoir_Montant__c = dateAvoirsByOrderId.get(order.Id).Montant__c;
           order.Avoir_Ref__c = dateAvoirsByOrderId.get(order.Id).Name;           
        }
    }
    
    public void AddAvoirToOrder(){
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