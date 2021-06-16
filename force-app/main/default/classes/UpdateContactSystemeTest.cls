@IsTest(seeAllData=false)
public class UpdateContactSystemeTest {   
   public static testMethod void testSchedulable(){
       Contact contact = new Contact();
       contact.FirstName = 'Test';
       contact.LastName = 'Test';
       contact.Email = 'test@test.com';
       
       insert contact;
       
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
        telechargement.Contact__c = contact.Id;
        telechargement.Systeme_d_exploitation_version_extension__c = ext.Id;
        
        insert telechargement;
        
        contact.Systeme_d_exploitation__c = null;
        update contact;
        
        Test.StartTest();        
        Database.executeBatch(new UpdateContactSystemeBatchable(), 200);
        Test.StopTest();
        
        Contact[] contacts = [SELECT Id FROM Contact WHERE Systeme_d_exploitation__c != null];
        System.AssertEquals(contacts.size(), 1);
        String jobId = System.schedule('ScheduleApexClassTest', '0 0 0 15 3 ? 2022', new UpdateContactSystemeSchedulable());
   }
}