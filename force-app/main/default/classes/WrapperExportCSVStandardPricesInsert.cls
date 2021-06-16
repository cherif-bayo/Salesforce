public class WrapperExportCSVStandardPricesInsert{
    public string pricebookId {get; set;}
    public string productId {get; set;}
    public string productCode {get; set;}
    public string productPrice{get; set;}
    public string productCurrency{get; set;}
    public boolean getIsActive(){
        return true;
    }
}