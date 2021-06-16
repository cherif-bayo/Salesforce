@isTest
public class OrderCheckPersonCompanyDomainTest{
    public static testMethod void testMain() {
        Account account = new Account();
        account.FirstName = 'Test';
        account.LastName = 'Test';
        account.PersonEmail = 'test@test.com';
        
        insert account;
        
        Contact contact2 = new Contact();
        contact2.Email = 'test@test2.com';
        contact2.FirstName = 'Test';
        contact2.LastName = 'Test';
        
        insert contact2;
    
        Order order = new Order();
        order.AccountId = account.Id;
        order.Client_Final__c = contact2.Id;
        order.EffectiveDate = Date.today();
        order.Domaine_Utilisateur__c = 'Company';
        order.Status = 'Version préliminaire';
        order.HasPersonAccountAndCompanyDomain__c = true;
        
        insert order;
        
        Domaine_general__c domaine = new Domaine_general__c();
        domaine.Name = 'test2';
        
        insert domaine;
        
        Domaine_general__c domaine2 = new Domaine_general__c();
        domaine2.Name = 'test.com';
        
        insert domaine2;
        
        Test.StartTest();        
        Database.executeBatch(new OrderCheckPersonCompanyDomainBatchable(), 1);
        Test.StopTest();
        
        order = [SELECT HasPersonAccountAndCompanyDomain__c FROM Order WHERE Id = :order.Id];
        
        System.assertEquals(false, order.HasPersonAccountAndCompanyDomain__c);
        
        String jobId = System.schedule('ScheduleApexClassTest', '0 0 0 15 3 ? 2022', new OrderCheckPersonCompanyDomainSchedulable());
    }
}