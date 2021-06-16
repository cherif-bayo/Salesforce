public class AccountOrdersFromContactsExtension{
    public List<Order> orders {get; set;}
    
    private final Account acct;
    
    // The extension constructor initializes the private member
    // variable acct by using the getRecord method from the standard
    // controller.
    public AccountOrdersFromContactsExtension(ApexPages.StandardController stdController) {
        this.acct = (Account)stdController.getRecord();
        
        List<Contact> contacts = [select Id from Contact where AccountId = :this.acct.Id];
    
        this.orders = [select OrderNumber, Client_final__r.Name, Status, TotalAmountAfterDiscount__c from Order where Client_final__c in :contacts];
    }
}