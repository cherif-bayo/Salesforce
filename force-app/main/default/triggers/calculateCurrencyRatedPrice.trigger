trigger calculateCurrencyRatedPrice on Order (before update, before insert) {
    private static Decimal CURRENCY_EUR_RATE = 1.00;
    
    private static String CURRENCY_EUR = 'EUR';    
    private static String CURRENCY_USD = 'USD';
    private static String CURRENCY_JPY = 'JPY';
    private static String CURRENCY_GBP = 'GBP';

    List<Order> ordersToUpdate = new List<Order>();
    List<Date> datesOrders = new List<Date>();
    List<String> ordersCurrencies = new List<String>();
    for(Order order : Trigger.new){
        if(Trigger.isUpdate){
            Decimal oldNbItems = Trigger.oldMap.get(order.Id).NbOrderItems__c;
            Decimal newItems = order.NbOrderItems__c; 
            
            Decimal oldAmount = Trigger.oldMap.get(order.Id).TotalAmountAfterDiscountShowed__c;
            Decimal newAmount = order.TotalAmountAfterDiscountShowed__c;       
            
            String oldProvenance = Trigger.oldMap.get(order.Id).Provenance__c;
            String newProvenance = order.Provenance__c;     
            
            Date oldDate = Trigger.oldMap.get(order.Id).EffectiveDate;
            Date newDate = order.EffectiveDate;        
            
            if(oldAmount != newAmount || (oldProvenance != newProvenance) || oldDate != newDate || oldNbItems != newItems){
                ordersToUpdate.add(order);   
                datesOrders.add(order.EffectiveDate);
                ordersCurrencies.add(order.CurrencyIsoCode);
            }
        }else if(Trigger.isInsert){
            if(order.TotalAmountAfterDiscountShowed__c > 0){
                ordersToUpdate.add(order);   
                datesOrders.add(order.EffectiveDate);                
                ordersCurrencies.add(order.CurrencyIsoCode);
            }
        }
    }
    
    if(ordersToUpdate.size() > 0){        
        Map<Date, Map<String, Decimal>> ratesByDateAndCurrency = new Map<Date, Map<String, Decimal>>();
        for(Currencies_Exchange_Rates__c exchangeRate : [SELECT Rate__c, Day__c, CurrencyIsoCode FROM Currencies_Exchange_Rates__c WHERE Day__c in :datesOrders]){
            if(ratesByDateAndCurrency.containsKey(exchangeRate.Day__c)){
                ratesByDateAndCurrency.get(exchangeRate.Day__c).put(exchangeRate.CurrencyIsoCode, exchangeRate.Rate__c);
            }else{
                Map<String, Decimal> ratesByCurrency = new Map<String, Decimal>();
                ratesByCurrency.put(exchangeRate.CurrencyIsoCode, exchangeRate.Rate__c);
                ratesByDateAndCurrency.put(exchangeRate.Day__c, ratesByCurrency);
            }
        }    
        
        for(Order order : ordersToUpdate){                
            Map<String, Decimal> ratesByCurrency = ratesByDateAndCurrency.get(order.EffectiveDate);
            if(ratesByCurrency != null){
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
                    }else{
                        order.Frais_ShareItEUR__c = 0;
                        order.Frais_ShareItUSD__c = 0;
                        order.Frais_ShareItJPY__c = 0;
                        order.Frais_ShareItGBP__c = 0;
                    }                                       
                }
            }
        }
    }
}