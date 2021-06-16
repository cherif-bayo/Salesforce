@isTest(SeeAllData=true)
public class testAccountOrdersFromContacts{
    public static testMethod void test(){
        Account account = [select Id from Account limit 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(account);
        
        AccountOrdersFromContactsExtension accountOrdersFromContactsExtension = new AccountOrdersFromContactsExtension(sc);
    }
}