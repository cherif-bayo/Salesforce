@isTest
public class Test_AnnualLicenseAutomaticRenewal {
    
    @testSetup
    public static void setUp() {
        RecordType personAccountRecordType =  [SELECT Id FROM RecordType WHERE Name = 'Compte personnel' and SObjectType = 'Account'];
        Account newPersonAccount = new Account();
        newPersonAccount.FirstName = 'Fred';
        newPersonAccount.LastName = 'Smith';
        newPersonAccount.RecordType = personAccountRecordType;
        insert newPersonAccount;
        
        HelperTestData.createOrderWithProductWithPersonalAccount(newPersonAccount);
        Order order = [select Montant_Hors_Frais__c,CurrencyIsoCode,customerToken__c,OrderNumber from Order limit 1];        
        order.paymentType__c = ParametersForOrders.BILLING_CARD;
        order.EffectiveDate = Date.today().addYears(-1);
        order.Renewal_Auto__c = true;
        order.Type_licence__c = ParametersForOrders.SEND_KEY_LICENSE_TYPE_1;
        order.Renouvele__c = false;
        update order;
    }
    
    @isTest
    public static void main() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStatusCode(200);
        mock.setStaticResource('jsonStripeWebHook'); // La réponse du WS n'a pas d'importance
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, mock);
        
        SH001_AnnualLicenseAutomaticRenewalBatch b = new SH001_AnnualLicenseAutomaticRenewalBatch();
        b.execute(null);
    }    
}