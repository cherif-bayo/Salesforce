@isTest public class AutocreatedConfigSelfRegTest {
    @isTest static void testMain(){
        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Custom Customer Community User' LIMIT 1];
        
        Map<SObjectField, String> registrationAttributes = new Map<SObjectField, String>{
            User.Email.getDescribe().getSObjectField() => 'martin.lezer@bd.com'
        };
                    
        Test.startTest();
        Id userId = new AutocreatedConfigSelfReg().createUser(acc.Id, p.Id, registrationAttributes, 'testPassword301188');
        Test.stopTest();
    }
    
    @isTest static void testError(){        
        Id profileAdminId = [select Id from Profile where Name = 'System Administrator' limit 1].Id;
       	UserRole role = [SELECT Id FROM UserRole LIMIT 1];
		User uAdmin = new User(Alias = 'standt', Email='martin.lezer@admin.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = profileAdminId, 
            TimeZoneSidKey='America/Los_Angeles', UserName='martin.lezer@admin.com', UserRoleId=role.Id);
        insert uAdmin;
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Custom Customer Community User' LIMIT 1];
        Account acc;
        System.RunAs(uAdmin){
            acc = new Account();
            acc.Name = 'Test';
            insert acc;
            
            Contact c = new Contact();
            c.FirstName= 'Martin';
            c.LastName = 'Lezer';
            c.Email = 'martin.lezer@bd.com';
            c.AccountId = acc.Id;
            insert c;
            
            User u = new User(Alias = 'standt', Email='martin.lezer@bd.com', 
                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US', ProfileId = p.Id, 
                TimeZoneSidKey='America/Los_Angeles', UserName='martin.lezer@bd.com', ContactId = c.Id);
            insert u;
        }
        
        Map<SObjectField, String> registrationAttributes = new Map<SObjectField, String>{
            User.Email.getDescribe().getSObjectField() => 'martin.lezer@bd.com'
        };
                    
        String exceptionMessage;
        Test.startTest();
        try{
        	Id userId = new AutocreatedConfigSelfReg().createUser(acc.Id, p.Id, registrationAttributes, 'testPassword301188');
        }catch(Exception e){
            exceptionMessage = e.getMessage();
        }
        Test.stopTest();
        
        System.assertEquals(Label.Community_Existing_Account, exceptionMessage);
    }
}