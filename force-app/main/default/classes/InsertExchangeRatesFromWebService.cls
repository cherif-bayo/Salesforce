global class InsertExchangeRatesFromWebService{
    private class RatesJson{
        public Decimal USDEUR;
        public Decimal USDJPY;
        public Decimal USDGBP;                
    }

    @future(callout=true)
    public static void InsertRates(){
        Set<String> currencies = new Set<String>(); 
        for(CurrencyType currencyType : [SELECT IsoCode FROM CurrencyType WHERE IsActive=true]){
            currencies.add(currencyType.IsoCode);
        }
     
        Http h = new Http();
        HttpRequest req = new HttpRequest();
    
        req.setEndpoint('http://apilayer.net/api/live?access_key=4cd6c853366853eaf77eedb1b78c6eba&source=USD&currencies=EUR,JPY,GBP');
        req.setMethod('GET');
        HttpResponse res = h.send(req);
        
        JSONParser parser = JSON.createParser(res.getBody());
        
        RatesJson rates;
        DateTime ratesTime;
        while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) &&
                (parser.getText() == 'quotes')) {
                parser.nextToken();
                
                rates = (RatesJson)parser.readValueAs(RatesJson.class);
                
                parser.skipChildren();
            }else if((parser.getCurrentToken() == JSONToken.FIELD_NAME) &&
                (parser.getText() == 'timestamp')){
                parser.nextToken();
                
                ratesTime = DateTime.newInstance(parser.getDoubleValue().longValue() * 1000);
            }
        }
        
        Decimal rateEur = 1;
        Decimal rateUSD = 1/rates.USDEUR;
        Decimal rateGBP = rates.USDGBP/rates.USDEUR;
        Decimal rateJPY = rates.USDJPY/rates.USDEUR;
        
        Map<String, Decimal> ratesByCurrency = new Map<String, Decimal>();
        ratesByCurrency.put('USD', rateUSD);
        ratesByCurrency.put('GBP', rateGBP);
        ratesByCurrency.put('JPY', rateJPY);                
        
        Date ratesDate = ratesTime.date();
        Currencies_Exchange_Rates__c[] existingRates = [SELECT Rate__c, CurrencyIsoCode, Day__c FROM Currencies_Exchange_Rates__c WHERE Day__c >= :ratesDate];
        Date maxDateRate;
        for(Currencies_Exchange_Rates__c rate : existingRates){
            rate.Rate__c = ratesByCurrency.get(rate.CurrencyIsoCode);
            if(maxDateRate == null || maxDateRate < rate.Day__c){
                maxDateRate = rate.Day__c;
            }
        }        
        
        update existingRates;
        
        List<Currencies_Exchange_Rates__c> ratesToInsert = new List<Currencies_Exchange_Rates__c>();
        Integer nbRatesDaysToInsert = 5;
        if(maxDateRate != null){
            nbRatesDaysToInsert = nbRatesDaysToInsert - Math.abs(maxDateRate.daysBetween(ratesDate)) - 1;
        }else{
            maxDateRate = Date.today().addDays(-1);    
        }
        
        ratesDate = maxDateRate.addDays(1);
        for(Integer i = 0; i < nbRatesDaysToInsert; i++){
            for(String currencyRate : ratesByCurrency.keySet()){
                Currencies_Exchange_Rates__c exchangeRate = new Currencies_Exchange_Rates__c();
                exchangeRate.Day__c = ratesDate;
                exchangeRate.Rate__c = ratesByCurrency.get(currencyRate);
                exchangeRate.CurrencyIsoCode = currencyRate;
                
                ratesToInsert.add(exchangeRate);
            }
            
            ratesDate = ratesDate.addDays(1);
        }
        
        insert ratesToInsert;
    }
}