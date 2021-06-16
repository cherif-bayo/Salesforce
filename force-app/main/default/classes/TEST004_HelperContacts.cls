@isTest
public class TEST004_HelperContacts {

    @isTest
    public static void testUpdateContactWithDateDownload() {
        Contact ct = new Contact(LastName='test');
        insert ct;
        
        Date dt = Date.newInstance(1960, 2, 17);
            
        Test.startTest();
        CL004_HelperContacts.updateContactWithDateDownload(ct,dt);
        Test.stopTest();
        
        Contact ct2  = [Select Piste_date_dernier_t_l_chargement__c,Piste_premier_telechargement__c,LeadSource from Contact limit 1];
        System.assertEquals(CL003_Constants.ORIGINE_DOWNLOAD,ct2.LeadSource);
        System.assertEquals(dt,ct2.Piste_date_dernier_t_l_chargement__c);
        System.assertEquals(dt,ct2.Piste_premier_telechargement__c);        
    }
    
}