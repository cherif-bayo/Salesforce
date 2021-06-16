public class UpdateExchangeRatesOrder{   
    private static Decimal CURRENCY_EUR_RATE = 1.00;
    
    private static String CURRENCY_EUR = 'EUR';    
    private static String CURRENCY_USD = 'USD';
    private static String CURRENCY_JPY = 'JPY';
    private static String CURRENCY_GBP = 'GBP';
 
    public Integer CountOrder{
        get{
            return this.orders.size();
        }
    }
    
    private List<Order> orders;

    public UpdateExchangeRatesOrder(){   
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
        this.orders = [SELECT Provenance__c, NbOrderItems__c, Frais_ShareItUSD__c, Frais_ShareItGBP__c, Frais_ShareItEUR__c, Frais_ShareItJPY__c, CurrencyIsoCode, EffectiveDate, TotalAmountAfterDiscountShowed__c, TotalAmountAfterDiscountEUR__c, TotalAmountAfterDiscountUSD__c, TotalAmountAfterDiscountJPY__c , TotalAmountAfterDiscountGBP__c FROM Order WHERE EffectiveDate >= :firstRate.Day__c AND TotalAmountAfterDiscountEUR__c = null AND TotalAmountAfterDiscountGBP__c = null AND TotalAmountAfterDiscountJPY__c = null AND TotalAmountAfterDiscountUSD__c = null limit 500];
        
        for(Order order : this.orders){
            Date orderDate = order.EffectiveDate;
            Integer nbDaysRemoved = 0;
            while(ratesByDateAndCurrency.containsKey(orderDate) == false || nbDaysRemoved < 30){
                orderDate = orderDate.addDays(-1);
                nbDaysRemoved++;
            }
            if(ratesByDateAndCurrency.containsKey(orderDate)){
                Map<String, Decimal> ratesByCurrency = ratesByDateAndCurrency.get(orderDate);
                if(ratesByCurrency.containsKey(CURRENCY_USD) && ratesByCurrency.containsKey(CURRENCY_JPY) && ratesByCurrency.containsKey(CURRENCY_GBP)){                    
                    Decimal rateOrder = CURRENCY_EUR_RATE;
                    if(order.CurrencyIsoCode != CURRENCY_EUR){
                        rateOrder = ratesByCurrency.get(order.CurrencyIsoCode);
                    }
                
                    Decimal rateEUR = CURRENCY_EUR_RATE;
                    Decimal rateUSD = ratesByCurrency.get(CURRENCY_USD);
                    Decimal rateJPY = ratesByCurrency.get(CURRENCY_JPY);
                    Decimal rateGBP = ratesByCurrency.get(CURRENCY_GBP);  
                                                                  
                    order.TotalAmountAfterDiscountEUR__c = (order.TotalAmountAfterDiscountShowed__c * rateEUR) / rateOrder;
                    order.TotalAmountAfterDiscountUSD__c = (order.TotalAmountAfterDiscountShowed__c * rateUSD) / rateOrder;
                    order.TotalAmountAfterDiscountJPY__c = (order.TotalAmountAfterDiscountShowed__c * rateJPY) / rateOrder;
                    order.TotalAmountAfterDiscountGBP__c = (order.TotalAmountAfterDiscountShowed__c * rateGBP) / rateOrder;  
                    
                    if(order.Provenance__c == 'ShareIt'){
                        Decimal nbOrderProducts = order.NbOrderItems__c;
                    
                        Decimal priceFraisShareIt = (0.75 * rateUSD) / rateEUR;
                        order.Frais_ShareItUSD__c = priceFraisShareIt * nbOrderProducts + 0.049 * order.TotalAmountAfterDiscountUSD__c;
                        
                        priceFraisShareIt = (0.75 * rateJPY) / rateEUR;
                        order.Frais_ShareItJPY__c = priceFraisShareIt * nbOrderProducts + 0.049 * order.TotalAmountAfterDiscountJPY__c;
                          
                        priceFraisShareIt = (0.75 * rateGBP) / rateEUR;
                        order.Frais_ShareItGBP__c = priceFraisShareIt * nbOrderProducts + 0.049 * order.TotalAmountAfterDiscountGBP__c;
                        
                        Decimal priceFraisShareItEUR = (0.75 * rateEUR) / rateEUR;
                        order.Frais_ShareItEUR__c = priceFraisShareItEUR* nbOrderProducts + 0.049 * order.TotalAmountAfterDiscountEUR__c;   
                    }                                                                           
                }
            }
        }
    }
    
    public PageReference UpdateOrders(){
        List<List<Order>> ordersToUpdate = new List<List<Order>>();
        
        List<Order> os = new List<Order>();
        Integer max = this.orders.size() >= 2000 ? 2000 : this.orders.size();
        for(Integer i = 0; i < max; i++){
            Order order = this.orders[i];     
            
            os.add(order);
        }
        
        for(Integer i = 0; i < max; i++){
            this.orders.remove(0);
        }
        
        ordersToUpdate.add(os);
        
        for(List<Order> o : ordersToUpdate){
            update o;
        }
        
        return null;
    }
}