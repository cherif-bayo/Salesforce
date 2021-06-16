@isTest (SeeAllData=true)

public class testChangeCurrencyIsoCodeOrder{
    public static testMethod void testWithoutOrderItems(){
        Order order = [select Id, CurrencyIsoCode from Order where TotalAmount = 0 limit 1];
        List<String> currencies = new List<String>{'EUR', 'USD', 'GBP', 'JPY'};
        
        Test.setCurrentPage(Page.pageChangeOrderCurrencyIsoCodeExtension);

        // call the constructor
        ChangeOrderCurrencyIsoCodeExtension controller = new ChangeOrderCurrencyIsoCodeExtension(new ApexPages.StandardController(order));
        String newCurrency;
        for(String c : currencies){
            if(c != order.CurrencyIsoCode){
                newCurrency = c;
                break;
            }
        }
        controller.CurrencyIsoCode = newCurrency;
        controller.changeOrderCurrencyIsoCode();
    }
    
    public static testMethod void testWithOrderItems(){
        Order order = [select Id, CurrencyIsoCode from Order where TotalAmount > 0 limit 1];
        ChangeOrderCurrencyIsoCodeExtension controller = new ChangeOrderCurrencyIsoCodeExtension(new ApexPages.StandardController(order));
    }
}