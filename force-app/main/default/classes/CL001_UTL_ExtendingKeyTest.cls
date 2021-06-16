/**
 * Test class Extending License key and sending email to user without creating new key.
 */

@IsTest
public with sharing class CL001_UTL_ExtendingKeyTest {

    @TestSetup
    public static void setUp() {
        RecordType personAccountRecordType =  [SELECT Id FROM RecordType WHERE Name = 'Compte personnel' AND SobjectType = 'Account'];
        Account newPersonAccount = new Account();
        newPersonAccount.FirstName = 'Fred';
        newPersonAccount.LastName = 'Smith';
        newPersonAccount.RecordType = personAccountRecordType;
        insert newPersonAccount;

        //Create common test account
        Account a = new Account();
        a.Name = 'Test Account';
        insert a;

        //Create common test contact
        Contact c = new Contact();
        c.FirstName = 'Camille';
        c.LastName = 'Honnet';
        c.AccountId = a.Id;
        c.MailingCountryCode = 'FR';
        c.Email = 'test@test.com';
        insert c;

        List<Software__c> softwares = new List<Software__c>{
                new Software__c(AccessType__c='Multiple', Code__c='00', Name='XLSTAT', DevelopmentDone__c=true, ProductId__c='44affc53-2fc9-4942-a8bb-5f87214c8f0a'),
                new Software__c(AccessType__c='Simple', Code__c='01', Name='XLRISK', ProductId__c='abb8ac81-f3a1-402a-a5e5-e90b444aa933')
        };
        insert softwares;

        HelperTestData.createStandardPriceBook();
        List<Order> orders = new List<Order>();
        for (Integer i=0; i< 1 ; i++) {
            Id orderId = HelperTestData.createNewOrderWithProductWithPersonalAccount(newPersonAccount);
            Order order = [SELECT Montant_Hors_Frais__c,CurrencyIsoCode,customerToken__c,OrderNumber FROM Order WHERE Id= :orderId];
            order.ActivatedDate = Datetime.now().addDays(-5).addHours(-1).addMinutes(5);
            order.Provenance__c = 'Stripe';
            order.Status =  'Payée';
            order.Autorenewalable__c = true;
            order.Type_licence__c = ParametersForOrders.SEND_KEY_LICENSE_TYPE_1;
            order.Renouvele__c = false;
            orders.add(order);
        }
        update orders;

        //Create common test flexera_key
        Flexera_Key__c key01 = new Flexera_Key__c();
        key01.Account__c = a.Id;
        key01.Contact__c = c.Id;
        key01.Date_limite__c = Date.today();
        key01.Quantity__c = 1;
        key01.Expiration__c = 'Expiring';
        key01.Entitlement_Id__c = 'Test';
        key01.Nb_activations_allowed__c = 1;
        key01.Domaine_utilisateur__c = 'Company';
        key01.Type_licence__c = 'Annuelle';
        key01.Date_limite__c = Date.today();
        key01.XLSTAT_Solution__c = 'XLSTAT-Premium';
        key01.Is_Network__c = false;
        insert key01;
    }

    @IsTest
    public static void testKeyExtension() {
        Order order = [SELECT Id, CustomOriginalOrder__c FROM Order LIMIT 1];
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('jsonCryptlexMockLicenceCreation');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        CL001_UTL_ExtendingKey.extend(order);
        Test.stopTest();
        System.assertEquals(order.Status,'Payée');
    }

}