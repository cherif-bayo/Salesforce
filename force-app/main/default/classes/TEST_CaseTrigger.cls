@isTest
public class TEST_CaseTrigger {
    
    @testSetup
    public static void setUp() {
		insert new Lead (LastName='test', Email = 'test@test.fr');      

		Account acc = new Account (Name='test');
		insert acc; 

		Contact ct = new Contact(LastName='test', AccountId = acc.Id, email='test2@test.fr');
		insert ct;
    }

    @isTest
    public static void testLeadAssociation() {        
        Case aCase = new Case (Subject = 'test', suppliedEmail='test@test.fr');
        insert aCase;

		aCase = [Select Lead__c from Case];
		Lead lead = [select Id from Lead];
		System.assertEquals(lead.Id, aCase.Lead__c); 
    }      

	@isTest
    public static void testAccountAssociation() {        
        Case aCase = new Case (Subject = 'test', suppliedEmail='test2@test.fr');
        insert aCase;

		aCase = [Select AccountId from Case];
		Account acc = [select Id from Account];
		System.assertEquals(acc.Id, aCase.AccountId); 
    }      
}