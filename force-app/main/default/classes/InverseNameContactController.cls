public class InverseNameContactController{
    public String CountOrders{
        get{
            return String.valueof(this.o.size());
        }
    }

    private Contact[] o;

    public InverseNameContactController(){
        this.o = [select Id, FirstName, LastName from Contact where Import_Auto__c = true and FirstName != null];
    }

    public void Inverse(){
        List<List<Contact>> ordersToUpdate = new List<List<Contact>>();
        
        List<Contact> orders = new List<Contact>();
        Integer max = o.size() >= 2000 ? 2000 : o.size();
        for(Integer i = 0; i < max; i++){
            Contact order = o[i];
            String FirstName = order.FirstName;
            String LastName = order.LastName;
            order.FirstName = LastName;
            order.LastName = FirstName;
        
            if(orders.size() == 1000){
                ordersToUpdate.add(orders);
                orders = new List<Contact>{order};
            }else{
                orders.add(order);
            }
        }
        
        for(Integer i = 0; i < max; i++){
            o.remove(0);
        }
        
        ordersToUpdate.add(orders);
        
        for(List<Contact> o : ordersToUpdate){
            update o;
        }
    }
}