@isTest
global with sharing class ShareItRefundWebServiceImpl implements HTTPCalloutMock{
    global HTTPResponse respond(HTTPRequest req){
        HttpResponse res = new HTTPResponse();
        res.setHeader('Content-Type', 'text/xml');
        res.setBody('<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"><SOAP-ENV:Body><SOAP-ENV:Fault><faultcode>000</faultcode><faultstring>Purchase not payed completely</faultstring><faultactor></faultactor><detail>The Purchase is not payed completely. Please check the PurchaseId</detail></SOAP-ENV:Fault></SOAP-ENV:Body></SOAP-ENV:Envelope>');
        res.setStatusCode(201);
        return res;
    }
}