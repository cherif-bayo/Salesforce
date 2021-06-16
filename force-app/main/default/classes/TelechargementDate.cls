public class TelechargementDate{
   public Integer CountOrder{
        get{
            return this.orders.size();
        }
    }
    
    private List<Telechargement__c> orders;
    
    public TelechargementDate(){        
        this.orders = [select Date__c, CreatedDate from Telechargement__c where Date__c = null];
        
        for(Telechargement__c order : this.orders){
           order.Date__c = order.CreatedDate;
        }
    }
    
    public void ChangeDate(){
        List<List<Telechargement__c>> ordersToUpdate = new List<List<Telechargement__c>>();
        
        List<Telechargement__c> os = new List<Telechargement__c>();
        Integer max = this.orders.size() >= 2000 ? 2000 : this.orders.size();
        for(Integer i = 0; i < max; i++){
            Telechargement__c order = this.orders[i];     
            
            os.add(order);
        }
        
        for(Integer i = 0; i < max; i++){
            this.orders.remove(0);
        }
        
        ordersToUpdate.add(os);
        
        for(List<Telechargement__c> o : ordersToUpdate){
            update o;
        }
    }
    
}