@IsTest
public class WelcomePackagePlaquetteInsertTest{
    @IsTest static void testMain(){
        Test.startTest();
        WelcomePackagePlaquetteInsert.InsertPlaquettes();
        Test.stoptest();
        
        System.assertEquals(150, [SELECT Id FROM Plaquette__c].size());
    }
}