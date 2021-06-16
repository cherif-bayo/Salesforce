@isTest
public class LeadToContactOrPersonAccountTest{
    public static testMethod void testContact(){
        Account account = new Account();
        account.Name = 'Test';
        
        insert account;
    
        Lead lead = new Lead();
        lead.FirstName = 'Test';
        lead.LastName = 'Test';
        lead.Email = 'test@xlstat.com';
        
        insert lead;
        
        Telechargement__c telechargement = new Telechargement__c();
        telechargement.Lead__c = lead.Id;
        
        insert telechargement;
    
        Test.setCurrentPage(Page.LeadToContactOrPersonAccount);
        Test.startTest();
        LeadToContactOrPersonAccountExtension controller = new LeadToContactOrPersonAccountExtension(new ApexPages.StandardController(lead));
        controller.ConversionType = LeadToContactOrPersonAccountExtension.CONTACT_OPTION;
        controller.Order.AccountId = account.Id;
        controller.Convert();
        Test.stopTest();
        
        Contact[] contact = [SELECT Id FROM Contact WHERE Email = :lead.Email];
        
        System.assertEquals(1, contact.size());
        
        telechargement = [SELECT Id FROM Telechargement__c WHERE Contact__c = :contact[0].Id];
        
        System.assertNotEquals(null, telechargement);
    }
    
    public static testMethod void testAccount(){    
        Lead lead = new Lead();
        lead.FirstName = 'Test';
        lead.LastName = 'Test';
        lead.Email = 'test@xlstat.com';
        
        insert lead;
        
        Telechargement__c telechargement = new Telechargement__c();
        telechargement.Lead__c = lead.Id;
        
        insert telechargement;
    
        Test.setCurrentPage(Page.LeadToContactOrPersonAccount);
        Test.startTest();
        LeadToContactOrPersonAccountExtension controller = new LeadToContactOrPersonAccountExtension(new ApexPages.StandardController(lead));
        controller.ConversionType = LeadToContactOrPersonAccountExtension.ACCOUNT_OPTION;
        controller.Convert();
        Test.stopTest();
        
        Account[] account = [SELECT PersonContactId FROM Account WHERE PersonEmail = :lead.Email];
        
        System.assertEquals(1, account.size());
        
        telechargement = [SELECT Id FROM Telechargement__c WHERE Contact__c = :account[0].PersonContactId];
        
        System.assertNotEquals(null, telechargement);
    }
}