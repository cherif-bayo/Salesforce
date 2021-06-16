trigger RatesUpdated on Currencies_Exchange_Rates__c (after update, after insert) {
    private static Decimal CURRENCY_EUR_RATE = 1.00;
    
    private static String CURRENCY_EUR = 'EUR';    
    private static String CURRENCY_USD = 'USD';
    private static String CURRENCY_JPY = 'JPY';
    private static String CURRENCY_GBP = 'GBP';

    Map<Date, Map<String, Decimal>> ratesByDateByCurrency = new Map<Date, Map<String, Decimal>>();
    for(Currencies_Exchange_Rates__c exchangeRates : Trigger.new){
        if(ratesByDateByCurrency.containsKey(exchangeRates.Day__c)){
            ratesByDateByCurrency.get(exchangeRates.Day__c).put(exchangeRates.CurrencyIsoCode, exchangeRates.Rate__c);
        }else{
            Map<String, Decimal> ratesByIsoCode = new Map<String, Decimal>();
            ratesByIsoCode.put(exchangeRates.CurrencyIsoCode, exchangeRates.Rate__c);
            ratesByDateByCurrency.put(exchangeRates.Day__c, ratesByIsoCode);
        }
    }
    
    Order[] orders = [SELECT Frais_ShareItGBP__c, Frais_ShareItEUR__c, Frais_ShareItJPY__c, Frais_ShareItUSD__c, Frais_ShareIt__c, NbOrderItems__c, Provenance__c, CurrencyIsoCode, EffectiveDate, TotalAmountAfterDiscountShowed__c, TotalAmountAfterDiscountEUR__c, TotalAmountAfterDiscountUSD__c, TotalAmountAfterDiscountJPY__c , TotalAmountAfterDiscountGBP__c FROM Order WHERE EffectiveDate in :ratesByDateByCurrency.keySet()];
    
    for(Order order : orders){
        Map<String, Decimal> ratesByCurrency = ratesByDateByCurrency.get(order.EffectiveDate);
        if(ratesByCurrency.containsKey(order.CurrencyIsoCode)){
            Decimal rateOrder = CURRENCY_EUR_RATE;
            if(order.CurrencyIsoCode != CURRENCY_EUR){
                rateOrder = ratesByCurrency.get(order.CurrencyIsoCode);
            }
            Decimal rateEUR = CURRENCY_EUR_RATE;
            Boolean orderIsShareIt = order.Provenance__c == 'ShareIt';
            Integer nbOrderProducts = Integer.valueof(order.NbOrderItems__c);
            if(ratesByCurrency.containsKey(CURRENCY_USD)){
                Decimal rateUSD = ratesByCurrency.get(CURRENCY_USD);
                order.TotalAmountAfterDiscountUSD__c = (order.TotalAmountAfterDiscountShowed__c * rateUSD) / rateOrder;
                
                if(orderIsShareIt){
                    Decimal priceFraisShareIt = (0.75 * rateUSD) / rateEUR;
                    
                    order.Frais_ShareItUSD__c = priceFraisShareIt * nbOrderProducts + 0.049 * order.TotalAmountAfterDiscountUSD__c;
                } 
            }
            if(ratesByCurrency.containsKey(CURRENCY_JPY)){
                Decimal rateJPY = ratesByCurrency.get(CURRENCY_JPY);
                order.TotalAmountAfterDiscountJPY__c = (order.TotalAmountAfterDiscountShowed__c * rateJPY) / rateOrder;
                
                if(orderIsShareIt){
                    Decimal priceFraisShareIt = (0.75 * rateJPY) / rateEUR;
                    
                    order.Frais_ShareItJPY__c = priceFraisShareIt * nbOrderProducts + 0.049 * order.TotalAmountAfterDiscountJPY__c;
                }  
            }
            if(ratesByCurrency.containsKey(CURRENCY_GBP)){
                Decimal rateGBP = ratesByCurrency.get(CURRENCY_GBP);  
                                                              
                order.TotalAmountAfterDiscountGBP__c = (order.TotalAmountAfterDiscountShowed__c * rateGBP) / rateOrder;       
                
                if(orderIsShareIt){
                    Decimal priceFraisShareIt = (0.75 * rateGBP) / rateEUR;
                    
                    order.Frais_ShareItGBP__c = priceFraisShareIt * nbOrderProducts + 0.049 * order.TotalAmountAfterDiscountGBP__c;
                }                                         
            }
            order.TotalAmountAfterDiscountEUR__c = (order.TotalAmountAfterDiscountShowed__c * rateEUR) / rateOrder;
            
            if(orderIsShareIt){
                Decimal priceFraisShareIt = (0.75 * rateOrder) / rateEUR;
                Decimal priceFraisShareItEUR = (0.75 * rateEUR) / rateEUR;
                
                order.Frais_ShareIt__c = priceFraisShareIt * nbOrderProducts + 0.049 * order.TotalAmountAfterDiscountShowed__c;
                order.Frais_ShareItEUR__c = priceFraisShareItEUR* nbOrderProducts + 0.049 * order.TotalAmountAfterDiscountEUR__c;
            }
        }
    }
    
    update orders;
}