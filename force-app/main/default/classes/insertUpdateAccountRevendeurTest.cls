@isTest (SeeAllData=false)
public class insertUpdateAccountRevendeurTest{
    public static testMethod void testMain() {
        Account account = new Account();
        account.Name = 'Test';
        account.Type = 'Editeur';
        
        insert account;
        
        Contact contact = new Contact();
        contact.FirstName = 'Test';
        contact.LastName = 'Test';
        contact.Email = Label.emailAdmin;
        contact.AccountId = account.Id;
        
        insert contact;
        
        Order order = new Order();
        order.EffectiveDate = Date.today();
        order.AccountId = account.Id;
        order.Client_Final__c = contact.Id;
        order.Status = 'Version préliminaire';
        
        Test.startTest();
        insert order;
        Test.stopTest();
        
        order = [SELECT AccountPro__c FROM Order WHERE Id = :order.Id];
        
        System.assertEquals(account.Id, order.AccountPro__c);
    }
}