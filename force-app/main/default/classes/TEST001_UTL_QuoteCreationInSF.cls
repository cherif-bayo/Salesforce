@IsTest
public class TEST001_UTL_QuoteCreationInSF  {

	@IsTest
	public static void casNominal() {
		HelperTestData.createExchangeRate();
		HelperTestData.createStandardPriceBook();

		Coupon__c coupon =  new Coupon__c (Name='COUPON', DomainName__c = 'STUDENT',Fin__c= Date.today().addDays(1) ,Debut__c = Date.today().addDays(-1),discount_EUR__c=50,discount_USD__c=25);
		insert coupon;

		Account acc = new Account(Name='account', Type = 'Client');
		insert acc;

		Account accDel = new Account(Name='accountDelivring', Type = 'Client');
		insert accDel;

		Contact ct = new Contact(LastName='Nom', AccountId=acc.Id);
		insert ct;

		Contact ctDel = new Contact(LastName='NomDel', AccountId = accDel.Id);
		insert ctDel;

		WebServiceOrderV2.PlanProduct planProduct = new WebServiceOrderV2.PlanProduct();
		planProduct.ProductCode = 'S_BAS_CMP_AN';
		planProduct.Quantity = 3;
		planProduct.couponReference = 'COUPON';

		WebServiceOrderV2.Customer contact = new WebServiceOrderV2.Customer();
		contact.FirstName = 'prenom';
		contact.LastName = 'nom';
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

		CL001_CustomerWrapper customerWrapper = new CL001_CustomerWrapper(contact);	
		customerWrapper.account2 = acc;
		customerWrapper.contact2 = ct;

		CL001_CustomerWrapper customerDeliveringWrapper = new CL001_CustomerWrapper(contactDelivering);	
		customerDeliveringWrapper.account2 = accDel;
		customerDeliveringWrapper.contact2 = ctDel;

		List<Account> distributeurs = new List<Account> ();
		String licenseType = '';
		boolean isExistingclientFinal = false;
		String currencyISOCode = '';
		String userDomain = '';
		boolean clientFinal = true;

		Test.startTest();

		CL001_UTL_QuoteCreationInSF.create(plan, customerWrapper, customerDeliveringWrapper);
		Test.stopTest();
	}

}