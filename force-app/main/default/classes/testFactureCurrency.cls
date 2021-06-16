@isTest(SeeAllData=true)
public class testFactureCurrency{
    public static testMethod void testTrigger(){
        Facture__c facture = [SELECT Id FROM Facture__c limit 1];
        update facture;
    }
}