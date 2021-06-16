@isTest
global class TEST001_HelperPlan {

	@isTest
	public static void main() {
		HelperTestData.createStandardPriceBook();

		WebServiceOrderV2.PlanProduct planProduct = new WebServiceOrderV2.PlanProduct();
		planProduct.ProductCode = 'S_BAS_CMP_AN';
		planProduct.Quantity = 3;
		planProduct.couponReference = 'COUPON';

		WebServiceOrderV2.Customer contact = new WebServiceOrderV2.Customer();
		contact.FirstName = 'prenom';
		contact.LastName = 'Nom';
		contact.Email = 'email@adinsoft.edu';
		contact.company = 'company1';
		contact.countryCode = 'FR';
		contact.street1 = 'street1';
		contact.street2 = 'street2';
		contact.postalCode = '33000';
		contact.city = 'city';
		contact.language = 'FR';

		WebServiceOrderV2.Customer contactDelivering = new WebServiceOrderV2.Customer();
		contactDelivering.FirstName = 'prenomClientFinal';
		contactDelivering.LastName = 'nomClientFinal';
		contactDelivering.Email = 'email@finaladinsoft.edu';
		contactDelivering.company = 'company2';
		contactDelivering.countryCode = 'FR';
		contactDelivering.street1 = 'street1ClientFinal';
		contactDelivering.street2 = 'street2ClientFinal';
		contactDelivering.postalCode = '33000';
		contactDelivering.city = 'cityClientFinal';
		contactDelivering.language = 'FR';

		WebServiceOrderV2.Plan plan = new WebServiceOrderV2.Plan();
		plan.planProducts = new List<WebServiceOrderV2.PlanProduct> ();
		plan.planProducts.add(planProduct);
		plan.customerBilling = contact;
		plan.customerDelivering = contactDelivering;
		plan.currencyISOCode = 'USD';
		plan.affiliate = 1;

		CL001_HelperPlan.getUserDomain(plan);
		CL001_HelperPlan.getLicenseType(plan);
		CL001_HelperPlan.isPlanWithCustomerDelivering(plan);
		CL001_HelperPlan.getProductByProductCode(plan);
		CL001_HelperPlan.getCouponId(plan);
		CL001_HelperPlan.isValidPlan(plan);
		CL001_HelperPlan.getDistributeurs(plan);
		CL001_HelperPlan.checkNumberOfOptionLicences(plan);
	}
}