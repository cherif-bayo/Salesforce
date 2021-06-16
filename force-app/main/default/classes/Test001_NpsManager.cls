@isTest
public class Test001_NpsManager {
    
    @testSetup
    public static void setup() {
       	Contact ct = new Contact(Lastname = 'lastName', Email = 'email@gmail.com');
        insert ct;
        
        Lead ld = new Lead(email='testLead@test.fr', firstName='testLead',lastName='testLead');
        insert ld;
        Flexera_Key__c key = new Flexera_Key__c();
        key.Contact__c = ct.Id;
        key.Lead__c = ld.Id;
        key.Quantity__c = 1;
        key.Name = 'test';
        
        insert key;
    }
    
    @isTest
    public static void testNpsManagerOk() {
        RestRequest request = new RestRequest();
     
        request.requestUri =
            'https://addinsoft--sb1.cs85.my.salesforce.com/services/apexrest/NpsManager/test';
        request.httpMethod = 'GET';
        RestContext.request = request;
        
        Test.startTest();
        String email = WS001_NpsManager.doGet();
        Test.stopTest();
        
         System.assertEquals(email,'email@gmail.com');
                
    } 
    
    @isTest
    public static void testNpsManagerKO() {
        RestRequest request = new RestRequest();
     
        request.requestUri =
            'https://addinsoft--sb1.cs85.my.salesforce.com/services/apexrest/NpsManager/pascle';
        request.httpMethod = 'GET';
        RestContext.request = request;
        
        Test.startTest();
        String email = WS001_NpsManager.doGet();
        Test.stopTest();
        
         System.assertEquals(email,'');
                
    }   
}