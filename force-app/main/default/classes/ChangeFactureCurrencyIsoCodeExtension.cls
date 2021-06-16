public class ChangeFactureCurrencyIsoCodeExtension {

    public final Facture__c facture {get; set;}
    public String CurrencyIsoCode {get; set;}
    public List<SelectOption> CurrencyIsoCodes {get;set;}
    public Boolean NotChanged {get; set;}
    
    private static List<String> currencies = new List<String>{'EUR', 'USD', 'GBP', 'JPY'};
    
    public ChangeFactureCurrencyIsoCodeExtension(ApexPages.StandardController stdController) {
        this.facture = [select Id, CurrencyIsoCode from Facture__c where Id = :stdController.getId()];
        
        this.CurrencyIsoCodes = new List<SelectOption>();
        for(String c : currencies){
            if(c != this.facture.CurrencyIsoCode){
                this.CurrencyIsoCodes.add(new SelectOption(c, c));
            }
        }    
            
        this.NotChanged = true;   
    }

    public void ChangeCurrency() {
        if(this.NotChanged == true){
            try{
                this.facture.CurrencyIsoCode = this.CurrencyIsoCode;
                
                update facture;
            
                this.NotChanged = false;
                
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, 'Devise changée.'));
            }catch(Exception e){
                ApexPages.addMessages(e);
            }
        }
    }
}