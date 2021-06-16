@isTest
public class Test001_NpsResponse {
    
    @isTest
    public static void testNpsResponseOk() {
        Test.startTest();
        WS001_NpsResponse.doPost('test@xlstat.com',10, false, true, '2020.2.1', 'happy to use your software', 'ACA81A-C91C4C-42C3BD-C5056F-58718D-076907', 'EN');
        Test.stopTest();
        
        Reponse_Nps__c npsResponse = [SELECT Id, email__c, 	Nps_Consentment__c, Nps_Note__c, Already_Contacted__c, Xlstat_Version__c, User_Comments__c, User_Key_Number__c, User_Language__c FROM Reponse_Nps__c LIMIT 1];
        
        System.assertEquals(10,npsResponse.Nps_Note__c);
        System.assertEquals('test@xlstat.com',npsResponse.email__c);
        System.assertEquals(false,npsResponse.Nps_Consentment__c);
        System.assertEquals(true,npsResponse.Already_Contacted__c);
        System.assertEquals('2020.2.1',npsResponse.Xlstat_Version__c);
        System.assertEquals('happy to use your software',npsResponse.User_Comments__c);
        System.assertEquals('ACA81A-C91C4C-42C3BD-C5056F-58718D-076907',npsResponse.User_Key_Number__c);
        System.assertEquals('EN',npsResponse.User_Language__c);
     
        
    }    
}