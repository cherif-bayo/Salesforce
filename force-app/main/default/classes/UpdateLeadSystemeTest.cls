@IsTest(seeAllData=false)
public class UpdateLeadSystemeTest {   
   public static testMethod void testSchedulable(){
       Lead lead = new Lead();
       lead.FirstName = 'Test';
       lead.LastName = 'Test';
       lead.Email = 'test@test.com';
       
       insert lead;
       
        Systeme_d_exploitation__c os = new Systeme_d_exploitation__c();
        os.Name = 'test';
        insert os;
        
        Systeme_d_exploitation_version__c version = new Systeme_d_exploitation_version__c();
        version.Name = 'test';
        version.Systeme_d_exploitation__c = os.Id;
        insert version;
        
        Systeme_d_exploitation_version_extension__c ext = new Systeme_d_exploitation_version_extension__c();
        ext.Name = 'test';
        ext.Systeme_d_exploitation_version__c = version.Id;
        insert ext;
        
        Telechargement__c telechargement = new Telechargement__c();
        telechargement.Lead__c= lead.Id;
        telechargement.Systeme_d_exploitation_version_extension__c = ext.Id;
        
        insert telechargement;
        
        lead.Systeme_d_exploitation__c = null;
        update lead;
        
        Test.StartTest();        
        Database.executeBatch(new UpdateLeadSystemeBatchable(), 200);
        Test.StopTest();
        
        Lead[] leads = [SELECT Id FROM Lead WHERE Systeme_d_exploitation__c != null];
        System.AssertEquals(leads.size(), 1);
   }
}