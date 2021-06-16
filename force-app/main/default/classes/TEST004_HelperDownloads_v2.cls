@isTest
public class TEST004_HelperDownloads_v2 {
    
    @isTest
    public static void testCreateDownloadWithLeadId() {
        Lead lead = new Lead(Company='test',LastName='test');
        insert lead;
        
        Date dt = Date.newInstance(1960, 2, 17);
            
        Test.startTest();
        CL004_HelperDownloads_v2.createDownloadWithLeadId(dt,'macOs',lead.Id);
        Test.stopTest();
        
        Telechargement__c tel  = [Select Date__c,Lead__c,osDownload__c from Telechargement__c limit 1];
        System.assertEquals(lead.Id,tel.Lead__c);
        System.AssertEquals(dt,tel.Date__c);
        System.AssertEquals('macOs',tel.osDownload__c);
    }
    
    @isTest
    public static void testCreateDownloadWithContactId() {
        Contact ct = new Contact(LastName='test');
        insert ct;
        
        Date dt = Date.newInstance(1960, 2, 17);
            
        Test.startTest();
        CL004_HelperDownloads_v2.createDownloadWithContactId(dt,'macOs',ct.Id);
        Test.stopTest();
        
        Telechargement__c tel  = [Select Date__c,Contact__c,osDownload__c from Telechargement__c limit 1];
        System.assertEquals(ct.Id,tel.Contact__c);
        System.AssertEquals(dt,tel.Date__c);
        System.AssertEquals('macOs',tel.osDownload__c);
    }
    
}