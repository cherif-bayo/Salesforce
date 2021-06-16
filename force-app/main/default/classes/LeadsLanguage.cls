public class LeadsLanguage{
    Map<String, String> oldLangueToNewLangue = new Map<String, String>{'en' => 'US', 'ja' => 'JP'};

   public Integer CountOrder{
        get{
            return this.orders.size();
        }
    }
    
    private List<Lead> orders;
    
    public LeadsLanguage(){        
        this.orders = [select Langue__c from Lead where Langue__c = 'en' OR Langue__c = 'ja'];
        
        for(Lead order : this.orders){
           order.Langue__c = oldLangueToNewLangue.get(order.Langue__c);
        }
    }
    
    public void ChangeLanguage(){
        List<List<Lead>> ordersToUpdate = new List<List<Lead>>();
        
        List<Lead> os = new List<Lead>();
        Integer max = this.orders.size() >= 2000 ? 2000 : this.orders.size();
        for(Integer i = 0; i < max; i++){
            Lead order = this.orders[i];     
            
            os.add(order);
        }
        
        for(Integer i = 0; i < max; i++){
            this.orders.remove(0);
        }
        
        ordersToUpdate.add(os);
        
        for(List<Lead> o : ordersToUpdate){
            update o;
        }
    }
    
}