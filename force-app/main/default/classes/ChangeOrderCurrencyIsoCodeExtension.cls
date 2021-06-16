public class ChangeOrderCurrencyIsoCodeExtension {

    public final Order order {get; set;}
    public String CurrencyIsoCode {get; set;}
    public List<SelectOption> CurrencyIsoCodes {get;set;}
    public Boolean NotChanged {get; set;}
    
    private static List<String> currencies = new List<String>{'EUR', 'USD', 'GBP', 'JPY'};
    private Pricebook2[] pricebooks;
    
    public ChangeOrderCurrencyIsoCodeExtension(ApexPages.StandardController stdController) {
        this.order = [select Id, CurrencyIsoCode, Pricebook2Id from Order where Id = :stdController.getId()];
        
        OrderItem[] orderItems = [select Id from OrderItem where OrderId = :this.order.Id];
        
        if(orderItems.size() > 0){
            this.NotChanged = false;
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Vous ne pouvez pas changer la devise d\'une commande contenant des produits.'));
        }else{
            this.CurrencyIsoCodes = new List<SelectOption>();
            for(String c : currencies){
                if(c != this.order.CurrencyIsoCode){
                    this.CurrencyIsoCodes.add(new SelectOption(c, c));
                }
            }    
            
            this.NotChanged = true;      
            
            this.pricebooks = [select Id, Name from Pricebook2]; 
        }                    
    }

    public void changeOrderCurrencyIsoCode() {
        if(this.NotChanged == true){
            try{
                String pricebookIdForOrder = this.order.Pricebook2Id;
                for(Pricebook2 pricebook : this.pricebooks){
                    if(pricebook.Name.contains(this.CurrencyIsoCode)){
                        pricebookIdForOrder = pricebook.Id;
                        break;
                    }
                }
                
                this.order.CurrencyIsoCode = this.CurrencyIsoCode;
                this.order.Pricebook2Id = pricebookIdForOrder;
                
                update order;
            
                this.NotChanged = false;
                
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, 'Devise changée.'));
            }catch(Exception e){
                ApexPages.addMessages(e);
            }
        }
    }
}