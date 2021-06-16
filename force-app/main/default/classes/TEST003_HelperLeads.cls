@isTest
public class TEST003_HelperLeads {

    @isTest
    public static void testcreateLead() {
        
        Date dt = Date.newInstance(1960, 2, 17);
        
        Test.startTest();
        CL003_HelperLeads.createLead(dt, 'firstName', 'lastName','email@email.fr', '060606060606', 
                                     'FR', 'company','langue', 'domainCode','position');
        Test.stopTest();

		Lead lead = [select Date_premier_telechargement__c,Date_dernier_telechargement__c,firstName,lastName,email,phone,countryCode,
                     company,Langue__c,domain__c,Position__c from Lead Limit 1];
        
        System.assertEquals(dt, lead.Date_premier_telechargement__c);
        System.assertEquals(dt, lead.Date_dernier_telechargement__c);
        System.assertEquals('firstName', lead.firstName);
        System.assertEquals('lastName', lead.lastName);
        System.assertEquals('email@email.fr', lead.email);
        System.assertEquals('060606060606', lead.phone);
        System.assertEquals('FR', lead.countryCode);
        System.assertEquals('company', lead.company);
        System.assertEquals('langue', lead.Langue__c);
        System.assertEquals('position', lead.Position__c);
        System.assert(lead.domain__c == null);
    }
    
    @isTest
    public static void testUpdateLead() {
        
        Date dt = Date.newInstance(1960, 2, 17);
        Lead lead = new Lead(LastName='test');
        
        insert lead;
        
        Test.startTest();
        CL003_HelperLeads.updateLead(lead, dt, 'firstName', 'lastName','domainCode');
        Test.stopTest();

		Lead lead2 = [select Date_premier_telechargement__c,Date_dernier_telechargement__c,firstName,lastName,domain__c,LeadSource from Lead Limit 1];
        
        System.assertEquals(dt, lead2.Date_premier_telechargement__c);
        System.assertEquals(dt, lead2.Date_dernier_telechargement__c);
        System.assertEquals('firstName', lead2.firstName);
        System.assertEquals('lastName', lead2.lastName);
        System.assertEquals(CL003_Constants.ORIGINE_DOWNLOAD, lead2.LeadSource);
        System.assert(lead2.domain__c == null);
    }    
}