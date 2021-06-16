public class MontantProductFamilyToOrder{    
    public Integer CountOrder{
        get{
            return this.orders.size();
        }
    }
    
    private List<Order> orders;

    public MontantProductFamilyToOrder(){
        OrderItem[] orderItems = [select PricebookEntry.Product2.Family, TotalPriceAfterDiscountShowed__c, OrderId from OrderItem];
        Map<Id, List<OrderItem>> orderItemsByOrder = new Map<Id, List<OrderItem>>(); 
        for(OrderItem orderItem : orderItems){
            if(orderItemsByOrder.containsKey(orderItem.OrderId)){
                orderItemsByOrder.get(orderItem.OrderId).add(orderItem);
            }else{
                List<OrderItem> os = new List<OrderItem>();
                os.add(orderItem);
                orderItemsByOrder.put(orderItem.OrderId, os);
            }
        }
        
        this.orders = [select Id, MontantModule__c, MontantSolution__c, MontantFormation__c, MontantExpertise__c, MontantShipping__c, MontantSupport__c from Order where Id in :orderItemsByOrder.keySet()];
        
        for(Order order : this.orders){
            order.MontantModule__c = 0;
            order.MontantSolution__c = 0;
            order.MontantFormation__c  = 0;
            order.MontantExpertise__c = 0;
            order.MontantSupport__c = 0;
            order.MontantShipping__c = 0;            
            List<OrderItem> os = orderItemsByOrder.get(order.Id);
            for(OrderItem orderItem : os){
                if(orderItem.PricebookEntry.Product2.Family == 'Module'){
                    order.MontantModule__c = order.MontantModule__c + orderItem.TotalPriceAfterDiscountShowed__c;
                }else if(orderItem.PricebookEntry.Product2.Family == 'Solution'){
                    order.MontantSolution__c = order.MontantSolution__c + orderItem.TotalPriceAfterDiscountShowed__c;
                }else if(orderItem.PricebookEntry.Product2.Family == 'Formation'){
                    order.MontantFormation__c = order.MontantFormation__c + orderItem.TotalPriceAfterDiscountShowed__c;
                }else if(orderItem.PricebookEntry.Product2.Family == 'Expertise'){
                    order.MontantExpertise__c = order.MontantExpertise__c + orderItem.TotalPriceAfterDiscountShowed__c;
                }else if(orderItem.PricebookEntry.Product2.Family == 'Support'){
                    order.MontantSupport__c = order.MontantSupport__c + orderItem.TotalPriceAfterDiscountShowed__c;
                }else if(orderItem.PricebookEntry.Product2.Family == 'Shipping'){
                    order.MontantShipping__c = order.MontantShipping__c + orderItem.TotalPriceAfterDiscountShowed__c;
                }
            }
        }
    }
    
    public void AddMontantToOrder(){
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