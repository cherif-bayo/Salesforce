public without sharing class CL001_UTL_OrderCreationInSF {

	public static String create(WebServiceOrderV2.Plan plan, CL001_CustomerWrapper customerWrapper, CL001_CustomerWrapper customerDeliveringWrapper) {
		List<Account> distributeurs = CL001_HelperPlan.getDistributeurs(plan);
		String licenseType = CL001_HelperPlan.getLicenseType(plan);
		String userDomain = CL001_HelperPlan.getUserDomain(plan);
		WebServiceOrderV2.Customer customer = customerWrapper.customer;

		/***************************** creation nouvelle commande ****************************************************************/
		Order order = new Order(Pricebook2Id = UtilsCQP.getStdPricebookId());
		if (customer.Id != null) order.MyAccount_Auto__c = true;

		// Calcul AccountId, Client Final et Contact Lié
		if (distributeurs.size() > 0) { // Gestion des commandes distributeurs Midware et Statcon
			System.debug('[CL001_UTL_OrderCreationInSF] Commande distributeurs');
			order.AccountId = distributeurs[0].Id;
			order.type = 'Distributeur';
			if (!customerWrapper.account2.IsPersonAccount) order.Client_Final__c = customerWrapper.contact2.Id;
			else order.Client_Final__c = customerWrapper.account2.PersonContactId;
		} else { // Gestion des commandes passées en direct ou par un mandataire autre que les distributeurs
			System.debug('[CL001_UTL_OrderCreationInSF] Commande client sans distributeur');
			if (customerWrapper.contact2 != null) {
				System.debug('[CL001_UTL_OrderCreationInSF] Commande avec contact associé :' + customerWrapper.contact2);
				order.AccountId = customerWrapper.contact2.AccountId;
				if (!customerWrapper.account2.IsPersonAccount) { // Compte Pro
					System.debug('[CL001_UTL_OrderCreationInSF] Commande pour compte type company');
					order.Contact_Lie__c = customerWrapper.contact2.Id;
				}
			} else {
				order.AccountId = customerWrapper.account2.Id;
			}
		}
		System.debug('[CL001_UTL_OrderCreationInSF]  compte associé à la commande : ' + order.AccountId);

		// Si un client de livraison est renseigné (différent de celui de facturation) et
		// que les entreprises ne sont pas les mêmes (TODO : afin de ne pas écraser les distributeur?) alors :
		// Le mandataire est stocké dans client final (en plus du mandaté dans le contact lié)
		if (customer.company != null && customer.company != '' &&
		    CL001_HelperPlan.isPlanWithCustomerDelivering(plan) &&
		    customerDeliveringWrapper.customer.company != customer.company) {

			if (customerDeliveringWrapper.contact2 != null) {
				if (!customerDeliveringWrapper.account2.IsPersonAccount) order.Client_Final__c = customerDeliveringWrapper.contact2.Id;
			} else {
				if (customerDeliveringWrapper.account2.IsPersonAccount) order.Client_Final__c = customerDeliveringWrapper.account2.PersonContactId;
			}
		}

		order.Discount_Client_Activated__c = customerWrapper.account2.Discount_Global__c != null && customerWrapper.account2.Discount_Global__c != 0;
		order.Status = 'Version préliminaire';
		if (! ParametersForOrders.SEND_KEY_USER_DOMAIN_STUDENT.equalsIgnoreCase(userDomain)) order.Autorenewalable__c = true;
		order.EffectiveDate = Date.today();
		order.BillingCountryCode = customer.countryCode;
		order.BillingPostalCode = customer.postalCode;
		order.BillingStreet = customer.street1;
		if (customer.street2 != null && customer.street2 != 'null') order.BillingStreet = '\n' + customer.street2;
		if (ParametersForOrders.countriesCodesWithStatesCodes.contains(customer.countryCode)) order.BillingStateCode = customer.stateCode;
		order.BillingCity = customer.city;
		order.ShippingCountryCode = customer.countryCode;
		order.ShippingPostalCode = customer.postalCode;
		order.ShippingStreet = customer.street1;
		if (customer.street2 != null && customer.street2 != 'null') order.ShippingStreet = '\n' + customer.street2;
		if (ParametersForOrders.countriesCodesWithStatesCodes.contains(customer.countryCode)) order.ShippingStateCode = customer.stateCode;
		order.ShippingCity = customer.city;
		order.CurrencyISOCode = plan.currencyISOCode;
		order.Type_licence__c = licenseType;
		order.Domaine_utilisateur__c = userDomain;
		order.Website_Auto__c = true;
		order.Provenance__c = 'Stripe';
		order.paymentType__c = Integer.valueOf(plan.paymentMethod);
		order.Provenance_d_affiliation__c = 'Site XLSTAT';
		if (CL001_HelperPlan.getCouponId(plan) != null) {
			order.Ref_du_coupon__c = CL001_HelperPlan.getCouponId(plan);
			order.Discount_coupon_activated__c = true;
		}

		insert order;

		order = [SELECT Id, CurrencyIsoCode, Status, OrderNumber FROM Order WHERE Id = :order.Id LIMIT 1];

		/********************* creation  des lignes de commandes à partir des plan products *************************************************************/
		Map<String, Integer> orderProductsQuantities = new Map<String, Integer> ();
		for (WebServiceOrderV2.PlanProduct planProduct : plan.planProducts) {
			orderProductsQuantities.put(planProduct.productCode, planProduct.quantity);
		}
		System.debug('[#orderProductsQuantities] orderProductsQuantities :' + orderProductsQuantities);

		Map<String, ID> productsIdsByProductCode = new Map<String, ID> ();
		for (Product2 product :[select Id, ProductCode from Product2 where ProductCode in :orderProductsQuantities.keySet()]) {
			productsIdsByProductCode.put(product.ProductCode, product.Id);
		}
		System.debug('[#productsIdsByProductCode] productsIdsByProductCode :' + productsIdsByProductCode);

		if (productsIdsByProductCode.keySet().size() > 0) {
			String pricebookId = UtilsCQP.getStdPricebookId();
			List<OrderItem> orderItems = new List<OrderItem> ();
			for (WebServiceOrderV2.PlanProduct planProduct : plan.planProducts) {
				System.debug('[CL001_UTL_OrderCreationInSF#create] planProduct : ' + planProduct);
				List<PricebookEntry> pbes = [select UnitPrice from PricebookEntry where Product2Id = :productsIdsByProductCode.get(planProduct.productCode) and Pricebook2Id = :pricebookId and CurrencyISOCode = :plan.currencyISOCode];
				if (pbes.size()==0) break;

				OrderItem orderItem = new OrderItem();
				orderItem.PricebookEntryId = pbes[0].Id;
				orderItem.Quantity = planProduct.quantity;
				orderItem.OrderId = order.Id;
				orderItem.UnitPrice = pbes[0].UnitPrice;

				if (orderItem.Quantity > 0) orderItems.add(orderItem);
			}

			System.debug('[#CL001_UTL_OrderCreationInSF] order :' + order);
			System.debug('[#CL001_UTL_OrderCreationInSF] orderItems :' + orderItems);
			insert orderItems;
		}

		order.Status = ParametersForOrders.ORDER_STATUS_ABANDONNE;
		update order;
		return order.OrderNumber;
	}
}