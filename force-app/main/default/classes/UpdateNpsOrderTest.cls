@IsTest(seeAllData=false)
public class UpdateNpsOrderTest {
    public static testmethod void testBatch() {
        List<Reponse_Nps__c> npss = new List<Reponse_Nps__c>();
        List<Flexera_Key__c> keys = new List<Flexera_Key__c>();
        
        for(Integer i = 0; i < 100; i++){
            String keyName = 'DG54DFDF55D4GDGD45DGD5G4D' + String.valueOf(i);
            
            Reponse_Nps__c nps = new Reponse_Nps__c();
            nps.User_Key_Number__c = keyName;
            nps.User_Domain__c = 'Student';
            nps.OrderAmount__c = 254; 
            nps.email__c = 'updateOrder@test.com';
            nps.Nps_Note__c = 8;
            
            npss.add(nps);
            
            Flexera_Key__c key = new Flexera_Key__c();
            key.Name = keyName;
            key.Domaine_utilisateur__c	 = 'Student';
            key.Quantity__c	 = 2;
            
            keys.add(key);
        }
        insert npss;
        insert keys; 
        
        Test.StartTest();        
        Database.executeBatch(new UpdateNpsOrder(), 200);
        Test.StopTest();
        
        String jobId = System.schedule('ScheduleApexClassTest', '0 0 0 15 3 ? 2022', new UpdateNpsOrderSchedulable());
    }
}