@isTest
public class testWebServiceOrderMethodAddOrder {

	@testSetup static void setup() {

		HelperTestData.createPriceBookForCurrency('USD');
		Account acc = new Account(Name = 'Company'); insert acc;
		Account acc2 = new Account(Name = 'Company2', BillingCountryCode = 'FR'); insert acc2;
		insert new Contact(LastName = 'lastnameDejaPresent', Email = 'dejapresent@domaine.com', accountId = acc.Id);
	}

	// Test d'un devis 
	@isTest static void testDevisEntrepriseExistanteSansRenouvellement() {
		Test.setMock(WebServiceMock.class, new FlexeraWebServiceMockImpl());
		List<WebServiceOrder.PlanProduct> products = new List<WebServiceOrder.PlanProduct> ();
		WebServiceOrder.Customer contactBilling = HelperTestDataWebServiceOrder.createBaseCustomerPlanByEmail('email@domaine.com');
		WebServiceOrder.Customer contactDelivring = HelperTestDataWebServiceOrder.createBaseCustomerPlanByEmail('emaildelivring@domaine.com');
		WebServiceOrder.PlanProduct planProduct = HelperTestDataWebServiceOrder.createBasePlanProductByCodeNameAndCurrency('S_BAS_EDU_AN', 'base', 'USD');
		WebServiceOrder.PlanProduct planProduct2 = HelperTestDataWebServiceOrder.createBasePlanProductByCodeNameAndCurrency('S_BAS_CMP_AN', 'base', 'USD');
		WebServiceOrder.Plan order = HelperTestDataWebServiceOrder.createBasePlanByContactBillingPlanProductsAndCurrency(contactBilling, products, 'USD');

		products.add(planProduct);
		products.add(planProduct2);
		order.customerDelivering = contactDelivring; // Contact de delivring
		order.isQuote = true; // Devis
		order.isAutorenewal = null; // Renouvellement
		planProduct.affiliate = 'test'; // Affiliation
		planProduct2.couponReference = 'test'; // Coupon

		WebServiceOrder.Plan plan = WebServiceOrder.AddOrder(order);
	}


	// Test d'une commande 
	@isTest static void testCommandeEntrepriseExistanteSansRenouvellement() {
		Test.setMock(WebServiceMock.class, new FlexeraWebServiceMockImpl());
		List<WebServiceOrder.PlanProduct> products = new List<WebServiceOrder.PlanProduct> ();
		WebServiceOrder.Customer contactBilling = HelperTestDataWebServiceOrder.createBaseCustomerPlanByEmail('email@domaine.com');
		WebServiceOrder.Customer contactDelivring = HelperTestDataWebServiceOrder.createBaseCustomerPlanByEmail('emaildelivring@domaine.com');
		WebServiceOrder.PlanProduct planProduct = HelperTestDataWebServiceOrder.createBasePlanProductByCodeNameAndCurrency('S_BAS_EDU_AN', 'base', 'USD');
		WebServiceOrder.PlanProduct planProduct2 = HelperTestDataWebServiceOrder.createBasePlanProductByCodeNameAndCurrency('S_BAS_CMP_AN', 'base', 'USD');
		WebServiceOrder.Plan order = HelperTestDataWebServiceOrder.createBasePlanByContactBillingPlanProductsAndCurrency(contactBilling, products, 'USD');

		products.add(planProduct);
		products.add(planProduct2);
		order.isQuote = false; // Devis
		order.isAutorenewal = null; // Renouvellement
		contactBilling.Id = '0000000001'; // websiteId existant

		WebServiceOrder.Plan plan = WebServiceOrder.AddOrder(order);
	}

}