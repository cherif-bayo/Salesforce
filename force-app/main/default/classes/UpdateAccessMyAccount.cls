public class UpdateAccessMyAccount{
    public String CountOrders{
        get{
            return String.valueof(this.o.size());
        }
    }

    private Contact[] o;

    public UpdateAccessMyAccount(){
        this.o = [select Id, Acces_MyAccount__c FROM Contact WHERE Acces_MyAccount__c = false];
    }

    public void Inverse(){
        List<List<Contact>> ordersToUpdate = new List<List<Contact>>();
        
        List<Contact> orders = new List<Contact>();
        Integer max = o.size() >= 2000 ? 2000 : o.size();
        for(Integer i = 0; i < max; i++){
            Contact order = o[i];
            order.Acces_MyAccount__c = true;
        
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