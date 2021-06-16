@isTest
public class Test_OrderProcessingFromCustomPayment {
    
    @isTest
	public static void mainTest() {
		Account acc = new Account (Name='test');
		insert acc;

		Contact ct = new Contact (lastName='test', accountId = acc.Id);
		insert ct;
        
        Order order = new Order();
        order.AccountId = acc.Id;
        order.Client_Final__c = ct.Id;
        order.EffectiveDate = Date.today();
        order.Domaine_Utilisateur__c = 'Company';
        order.CurrencyIsoCode='USD';
        order.Status = 'Version préliminaire';
        order.HasPersonAccountAndCompanyDomain__c = true;
        insert order;
        
        Order od = [select Id, OrderNumber from Order LIMIT 1];
        Test.startTest();
		CL001_OrderProcessingFromCustomPayment.updateOrderFromCustomPayment(od.OrderNumber, 'test', 'test', 'test', 'test');
		Test.stopTest();


	}

}