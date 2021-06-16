@isTest
private class InsertExchangeRatesFromWebServiceTest {
     @isTest static void testCallout() {
        Test.setMock(HttpCalloutMock.class, new MockInsertExchangeRatesFromWebService ());
        
        Account account = new Account();
        account.Name = 'test';
        account.Type = 'Company';
        
        insert account;
        
        Order order = new Order();
        order.EffectiveDate = Date.today();
        order.AccountId = account.Id;
        order.Status = 'Version préliminaire';
        
        insert order;
        
        Test.startTest();
        InsertExchangeRatesFromWebService.InsertRates();
        Test.stopTest();
        
        Map<Date, Map<String, Currencies_Exchange_Rates__c>> exchangeRatesByCurrency = new Map<Date, Map<String, Currencies_Exchange_Rates__c>>();
        for(Currencies_Exchange_Rates__c exchangeRate : [SELECT CurrencyIsoCode, Day__c, Rate__c FROM Currencies_Exchange_Rates__c]){
            if(exchangeRatesByCurrency.containsKey(exchangeRate.Day__c)){
                exchangeRatesByCurrency.get(exchangeRate.Day__c).put(exchangeRate.CurrencyIsoCode, exchangeRate);
            }else{
                Map<String, Currencies_Exchange_Rates__c> rates = new Map<String, Currencies_Exchange_Rates__c>();
                rates.put(exchangeRate.CurrencyIsoCode, exchangeRate);
                exchangeRatesByCurrency.put(exchangeRate.Day__c, rates);
            }
        }
        
        System.assertEquals(exchangeRatesByCurrency.keySet().size(), 5);
        Map<String, Currencies_Exchange_Rates__c> exchangeRatesByCurrencyCurrentDate = exchangeRatesByCurrency.get(Date.today());
        System.assertEquals(exchangeRatesByCurrencyCurrentDate.size(), 3);
        System.assertEquals(exchangeRatesByCurrencyCurrentDate.containsKey('USD'), true);
        System.assertEquals(exchangeRatesByCurrencyCurrentDate.containsKey('JPY'), true);
        System.assertEquals(exchangeRatesByCurrencyCurrentDate.containsKey('GBP'), true);                        
        System.assertNotEquals(exchangeRatesByCurrencyCurrentDate.get('GBP').Rate__c, null);   
        System.assertNotEquals(exchangeRatesByCurrencyCurrentDate.get('USD').Rate__c, null);   
        System.assertNotEquals(exchangeRatesByCurrencyCurrentDate.get('JPY').Rate__c, null);  
        System.assertNotEquals(exchangeRatesByCurrencyCurrentDate.get('USD').Day__c, null);   
        System.assertNotEquals(exchangeRatesByCurrencyCurrentDate.get('JPY').Day__c, null);   
        System.assertNotEquals(exchangeRatesByCurrencyCurrentDate.get('GBP').Day__c, null);                                                                                
    }
}