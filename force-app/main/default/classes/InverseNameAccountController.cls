public class InverseNameAccountController{
    public String CountOrders{
        get{
            return String.valueof(this.o.size());
        }
    }

    private Account[] o;

    public InverseNameAccountController(){
        this.o = [select Id, FirstName, LastName from Account where Import_Auto__c = true and IsPersonAccount = true and FirstName != null];
    }

    public void Inverse(){
        List<List<Account>> ordersToUpdate = new List<List<Account>>();
        
        List<Account> orders = new List<Account>();
        Integer max = o.size() >= 2000 ? 2000 : o.size();
        for(Integer i = 0; i < max; i++){
            Account order = o[i];
            String FirstName = order.FirstName;
            String LastName = order.LastName;
            order.FirstName = LastName;
            order.LastName = FirstName;
        
            if(orders.size() == 1000){
                ordersToUpdate.add(orders);
                orders = new List<Account>{order};
            }else{
                orders.add(order);
            }
        }
        
        for(Integer i = 0; i < max; i++){
            o.remove(0);
        }
        
        ordersToUpdate.add(orders);
        
        for(List<Account> o : ordersToUpdate){
            update o;
        }
    }
}