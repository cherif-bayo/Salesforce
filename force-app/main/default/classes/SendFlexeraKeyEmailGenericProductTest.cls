@IsTest
private class SendFlexeraKeyEmailGenericProductTest {

    @TestSetup
    static void setup() {
        Account a = new Account();
        a.Name = 'Test Account';
        insert a;

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

        Order order = new Order();
        order.AccountId = a.Id;
        order.Client_Final__c = c.Id;
        order.EffectiveDate = Date.today();
        order.Domaine_Utilisateur__c = 'Company';
        order.Status = 'Version préliminaire';
        order.HasPersonAccountAndCompanyDomain__c = true;
        insert order;

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
        key01.XLSTAT_Solution__c = 'XLRISK';
        key01.Software__c='XLRisk';
        key01.SoftwareCode__c = '01';
        key01.Is_Network__c = false;
        key01.Order__c = order.Id;
        insert key01;
    }

    @IsTest
    static void testSend() {
        Flexera_Key__c flexeraKey = [
                SELECT Software__c, SoftwareCode__c, XLSTAT_Solution__c, Name, Type_licence__c, Domaine_utilisateur__c, Contact__c, Order__c
                FROM Flexera_Key__c
                LIMIT 1
        ];
        Order order = [SELECT Id FROM Order WHERE Id = :flexeraKey.Order__c];
        Test.startTest();
        SendFlexeraKeyEmailGenericProduct sender = new SendFlexeraKeyEmailGenericProduct(false, flexeraKey, order);
        sender.Send();
        Test.stopTest();
    }
}