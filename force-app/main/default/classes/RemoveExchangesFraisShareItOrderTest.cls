@isTest
public class RemoveExchangesFraisShareItOrderTest{

	@TestSetup
	public static void setup() {
		Account acc = new Account(Name='test');
		insert acc;
		
		Contact ct = new Contact (LastName='test', accountId= acc.Id);
		insert ct;
		
		HelperTestData.createOrderWithProductWithContact(ct);
	}

	@IsTest
    public static void main (){
        RemoveExchangesFraisShareItOrder controller = new RemoveExchangesFraisShareItOrder();
        
        controller.UpdateOrders();
    }
}