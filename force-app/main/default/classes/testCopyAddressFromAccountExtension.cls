@isTest
public class testCopyAddressFromAccountExtension {
    
    @testSetup
    public static void setUp() {
        Account acc =  new Account (Name='test');
        insert acc;
        
        insert new Order (AccountId = acc.Id, EffectiveDate = date.today(), Status= 'Version préliminaire');
    }
    
    public static testMethod void testCopy() {       
        Account account = [select BillingStreet from Account where name='test' limit 1]; 
        Order order = [select Id from Order where AccountId = :account.Id limit 1];
        
        Test.setCurrentPage(Page.pageCopyAddressFromAccountExtension);

        // call the constructor
        CopyAddressFromAccountExtension controller = new CopyAddressFromAccountExtension(new ApexPages.StandardController(order));
        controller.copyAddress();
    }
}