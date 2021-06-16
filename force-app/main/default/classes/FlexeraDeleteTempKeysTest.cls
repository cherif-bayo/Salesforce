@IsTest(seeAllData=false)
public class FlexeraDeleteTempKeysTest{   
    public static testMethod void testBatchable(){  
        Contact contact = new Contact();
        contact.FirstName = 'Test';
        contact.LastName = 'Test';
        contact.Email = 'test@gmail.com';
        
        insert contact;
      
        Flexera_Key__c key1 = new Flexera_Key__c();
        key1.Name = 'Test';
        key1.Date_Limite__c = Date.today();
        key1.XLSTAT_Solution__c = 'XLSTAT-Base';
        key1.Modules_Nalpeiron__c = 'XLSTAT-Base, 3DPlot, CCR';
        key1.Contact__c = contact.Id;
        key1.Domaine_Utilisateur__c = 'Campus';
        key1.Quantity__c = 990;
        
        insert key1;
        
        Flexera_Key__c key2 = new Flexera_Key__c();
        key2.Name = 'Test';
        key2.Date_Limite__c = Date.today();
        key2.XLSTAT_Solution__c = 'XLSTAT-Base';
        key2.Modules_Nalpeiron__c = 'XLSTAT-Base, LG';
        key2.Contact__c = contact.Id;   
        key2.Domaine_Utilisateur__c = 'Company';
        key2.Quantity__c = 990;     
        
        insert key2;
   
        Test.StartTest();        
        Database.executeBatch(new FlexeraDeleteTempKeysBatchable (), 200);
        Test.StopTest();
        
        Flexera_Key__c[] flexeraKey1 = [SELECT Id FROM Flexera_Key__c];
        
        System.assertEquals(0,flexeraKey1.size());
    }
}