@isTest
public class TrialProcessorTest {
    
    @testSetup
    static void setup(){
        List<Flexera_Key__c> leadsTrial = new List<Flexera_Key__c>();
        // delete 200 Trial Keys
        for (Integer i=0;i<200;i++) {
            leadsTrial.add(new Flexera_Key__c(Name='JHSDJDS458SDGSHGHSD458SGHGV', Quantity__c= 1, Domaine_utilisateur__c = 'Trial'));
        }
        insert leadsTrial;
    }
    @isTest static void test() {
        Test.startTest();
        TrialProcessor lp = new TrialProcessor();
        Id batchId = Database.executeBatch(lp);
        Test.stopTest();
        String jobId = System.schedule('ScheduleApexClassTest', '0 0 0 15 3 ? 2022', new TrialProcessorSchedulable());
        // after the testing stops, assert records were updated properly
        System.assertEquals(200, [select count() from Flexera_Key__c where Name = 'JHSDJDS458SDGSHGHSD458SGHGV' and Quantity__c=1 and Domaine_utilisateur__c ='Trial']);
    }

}