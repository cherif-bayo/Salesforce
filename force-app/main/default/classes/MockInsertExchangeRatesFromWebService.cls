@isTest
global class MockInsertExchangeRatesFromWebService implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        System.assertEquals('http://apilayer.net/api/live?access_key=4cd6c853366853eaf77eedb1b78c6eba&source=USD&currencies=EUR,JPY,GBP', req.getEndpoint());
        System.assertEquals('GET', req.getMethod());
        
        Date dateToday = Date.today();
        
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"success":true,"terms":"https://currencylayer.com/terms","privacy":"https://currencylayer.com/privacy","timestamp":'+(DateTime.now().getTime() / 1000)+',"source":"USD","quotes":{"USDEUR":0.932601,"USDJPY":108.739998,"USDGBP":0.77967}}');
        res.setStatusCode(200);
        return res;
    }
}