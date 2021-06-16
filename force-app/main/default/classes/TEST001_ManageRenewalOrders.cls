@isTest
public class TEST001_ManageRenewalOrders {

	public class MyException extends Exception { }

	@TestSetup
	public static void setup() {
		HelperTestData.insertTextEmail();

		integer orderProductAmount = 2;

		Currencies_Exchange_Rates__c rate = new Currencies_Exchange_Rates__c();
		rate.Day__c = Date.today();
		rate.CurrencyIsoCode = 'USD';
		rate.Rate__c = 1;

		insert rate;

		Pricebook2 pricebook = new Pricebook2();
		pricebook.Name = 'Test';

		insert pricebook;

		Product2 product = new Product2();
		product.Name = 'Test';

		insert product;

		PricebookEntry pes = new PricebookEntry();
		pes.Product2Id = product.Id;
		pes.Pricebook2Id = Test.getStandardPricebookId();
		pes.UnitPrice = orderProductAmount;
		pes.CurrencyIsoCode = 'USD';

		insert pes;

		PricebookEntry pe = new PricebookEntry();
		pe.Product2Id = product.Id;
		pe.Pricebook2Id = pricebook.Id;
		pe.UnitPrice = orderProductAmount;
		pe.CurrencyIsoCode = 'USD';

		insert pe;

		Account account = new Account(Name = 'accountName',
		                              CurrencyIsoCode = 'USD');

		insert account;

		Account account2 = new Account(Name = 'accountName2',
		                               CurrencyIsoCode = 'USD');

		insert account2;

		Contact ct = new Contact(LastName = 'lastName',
		                         Email = 'lbeaubier@xlstat.com',
		                         Compte_MyAccount_cree__c = false,
		                         Langue__c = 'FR',
		                         Account = account);
		insert ct;

		Contact ct2 = new Contact(LastName = 'lastName2',
		                          Email = 'lbeaubier2@xlstat.com',
		                          Compte_MyAccount_cree__c = true,
		                          Langue__c = 'FR',
		                          Account = account2);
		insert ct2;

		Contact ct3 = new Contact(LastName = 'lastName3',
		                          Email = 'lbeaubier3@xlstat.com',
		                          Compte_MyAccount_cree__c = false,
		                          Langue__c = 'EN',
		                          Account = account);
		insert ct3;

		Contact ct4 = new Contact(LastName = 'lastName4',
		                          Email = 'lbeaubier4@xlstat.com',
		                          Langue__c = 'EN',
		                          Compte_MyAccount_cree__c = true,
		                          Account = account2);
		insert ct4;

		Order order = new Order();
		order.AccountId = account.Id;
		order.EffectiveDate = Date.today();
		order.Pricebook2Id = pricebook.Id;
		order.CurrencyIsoCode = 'USD';
		order.Status = 'Version préliminaire';
		order.Renewal_Auto__c = true;

		insert order;

		OrderItem orderItem = new OrderItem();
		orderItem.PricebookEntryId = pe.Id;
		orderItem.OrderId = order.Id;
		orderItem.Quantity = 1;
		orderItem.UnitPrice = orderProductAmount;

		insert orderItem;

		order.Status = 'ShareIt - Envoyer clé Nalpeiron';
		update order;

		Flexera_Key__C key = new Flexera_Key__C(Order__c = order.Id,
		                                        Name = 'mykey',
		                                        Type_Licence__c = 'Large Campus',
		                                        Contact__c = ct.Id, Quantity__c = 1);
		insert key;

		Flexera_Key__C key2 = new Flexera_Key__C(Order__c = order.Id,
		                                         Name = 'mykey2',
		                                         Type_Licence__c = 'Small Campus',
		                                         Contact__c = ct2.Id, Quantity__c = 5);
		insert key2;

		Flexera_Key__C key3 = new Flexera_Key__C(Order__c = order.Id,
		                                         Name = 'mykey2',
		                                         Type_Licence__c = 'Classroom',
		                                         Contact__c = ct3.Id, Quantity__c = 5);
		insert key3;

		Flexera_Key__C key4 = new Flexera_Key__C(Order__c = order.Id,
		                                         Name = 'mykey2',
		                                         Contact__c = ct4.Id, Quantity__c = 5);
		insert key4;		
	}

	@IsTest
	public static void testNominal() {
		Test.StartTest();
		Database.executeBatch(new B001_ManageRenewalOrders(), 100);
		Test.StopTest();

		Order order = [select Status from Order Limit 1];
		System.assertEquals('Payée', order.Status);
	}


	@IsTest
	public static void testException() {
		B001_ManageRenewalOrders batch = new B001_ManageRenewalOrders();
		batch.B001_ManageRenewalOrdersErrors.add(new MyException('exception'));

		Test.StartTest();
		Database.executeBatch(batch, 100);
		Test.StopTest();
	}
}