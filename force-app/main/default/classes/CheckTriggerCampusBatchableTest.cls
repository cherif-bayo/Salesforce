@isTest
public class CheckTriggerCampusBatchableTest  {

@TestSetup
static void setup() {
	List<Flexera_Key__c> keys = new List<Flexera_Key__c>();
	//Insert 10 keys
		for (Integer i = 0; i < 10; i++){
			keys.add(new Flexera_Key__c(Name='JHSDJDS458SDGSHGHSD458SGHGV', Quantity__c= 1, Domaine_utilisateur__c = 'Campus'));
		}
		insert keys;
}
 @isTest static void test() {
        Test.startTest();
        CheckTriggerCampusBatchable ctc = new CheckTriggerCampusBatchable();
        Id batchId = Database.executeBatch(ctc);
        Test.stopTest();
        String jobId = System.schedule('ScheduleApexClassTest', '0 0 0 15 3 ? 2022', new CheckTriggerCampusSchedulable());
        // after the testing stops, assert records were updated properly
        System.assertEquals(0, [select count() from Flexera_Key__c where Name = 'JHSDJDS458SDGSHGHSD458SGHGV' and Quantity__c=1 and Domaine_utilisateur__c ='Trial' and Expires90DFromToday__c = true]);
    }
}