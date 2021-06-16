public class FraisShareItController{
    public String CountOrders{
        get{
            return String.valueof(this.o.size());
        }
    }

    private Order[] o;

    public FraisShareItController(){
        this.o = [select Id, Frais_ShareIt__c, NbOrderItems__c, TotalAmountAfterDiscount__c, TotalAmount from Order where Status != 'Version préliminaire' and Import_Auto__c = true];
    }

    public void Generate(){
        List<List<Order>> ordersToUpdate = new List<List<Order>>();
        
        List<Order> orders = new List<Order>();
        Integer max = o.size() >= 2000 ? 2000 : o.size();
        List<String> oIds = new List<String>();
        for(Integer i = 0; i < max; i++){
            oIds.add(o[i].Id);
        }
        OrderItem[] orderItems = [select OrderId from OrderItem where OrderId in :oIds and PricebookEntry.Product2.Id = '01t24000001Qdlu'];
        Map<String, OrderItem> orderItemsByOrderId = new Map<String, OrderItem>();
        for(OrderItem orderItem : orderItems){
            orderItemsByOrderId.put(orderItem.OrderId, orderItem);
        }
        for(Integer i = 0; i < max; i++){
            Order order = o[i];
            Integer nbOrderProduct = Integer.valueof(order.NbOrderItems__c);
            if(orderItemsByOrderId.get(order.Id) != null){
                nbOrderProduct--;
            }
            if(order.TotalAmountAfterDiscount__c != null && order.TotalAmountAfterDiscount__c != 0){         
                order.Frais_ShareIt__c = 2.95 * nbOrderProduct + 0.05 * order.TotalAmountAfterDiscount__c;
            }else{
                order.Frais_ShareIt__c = 2.95 * nbOrderProduct + 0.05 * order.TotalAmount;
            }
        
            if(orders.size() == 1000){
                ordersToUpdate.add(orders);
                orders = new List<Order>{order};
            }else{
                orders.add(order);
            }
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