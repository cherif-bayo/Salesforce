public class UpdateOrderItemsExchangeRates{   
    private static Decimal CURRENCY_EUR_RATE = 1.00;
    
    private static String CURRENCY_EUR = 'EUR';    
    private static String CURRENCY_USD = 'USD';
    private static String CURRENCY_JPY = 'JPY';
    private static String CURRENCY_GBP = 'GBP';
 
    public Integer CountOrder{
        get{
            return this.orderItems.size();
        }
    }
    
    private List<OrderItem> orderItems;

    public UpdateOrderItemsExchangeRates(){   
         Map<Date, Map<String, Decimal>> ratesByDateAndCurrency = new Map<Date, Map<String, Decimal>>();
        for(Currencies_Exchange_Rates__c exchangeRate : [SELECT Rate__c, Day__c, CurrencyIsoCode FROM Currencies_Exchange_Rates__c]){
            if(ratesByDateAndCurrency.containsKey(exchangeRate.Day__c)){
                ratesByDateAndCurrency.get(exchangeRate.Day__c).put(exchangeRate.CurrencyIsoCode, exchangeRate.Rate__c);
            }else{
                Map<String, Decimal> ratesByCurrency = new Map<String, Decimal>();
                ratesByCurrency.put(exchangeRate.CurrencyIsoCode, exchangeRate.Rate__c);
                ratesByDateAndCurrency.put(exchangeRate.Day__c, ratesByCurrency);
            }
        }    
         
        Currencies_Exchange_Rates__c firstRate = [SELECT Day__c FROM Currencies_Exchange_Rates__c ORDER BY Day__c limit 1];
        this.orderItems = [SELECT Total_Price_After_Discount__c, Order.EffectiveDate, Order.CurrencyIsoCode, Total_Price_After_DiscountEUR__c, Total_Price_After_DiscountGBP__c, Total_Price_After_DiscountUSD__c, Total_Price_After_DiscountJPY__c FROM OrderItem WHERE Order.EffectiveDate >= :firstRate.Day__c AND Total_Price_After_DiscountJPY__c = null AND Total_Price_After_DiscountGBP__c = null AND Total_Price_After_DiscountEUR__c = null AND Total_Price_After_DiscountUSD__c = null AND Total_Price_After_Discount__c != null limit 500];
        
        for(OrderItem orderItem : this.orderItems){
            Date orderDate = orderItem.Order.EffectiveDate;
            Integer nbDaysRemoved = 0;
            while(ratesByDateAndCurrency.containsKey(orderDate) == false || nbDaysRemoved < 30){
                orderDate = orderDate.addDays(-1);
                nbDaysRemoved++;
            }
            if(ratesByDateAndCurrency.containsKey(orderDate)){
                Map<String, Decimal> ratesByCurrency = ratesByDateAndCurrency.get(orderDate);
                if(ratesByCurrency.containsKey(CURRENCY_USD) && ratesByCurrency.containsKey(CURRENCY_JPY) && ratesByCurrency.containsKey(CURRENCY_GBP)){                    
                    Decimal rateOrder = CURRENCY_EUR_RATE;
                    if(orderItem.Order.CurrencyIsoCode != CURRENCY_EUR){
                        rateOrder = ratesByCurrency.get(orderItem.Order.CurrencyIsoCode);
                    }
                
                    Decimal rateEUR = CURRENCY_EUR_RATE;
                    Decimal rateUSD = ratesByCurrency.get(CURRENCY_USD);
                    Decimal rateJPY = ratesByCurrency.get(CURRENCY_JPY);
                    Decimal rateGBP = ratesByCurrency.get(CURRENCY_GBP);  
                                                                  
                    orderItem.Total_Price_After_DiscountEUR__c = (orderItem.Total_Price_After_Discount__c * rateEUR) / rateOrder;
                    orderItem.Total_Price_After_DiscountUSD__c = (orderItem.Total_Price_After_Discount__c * rateUSD) / rateOrder;
                    orderItem.Total_Price_After_DiscountJPY__c = (orderItem.Total_Price_After_Discount__c * rateJPY) / rateOrder;
                    orderItem.Total_Price_After_DiscountGBP__c = (orderItem.Total_Price_After_Discount__c * rateGBP) / rateOrder;                                                   
                }
            }
        }
    }
    
    public PageReference UpdateOrders(){
        List<List<OrderItem>> ordersToUpdate = new List<List<OrderItem>>();
        
        List<OrderItem> os = new List<OrderItem>();
        Integer max = this.orderItems.size() >= 2000 ? 2000 : this.orderItems.size();
        for(Integer i = 0; i < max; i++){
            OrderItem order = this.orderItems[i];     
            
            os.add(order);
        }
        
        for(Integer i = 0; i < max; i++){
            this.orderItems.remove(0);
        }
        
        ordersToUpdate.add(os);
        
        for(List<OrderItem> o : ordersToUpdate){
            update o;
        }
        
        return null;
    }
}