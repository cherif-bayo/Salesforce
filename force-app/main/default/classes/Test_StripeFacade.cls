@isTest
public class Test_StripeFacade {
    
    @IsTest
    public static void testRefund() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStatusCode(200);
        mock.setStaticResource('jsonStripeWebHook'); // La réponse du WS n'a pas d'importance
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, mock);
        
        StripeFacade.Refund params = new StripeFacade.Refund();
        params.payment_intent = 'test';
        params.reason = 'test';
        
        Test.startTest();
        StripeFacade.refundCommand(params);
        Test.stopTest();
    }
}