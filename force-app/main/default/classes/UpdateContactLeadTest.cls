@IsTest(seeAllData=false)
public class UpdateContactLeadTest{
    public static testMethod void testBatch() {    
        List<Lead> leads = new List<Lead>();
        List<Contact> contacts = new List<Contact>();      
        List<Account> accounts = new List<Account>();                
        for(Integer i = 0; i < 100; i++){
            String email = 'test@test.com' + String.valueof(i);
        
            Lead lead = new Lead();
            lead.LastName = 'Test';
            lead.Email = email;
            lead.Company = 'Default company';
            
            leads.add(lead);
            
            Contact contact = new Contact();
            contact.Email = email;
            contact.LastName = 'Test';
            
            Account account = new Account();
            account.LastName = 'test';
            account.PersonEmail = email;
            
            accounts.add(account);
            
            contacts.add(contact);
        }
        insert leads;
        insert contacts;    
        insert accounts;
        
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
        
        List<Telechargement__c> telechargements = new List<Telechargement__c>();
        for(Integer i = 0; i < 100; i++){
            Telechargement__c telechargement = new Telechargement__c();
            telechargement.Lead__c = leads[i].Id;
            telechargement.Systeme_d_exploitation_version_extension__c = ext.Id;
            
            telechargements.add(telechargement);
        }
        insert telechargements;
        
        Test.StartTest();        
        Database.executeBatch(new UpdateContactLead(), 200);
        Test.StopTest();
        
        System.AssertEquals(database.countquery('SELECT COUNT() FROM Contact WHERE Piste_date_cr_ation__c != null AND Piste_nombre_de_t_l_chargements__c = 1'), 100);
         //System.AssertEquals(database.countquery('SELECT COUNT() FROM Account WHERE Piste_date_cr_ation__pc != null AND Piste_nombre_de_t_l_chargements__pc = 1'), 41);        
        System.AssertEquals(database.countquery('SELECT COUNT() FROM Lead'), 100);
        System.AssertEquals(database.countquery('SELECT COUNT() FROM Telechargement__c WHERE Lead__c != null'), 0);
        System.AssertEquals(database.countquery('SELECT COUNT() FROM Telechargement__c WHERE Contact__c != null'), 100);
        
        String jobId = System.schedule('ScheduleApexClassTest', '0 0 0 15 3 ? 2022', new UpdateContactLeadSchedulable());
   }
}