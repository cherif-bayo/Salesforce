@isTest
public class TEST001_LeadQualification {
    
    @testSetup
    public static void setup() {
        Lead lead = new Lead(email='test@test.fr', firstName='test',lastName='test',numoKey__c ='d0e8');
        insert lead;
    }
    
    @isTest
    public static void testLeadQualificationOk() {
        Test.startTest();
        Lead lead = WS001_LeadQualification.doPost('d0e8',1,'pca','XLSTAT-PSY',Date.today());
        Test.stopTest();
        
        System.assertEquals(1,lead.score__c);
        System.assertEquals('pca',lead.AnalysesFrequentes__c);
        System.assertEquals('XLSTAT-PSY',lead.solutionPreconisee__c);
        System.assertEquals(Date.today(),lead.dateActivationTrial__c);
    }    
}