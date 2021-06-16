@isTest (SeeAllData=false)

public class WebserviceXLSTAT365Tests{
    public static testMethod void testLead() {
        String email = Label.emailAdmin;
        String versionTest = Label.TestVersion;
        

        Test.startTest();
        WebServiceXLSTAT365.createUser(email, versionTest, 'en');
        WebServiceXLSTAT365.createUser(email, versionTest, 'fr');        
        Test.stopTest();
        
        Lead[] lead = [SELECT Id, IsXLSTAT365__c FROM Lead WHERE email = :email];
        XLSTAT_365_Version__c[] version = [SELECT Id FROM XLSTAT_365_Version__c];
        XLSTAT_365_Activation__c[] activations = [SELECT XLSTAT_365_Activation_Version__c FROM XLSTAT_365_Activation__c WHERE Lead__c = :lead[0].Id];
        
        System.assertEquals(lead.size(), 1);
        System.assertEquals(lead[0].IsXLSTAT365__c, true);
        System.assertEquals(activations.size(), 2);
        System.assertEquals(version.size(), 1);
        System.assertEquals(activations[0].XLSTAT_365_Activation_Version__c, version[0].Id);
    }
    
    public static testMethod void testContact() {
        String email = Label.emailAdmin;
        String TestFirstName = Label.ContactTestFirstName;
        String TestLastName = Label.ContactTestLastName;
        String versionTest = Label.TestVersion;
    
        Contact c = new Contact();
        c.FirstName = TestFirstName;
        c.LastName = TestLastName;
        c.Email = email;
        
        insert c;
    
        Test.startTest();
        WebServiceXLSTAT365.createUser(email, versionTest, 'en');      
        Test.stopTest();
        
        Lead[] lead = [SELECT Id, IsXLSTAT365__c FROM Lead WHERE email = :email];
        Contact contact = [SELECT Id, XLSTAT_365__c FROM Contact WHERE email = :email];        
        XLSTAT_365_Version__c[] version = [SELECT Id FROM XLSTAT_365_Version__c];
        XLSTAT_365_Activation__c[] activations = [SELECT XLSTAT_365_Activation_Version__c FROM XLSTAT_365_Activation__c WHERE Contact__c = :contact.Id];
        
        System.assertEquals(lead.size(), 0);
        System.assertEquals(contact.XLSTAT_365__c, true);
        System.assertEquals(activations.size(), 1);
        System.assertEquals(version.size(), 1);
        System.assertEquals(activations[0].XLSTAT_365_Activation_Version__c, version[0].Id);
    }
}