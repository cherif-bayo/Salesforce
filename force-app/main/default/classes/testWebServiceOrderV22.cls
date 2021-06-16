@isTest
private class testWebServiceOrderV22 {

	@testSetup static void setup() {

		HelperTestData.createPriceBookForCurrency('USD');

		Account acc = new Account(Name = 'Company');
		insert acc;

		Account acc2 = new Account(Name = 'Company2', BillingCountryCode = 'FR');
		insert acc2;

		insert new Contact(LastName = 'Lezer', Email = 'dejapresent@adinsoft.edu', accountId = acc.Id);
	}

	// Test d'un devis avec un xlstat base en annuel pour un campus
	@isTest static void testDevisEntrepriseExistante() {
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('jsonCryptlexMockLicenceCreation');
		mock.setStatusCode(201);
		mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
		Test.setMock(HttpCalloutMock.class, mock);

		WebServiceOrderV2.PlanProduct orderProduct = new WebServiceOrderV2.PlanProduct();
		orderProduct.ProductCode = 'S_BAS_EDU_AN';
		orderProduct.Quantity = 3;

		WebServiceOrderV2.Customer contact = new WebServiceOrderV2.Customer();
		contact.FirstName = 'Martin';
		contact.LastName = 'Lezer';
		contact.Email = 'mlezer@adinsoft.edu';
		contact.company = 'Company';
		contact.street1 = '88 rue chevalier';
		contact.street2 = '88 rue chevar';
		contact.postalCode = '33000';
		contact.city = 'Bordeaux';
		contact.language = 'FR';
		contact.countryCode = 'FR';

		WebServiceOrderV2.Customer contactDelivering = new WebServiceOrderV2.Customer();
		contactDelivering.FirstName = 'Martin-Charles';
		contactDelivering.LastName = 'Lezer Gerard';
		contactDelivering.Email = Label.emailAdmin;
		contactDelivering.company = '';
		contactDelivering.countryCode = 'FR';
		contactDelivering.street1 = '88 rue chevalier';
		contactDelivering.street2 = '80 rue chevalier';
		contactDelivering.postalCode = '33000';
		contactDelivering.city = 'Bordeaux';
		contactDelivering.language = 'FR';

		WebServiceOrderV2.Plan order = new WebServiceOrderV2.Plan();
		order.planProducts = new List<WebServiceOrderV2.PlanProduct> ();
		order.planProducts.add(orderProduct);
		order.customerBilling = contact;
		order.customerDelivering = contactDelivering;
		order.currencyISOCode = 'USD';
		order.affiliate = 1;

		WebServiceOrderV2.createQuote(order);
	}

	// Test d'un devis avec un xlstat base en annuel pour un campus
	@isTest static void testDevisEntrepriseExistanteClientFinal() {
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('jsonCryptlexMockLicenceCreation');
		mock.setStatusCode(201);
		mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
		Test.setMock(HttpCalloutMock.class, mock);

		WebServiceOrderV2.PlanProduct orderProduct = new WebServiceOrderV2.PlanProduct();
		orderProduct.ProductCode = 'S_BAS_EDU_AN';
		orderProduct.Quantity = 3;

		Contact ct = [select Id from Contact limit 1]; //inserted in setup

		WebServiceOrderV2.Customer contact = new WebServiceOrderV2.Customer();
		contact.FirstName = 'Martin';
		contact.LastName = 'Lezer';
		contact.Email = 'mlezer@adinsoft.edu';
		contact.company = 'Company2';
		contact.countryCode = 'FR';
		contact.street1 = '88 rue chevalier';
		contact.street2 = '88 rue chevar';
		contact.postalCode = '33000';
		contact.city = 'Bordeaux';
		contact.language = 'FR';
		contact.Id = ct.Id;

		WebServiceOrderV2.Customer contactDelivering = new WebServiceOrderV2.Customer();
		contactDelivering.FirstName = 'Martin-Charles';
		contactDelivering.LastName = 'Lezer Gerard';
		contactDelivering.Email = Label.emailAdmin;
		contactDelivering.company = '';
		contactDelivering.countryCode = 'FR';
		contactDelivering.street1 = '88 rue chevalier';
		contactDelivering.street2 = '80 rue chevalier';
		contactDelivering.postalCode = '33000';
		contactDelivering.city = 'Bordeaux';
		contactDelivering.language = 'FR';

		WebServiceOrderV2.Plan order = new WebServiceOrderV2.Plan();
		order.planProducts = new List<WebServiceOrderV2.PlanProduct> ();
		order.planProducts.add(orderProduct);
		order.customerBilling = contact;
		order.customerDelivering = contactDelivering;
		order.currencyISOCode = 'USD';

		WebServiceOrderV2.Result result = WebServiceOrderV2.createOrder(order);
		if (!result.status) System.debug(result.errorCode);
		else {
			System.debug('orderId créé :' + result.Id);
			Test.startTest();
			WebServiceOrderV2.Payment payment = new WebServiceOrderV2.Payment();
			payment.orderNumber = result.Id;
			payment.customerToken = 'test';
			payment.paymentToken = 'test';
			payment.paymentMethodToken = 'test';
			payment.exchangeRate = 10;
			payment.lastCreditCardDigits = 'test';
			WebServiceOrderV2.setOrderStatusToPaid(payment);
			Test.stopTest();
		}
	}
}