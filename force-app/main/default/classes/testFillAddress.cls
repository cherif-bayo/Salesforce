@isTest
public class testFillAddress{
    
    @testSetup
    public static void setup() {
        Account acc = new Account(Name = 'test', BillingCountryCode = 'GB',ShippingCountryCode = 'GB', Import_Auto__c = true);
        insert acc;
        
        Contact ct = new Contact (LastName = 'test', AccountId = acc.Id, MailingCountryCode = 'GB', Import_Auto__c = true);
        insert ct;
    }
    
    @isTest
     public static void testProAccounts(){
         FillAddressControllerProAccounts controller = new FillAddressControllerProAccounts();
             controller.AddAddressToProAccounts();           
     }
     
    @isTest
     public static void testPersonAccount(){
         FillAddressControllerPersonAccounts controller = new FillAddressControllerPersonAccounts();
             controller.AddAddressToPersonAccounts();        
     }
     
    @isTest
     public static void testOrders(){
         FillAddressControllerOrders controller = new FillAddressControllerOrders();
             controller.AddAddressToOrders();          
     }
}