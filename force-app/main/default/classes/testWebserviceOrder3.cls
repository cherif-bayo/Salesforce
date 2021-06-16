@isTest
public class testWebserviceOrder3 {

	private static String SOLUTION_NAME_TEST = 'XLSTAT-Base';

	@testSetup static void setup() {

		//Create common test Currencies_Exchanges_Rates__c
		insert new Currencies_Exchange_Rates__c(Day__c = Date.today(), CurrencyIsoCode = 'USD', Rate__c = 1);

		//Create common test PriceBook
		Pricebook2 pricebook = new Pricebook2(Name = 'Test', IsActive = true, CurrencyIsoCode__c = 'USD');
		insert pricebook;

		//Create common test Product2
		Product2 product = new Product2(IsActive = true, Name = SOLUTION_NAME_TEST, ProductCode = 'S_BAS_EDU_AN', Family = 'Solution', Domaine_utilisateur__c = 'Entreprise/Privé', Type_licence__c = 'Annuelle');
		Product2 productCD = new Product2(IsActive = true, Name = SOLUTION_NAME_TEST, ProductCode = 'C_SHI_DVD_EP', Family = 'Shipping', Domaine_utilisateur__c = 'Campus', Type_licence__c = 'Annuelle');
		Product2 productSupport = new Product2(IsActive = true, Name = SOLUTION_NAME_TEST, ProductCode = 'S_MAR_CMP_XS', Family = 'Solution', Domaine_utilisateur__c = 'Campus', Type_licence__c = 'Support et maintenance ( 1 an )');
		List<Product2> products = new List<Product2>{product,productCD,productSupport};
		insert products;

		//Create common test PriceBookEntry standard
		insert new PricebookEntry(IsActive = true, Product2Id = product.Id, Pricebook2Id = Test.getStandardPricebookId(), UnitPrice = 10);
		insert new PricebookEntry(IsActive = true, Product2Id = productCD.Id, Pricebook2Id = Test.getStandardPricebookId(), UnitPrice = 10);
		insert new PricebookEntry(IsActive = true, Product2Id = productSupport.Id, Pricebook2Id = Test.getStandardPricebookId(), UnitPrice = 10);

		//Create common test PriceBookEntry
		PricebookEntry pbe =  new PricebookEntry(IsActive = true, Product2Id = product.Id, Pricebook2Id = pricebook.Id, UnitPrice = 10);
		PricebookEntry pbeCD = new PricebookEntry(IsActive = true, Product2Id = productCD.Id, Pricebook2Id = pricebook.Id, UnitPrice = 10);
		PricebookEntry pbeSupport = new PricebookEntry(IsActive = true, Product2Id = productSupport.Id, Pricebook2Id = pricebook.Id, UnitPrice = 10);
		List<PricebookEntry> pricebookEntries = new List<PricebookEntry>{pbe,pbeCD,pbeSupport};
		insert pricebookEntries;

		Account acc = new Account(Name = 'Company', BillingCountryCode = 'FR');
		insert acc;

		Account acc2 = new Account(Name = 'DelivringCompany');
		insert acc2;

		Account acc3 = new Account(Name = 'CompanyContact');
		insert acc3;

		Account acc4 = new Account(Name = 'DelivringCompanyContact');
		insert acc4;

		Contact ct = New Contact(lastName = 'mlezer', email = 'mlezer@adinsoft.edu', AccountId = acc3.Id);
		insert ct;

		Contact ct2 = New Contact(lastName = 'mlezerdelivring', email = 'mlezerdelivring@adinsoft.edu', AccountId = acc4.Id);
		insert ct2;

		insert new Contact(LastName = 'Durant', Email = 'durant@adinsoft.edu', accountId = acc.Id);
		insert new Contact(LastName = 'Dupont', Email = 'dupont@adinsoft.edu', accountId = acc2.Id);

		Order order = new Order(AccountId = acc.Id, EffectiveDate = Date.today(), Status = 'Version préliminaire', Domaine_utilisateur__c = 'Campus',
		                        Type_licence__c = 'Annuelle', CurrencyIsoCode = 'USD', Pricebook2Id = pricebook.Id);
		insert order;
		
		insert new OrderItem(OrderId = order.Id, Product2Id = productSupport.Id, PricebookEntryId = pbeSupport.Id, UnitPrice = 11, Quantity = 5);
	
		order.status = 'Payée';
		update order;	
	}

	@isTest
	public static void testProductSupport() {
		Test.setMock(WebServiceMock.class, new FlexeraWebServiceMockImpl());

		Contact ct = [Select Id from Contact where email = 'mlezer@adinsoft.edu'];
		Contact ct2 = [Select Id from Contact where email = 'mlezerdelivring@adinsoft.edu'];

		WebServiceOrder.PlanProduct orderProduct = new WebServiceOrder.PlanProduct();
		orderProduct.ProductCode = 'S_MAR_CMP_XS';
		orderProduct.Quantity = 3;
		orderProduct.UnitPrice = 295;
		orderProduct.productName = 'test';
		orderProduct.currencyISOCode = 'USD';

		WebServiceOrder.Customer contact = new WebServiceOrder.Customer();
		contact.FirstName = 'Martin';
		contact.LastName = 'Lezer';
		contact.Email = 'durant@adinsoft.edu';
		contact.company = 'Company';
		contact.countryCode = 'FR';
		contact.street1 = '88 rue chevalier';
		contact.street2 = '88 rue chevar';
		contact.postalCode = '33000';
		contact.city = 'Bordeaux';
		contact.language = 'FR';

		WebServiceOrder.Plan order = new WebServiceOrder.Plan();
		order.planProducts = new List<WebServiceOrder.PlanProduct> ();
		order.planProducts.add(orderProduct);
		order.customerBilling = contact;
		order.isQuote = false;
		order.isAutorenewal = null;
		order.currencyISOCode = 'USD';

		WebServiceOrder.Plan plan = WebServiceOrder.AddOrder(order);
		if (plan.status) {
			plan.isUpdate = true;
			plan.keysToUpdate = new List<String> { 'fdjsqlfjlqsd', 'dsjqflkdsfl' };
			WebServiceOrder.SendOrder(plan);
		}
	}

	@isTest
	public static void testProductCD() {
		Test.setMock(WebServiceMock.class, new FlexeraWebServiceMockImpl());

		Contact ct = [Select Id from Contact where email = 'mlezer@adinsoft.edu'];
		Contact ct2 = [Select Id from Contact where email = 'mlezerdelivring@adinsoft.edu'];

		WebServiceOrder.PlanProduct orderProduct = new WebServiceOrder.PlanProduct();
		orderProduct.ProductCode = 'C_SHI_DVD_EP';
		orderProduct.Quantity = 3;
		orderProduct.UnitPrice = 295;
		orderProduct.productName = 'test';
		orderProduct.currencyISOCode = 'USD';

		WebServiceOrder.Customer contact = new WebServiceOrder.Customer();
		contact.FirstName = 'Martin';
		contact.LastName = 'Lezer';
		contact.Email = 'mlezer@adinsoft.edu';
		contact.company = 'Company';
		contact.Id = ct.Id;
		contact.countryCode = 'FR';
		contact.street1 = '88 rue chevalier';
		contact.street2 = '88 rue chevar';
		contact.postalCode = '33000';
		contact.city = 'Bordeaux';
		contact.language = 'FR';

		WebServiceOrder.Customer contactDelivering = new WebServiceOrder.Customer();
		contactDelivering.FirstName = 'Martin-Charles';
		contactDelivering.LastName = 'Lezer Gerard';
		contactDelivering.Email = 'mlezerdelivring@adinsoft.edu';
		contactDelivering.company = 'DelivringCompany';
		contactDelivering.Id = ct2.Id;
		contactDelivering.countryCode = 'FR';
		contactDelivering.street1 = '88 rue chevalier';
		contactDelivering.street2 = '80 rue chevalier';
		contactDelivering.postalCode = '33000';
		contactDelivering.city = 'Bordeaux';
		contactDelivering.language = 'FR';

		WebServiceOrder.Plan order = new WebServiceOrder.Plan();
		order.planProducts = new List<WebServiceOrder.PlanProduct> ();
		order.planProducts.add(orderProduct);
		order.customerBilling = contact;
		order.customerDelivering = contactDelivering;
		order.isQuote = false;
		order.isAutorenewal = null;
		order.currencyISOCode = 'USD';

		WebServiceOrder.Plan plan = WebServiceOrder.AddOrder(order);
		if (plan.status) {
			plan.isUpdate = true;
			plan.keysToUpdate = new List<String> { 'fdjsqlfjlqsd', 'dsjqflkdsfl' };
			WebServiceOrder.SendOrder(plan);
		}
	}

	@isTest
	public static void testMain2() {
		Test.setMock(WebServiceMock.class, new FlexeraWebServiceMockImpl());

		Contact ct = [Select Id from Contact where email = 'mlezer@adinsoft.edu'];
		Contact ct2 = [Select Id from Contact where email = 'mlezerdelivring@adinsoft.edu'];

		WebServiceOrder.PlanProduct orderProduct = new WebServiceOrder.PlanProduct();
		orderProduct.ProductCode = 'S_BAS_EDU_AN';
		orderProduct.Quantity = 3;
		orderProduct.UnitPrice = 295;
		orderProduct.productName = 'test';
		orderProduct.currencyISOCode = 'USD';

		WebServiceOrder.Customer contact = new WebServiceOrder.Customer();
		contact.FirstName = 'Martin';
		contact.LastName = 'Lezer';
		contact.Email = 'mlezer@adinsoft.edu';
		contact.company = 'Company';
		contact.Id = ct.Id;
		contact.countryCode = 'FR';
		contact.street1 = '88 rue chevalier';
		contact.street2 = '88 rue chevar';
		contact.postalCode = '33000';
		contact.city = 'Bordeaux';
		contact.language = 'FR';

		WebServiceOrder.Customer contactDelivering = new WebServiceOrder.Customer();
		contactDelivering.FirstName = 'Martin-Charles';
		contactDelivering.LastName = 'Lezer Gerard';
		contactDelivering.Email = 'mlezerdelivring@adinsoft.edu';
		contactDelivering.company = 'DelivringCompany';
		contactDelivering.Id = ct2.Id;
		contactDelivering.countryCode = 'FR';
		contactDelivering.street1 = '88 rue chevalier';
		contactDelivering.street2 = '80 rue chevalier';
		contactDelivering.postalCode = '33000';
		contactDelivering.city = 'Bordeaux';
		contactDelivering.language = 'FR';

		WebServiceOrder.Plan order = new WebServiceOrder.Plan();
		order.planProducts = new List<WebServiceOrder.PlanProduct> ();
		order.planProducts.add(orderProduct);
		order.customerBilling = contact;
		order.customerDelivering = contactDelivering;
		order.isQuote = false;
		order.isAutorenewal = null;
		order.currencyISOCode = 'USD';

		WebServiceOrder.Plan plan = WebServiceOrder.AddOrder(order);
		if (plan.status) {
			plan.isUpdate = true;
			plan.keysToUpdate = new List<String> { 'fdjsqlfjlqsd', 'dsjqflkdsfl' };
			WebServiceOrder.SendOrder(plan);
		}
	}


	@isTest
	public static void test4() {
		WebServiceOrder.Customer customer = HelperTestDataWebServiceOrder.createBaseCustomerPlanByEmail('lbeaubier@xlstat.com');
		WebServiceOrder.Customer cutomerDelivring = HelperTestDataWebServiceOrder.createBaseCustomerPlanByEmail('bobi@xlstat.com');

		WebServiceOrder.PlanProduct product = HelperTestDataWebServiceOrder.createBasePlanProductByCodeNameAndCurrency('XLSTAT_BASE', 'name', 'EUR');
		WebServiceOrder.plan plan = HelperTestDataWebServiceOrder.createBasePlanByContactBillingPlanProductsAndCurrency(customer,
		                                                                                                                new List<WebServiceOrder.PlanProduct> { product },
		                                                                                                                'EUR');
		plan.paymentMethod = 'Check';
		plan.isQuote = false;

		WebServiceOrder.AddOrder(plan);
		plan.isUpdate = true;
		plan.generateLicense = true;
		WebServiceOrder.SendOrder(plan);

		WebServiceOrder.AddOrder(plan);
		plan.isUpdate = true;
		plan.generateLicense = false;
		WebServiceOrder.SendOrder(plan);

		plan.paymentMethod = 'CB';
		plan.isQuote = false;

		WebServiceOrder.AddOrder(plan);
		plan.isUpdate = true;
		plan.generateLicense = true;

		//WebServiceOrder.SendOrder(plan);

		WebServiceOrder.AddOrder(plan);
		plan.isUpdate = true;
		plan.generateLicense = false;
		WebServiceOrder.SendOrder(plan);

		plan.paymentMethod = 'Virement';
		plan.isQuote = false;

		WebServiceOrder.AddOrder(plan);
		plan.isUpdate = true;
		plan.generateLicense = true;
		//WebServiceOrder.SendOrder(plan);

		WebServiceOrder.AddOrder(plan);
		plan.isUpdate = true;
		plan.generateLicense = false;
		WebServiceOrder.SendOrder(plan);

		plan.paymentMethod = 'CB';
		plan.isQuote = true;

		WebServiceOrder.AddOrder(plan);
		plan.isUpdate = true;
		plan.generateLicense = true;
		WebServiceOrder.SendOrder(plan);

		WebServiceOrder.AddOrder(plan);
		plan.isUpdate = true;
		plan.generateLicense = false;
		WebServiceOrder.SendOrder(plan);
	}
}