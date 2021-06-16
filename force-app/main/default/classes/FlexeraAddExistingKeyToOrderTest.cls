@IsTest
public class FlexeraAddExistingKeyToOrderTest{
    public static testMethod void testMain() {
        Account account = new Account();
        account.Name = 'Test';
        
        insert account;
        
        Contact contact = new Contact();
        contact.AccountId = account.Id;
        contact.Email = 'test@test.com';
        contact.FirstName = 'Test';
        contact.LastName = 'Test';
        
        insert contact;
        
        Order order = new Order();
        order.AccountId = account.Id;
        order.Contact_Lie__c = contact.Id;
        order.EffectiveDate = Date.today();
        order.Status = 'Version préliminaire';
        
        insert order;
        
        Version__c version = new Version__c();
        version.Name = 'Test';
        version.Date__c = Date.today();
        
        insert version;
        
        Flexera_Key__c key = new Flexera_Key__c();
        key.Name = 'Test';
        key.Entitlement_Id__c = 'Test';
        key.Contact__c = contact.Id;
        key.Date_limite__c = Date.today().addYears(1);
        key.Version__c = version.Id;
        key.Quantity__c = 1;
        
        insert key;
        
        PageReference pg = Page.FlexeraAddExistingKeyToOrder;
        pg.getParameters().put('order_id', order.id);
        Test.setCurrentPage(pg);
                
        Test.startTest();
        FlexeraAddExistingKeyToOrderController controller = new FlexeraAddExistingKeyToOrderController();
        controller.SearchText = 'Test';
        controller.Search();
        controller.WrapperKeys[0].IsSelected = true;
        controller.Add();
        Test.stoptest();
        
        Flexera_Key__c resultKey = [SELECT Id FROM Flexera_Key__c WHERE Contact__c = :contact.Id AND Order__c = :order.Id];
        System.AssertNotEquals(resultKey, null);
    }
}