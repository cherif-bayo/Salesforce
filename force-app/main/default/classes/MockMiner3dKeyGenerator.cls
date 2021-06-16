@isTest
global class MockMiner3dKeyGenerator implements HttpCalloutMock {

    global HTTPResponse respond(HTTPRequest req) {
       
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"licenseKey": "LsA8","activationKey": "Jd"}');
        res.setStatusCode(200);
        return res;
    }
}