@IsTest
public class Test_PaymentStripeFacade {
    
    @IsTest
    public static void testPay() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStatusCode(200);
        mock.setStaticResource('jsonStripeWebHook'); // La réponse du WS n'a pas d'importance
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, mock);
        
        // create an order
        RecordType personAccountRecordType =  [SELECT Id FROM RecordType WHERE Name = 'Compte personnel' and SObjectType = 'Account'];
        Account newPersonAccount = new Account();
        newPersonAccount.FirstName = 'Fred';
        newPersonAccount.LastName = 'Smith';
        newPersonAccount.RecordType = personAccountRecordType;
        insert newPersonAccount;
        
        HelperTestData.createOrderWithProductWithPersonalAccount(newPersonAccount);
        Order order = [select Montant_Hors_Frais__c,CurrencyIsoCode,customerToken__c,OrderNumber from Order limit 1];
        
        Test.startTest();
        new PaymentStripeFacadeQueuable(order).execute(null);
        Test.stopTest();
    }  
}