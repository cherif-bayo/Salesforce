public class ChangeOpportunityCurrencyExtension {

    public final Opportunity opportunity {get; set;}
    public String CurrencyIsoCode {get; set;}
    public List<SelectOption> CurrencyIsoCodes {get;set;}
    public Boolean NotChanged {get; set;}
    
    private static List<String> currencies = new List<String>{'EUR', 'USD', 'GBP', 'JPY'};
    private Pricebook2[] pricebooks;
    
    public ChangeOpportunityCurrencyExtension(ApexPages.StandardController stdController) {
        this.opportunity = [select Id, CurrencyIsoCode, Pricebook2Id, SyncedQuoteId from Opportunity where Id = :stdController.getId()];
        
        OpportunityLineItem[] opportunityItems = [select Id from OpportunityLineItem where OpportunityId = :this.opportunity.Id];
        
        Quote[] quotes = [select Id from Quote where OpportunityId = :this.opportunity.Id];
        
        if(opportunityItems.size() > 0){
            this.NotChanged = false;
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Vous ne pouvez pas changer la devise d\'une opportunité contenant des produits.'));
        }else if(quotes.size() > 0){
            this.NotChanged = false;
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Vous ne pouvez pas changer la devise d\'une opportunité contenant des devis.'));
        }else{
            this.CurrencyIsoCodes = new List<SelectOption>();
            for(String c : currencies){
                if(c != this.opportunity.CurrencyIsoCode){
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
                String pricebookIdForOrder = this.opportunity.Pricebook2Id;
                for(Pricebook2 pricebook : this.pricebooks){
                    if(pricebook.Name.contains(this.CurrencyIsoCode)){
                        pricebookIdForOrder = pricebook.Id;
                        break;
                    }
                }
                
                this.opportunity.CurrencyIsoCode = this.CurrencyIsoCode;
                this.opportunity.Pricebook2Id = pricebookIdForOrder;
                
                update opportunity;
            
                this.NotChanged = false;
                
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, 'Devise changée.'));
            }catch(Exception e){
                ApexPages.addMessages(e);
            }
        }
    }
}