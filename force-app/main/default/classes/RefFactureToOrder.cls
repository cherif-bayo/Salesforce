public class RefFactureToOrder{    
    public Integer CountOrder{
        get{
            return this.orders.size();
        }
    }
    
    private List<Order> orders;

    public RefFactureToOrder(){
        Facture__c[] factures = [select Id, Name, Commande_lie__c from Facture__c];
        Map<Id, List<Facture__c>> mapFactures = new Map<Id, List<Facture__c>>();
        for(Facture__c facture : factures){
            if(mapFactures.containsKey(facture.Commande_lie__c)){
                mapFactures.get(facture.Commande_lie__c).add(facture);
            }else{
                List<Facture__c> fs = new List<Facture__c>();
                fs.add(facture);
                mapFactures.put(facture.Commande_lie__c, fs);
            }
        }
        
        this.orders = [select Id, R_f_Facture__c from Order where Id in :mapFactures.keySet()];
        
        for(Order order : this.orders){
            String refFacture = order.R_f_Facture__c;
            for(Facture__c facture : mapFactures.get(order.Id)){
                if(refFacture != null){
                    refFacture = refFacture + ', ' + facture.Name;
                }else{
                    refFacture = facture.Name;
                }
            }
            order.R_f_Facture__c = refFacture;
        }
    }
    
    public void AddRefFacturesToOrders(){
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