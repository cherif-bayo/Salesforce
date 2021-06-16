public class CL001_UTL_QuoteCreationInSF {

	public static String create(WebServiceOrderV2.Plan plan, CL001_CustomerWrapper customerWrapper, CL001_CustomerWrapper customerDeliveringWrapper) {

		DateTime dateTimeNow = DateTime.now();
		String pricebookId = UtilsCQP.getStdPricebookId();

		/******************* Creation dans SF d'une opportunité avec les infos du client ***************************/
		Opportunity opportunity = new Opportunity();
		opportunity.Pricebook2Id = pricebookId;
		opportunity.CurrencyISOCode = plan.currencyISOCode;
		opportunity.Name = 'Proposition en ligne ' + dateTimeNow;
		opportunity.StageName = 'Proposition/Devis';
		opportunity.CloseDate = Date.today().addDays(7);
		opportunity.Website_Auto__c = true;
		opportunity.Type = 'Nouvelle activité';

		// Compte et contact associé à l'opportunité
		Account billingAccount = customerWrapper.account2;
		Contact billingContact = customerWrapper.contact2;

		if (billingContact != null) {
			opportunity.AccountId = billingContact.AccountId;
			opportunity.Contact_Lie__c = billingContact.Id;
		} else {
			opportunity.AccountId = billingAccount.Id;
			if (billingAccount.IsPersonAccount) opportunity.Contact_Lie__c = billingAccount.PersonContactId;
		}
		System.debug('[CL001_UTL_QuoteCreationInSF#create] opportunity.AccountId: ' + opportunity.AccountId);

		// Client Final de l'opportunité
		if (CL001_HelperPlan.isPlanWithCustomerDelivering(plan)) { // Cas distributeur : Remplissage le client final de l'opportunité
			Account delivringAccount = customerDeliveringWrapper.account2;
			if (customerDeliveringWrapper.contact2 != null) {
				if (!delivringAccount.IsPersonAccount) opportunity.Client_Final__c = customerDeliveringWrapper.contact2.Id;
			} else {
				if (delivringAccount.IsPersonAccount) opportunity.Client_Final__c = delivringAccount.PersonContactId;
			}
		}

		insert opportunity;

		/******************* Creation dans SF d'un devis    ********************************************/
		WebServiceOrderV2.Customer customer = customerWrapper.customer;

		Quote quote = new Quote();
		quote.OpportunityId = opportunity.Id;
		quote.Pricebook2Id = pricebookId;
		quote.Name = 'Devis en ligne ' + dateTimeNow;
		quote.Domaine_utilisateur__c = CL001_HelperPlan.getUserDomain(plan);
		quote.BillingCountryCode = customer.countryCode;
		quote.BillingPostalCode = customer.postalCode;
		quote.BillingStreet = customer.street1;
		if (customer.street2 != null && customer.street2 != 'null') quote.BillingStreet += '\n' + customer.street2;
		if (ParametersForOrders.countriesCodesWithStatesCodes.contains(customer.countryCode)) quote.BillingStateCode = customer.stateCode;
		quote.BillingCity = customer.city;
		quote.ShippingCountryCode = customer.countryCode;
		quote.ShippingPostalCode = customer.postalCode;
		quote.ShippingStreet = customer.street1;
		if (customer.street2 != null && customer.street2 != 'null') quote.ShippingStreet = '\n' + customer.street2;
		if (ParametersForOrders.countriesCodesWithStatesCodes.contains(customer.countryCode)) quote.ShippingStateCode = customer.stateCode;
		quote.ShippingCity = customer.city;
		quote.GenerateFactureEn__c = customer.language.toLowerCase() != 'fr';
		quote.Website_Auto__c = true;
		quote.Type__c = ParametersForOrders.QUOTE_TYPE;
		if (customer.company != null && customer.company != '') {
			quote.Affichage_Nom_Du_Compte__c = 'Nom du compte et nom du contact';
		} else {
			quote.Affichage_Nom_Du_Compte__c = 'Nom du compte seul';
		}
		quote.Ref_du_coupon__c = CL001_HelperPlan.getCouponId(plan);
		insert quote;

		quote.Status = 'Présenté';
		update quote;

		/******************* Creation dans SF des lignes de devis ***************************/
		Map<String, Integer> orderProductsQuantities = new Map<String, Integer> ();
		for (WebServiceOrderV2.PlanProduct planProduct : plan.planProducts) {
			orderProductsQuantities.put(planProduct.productCode, planProduct.quantity);
		}

		Map<String, ID> productsIdsByProductCode = new Map<String, ID> ();
		for (Product2 product :[select Id, ProductCode from Product2 where ProductCode in :orderProductsQuantities.keySet()]) {
			productsIdsByProductCode.put(product.ProductCode, product.Id);
		}

		// Si pas de code produit c'est qu'il y a eu un probleme
		if (productsIdsByProductCode.keySet().size() == 0) {
			System.debug('[CL001_UTL_QuoteCreationInSF#create] erreur fatale aucun code produit');
			return null;
		}

		List<QuoteLineItem> quoteLineItems = new List<QuoteLineItem> ();
		for (WebServiceOrderV2.PlanProduct planProduct : plan.planProducts) {
			System.debug('[CL001_UTL_QuoteCreationInSF#create] planProduct : ' + planProduct);
			List<PricebookEntry> pbes = [select UnitPrice from PricebookEntry where Product2Id = :productsIdsByProductCode.get(planProduct.productCode) and Pricebook2Id = :pricebookId and CurrencyISOCode = :plan.currencyISOCode limit 1];
			if (pbes.size()==0) break;

			QuoteLineItem quoteLineItem = new QuoteLineItem();
			quoteLineItem.PricebookEntryId = pbes[0].Id;
			quoteLineItem.Quantity = planProduct.quantity;
			quoteLineItem.QuoteId = quote.Id;
			quoteLineItem.UnitPrice = pbes[0].UnitPrice;

			if (quoteLineItem.Quantity > 0) quoteLineItems.add(quoteLineItem);
			System.debug('[CL001_UTL_QuoteCreationInSF#create] quoteLineItem : ' + quoteLineItem);
		}
		insert quoteLineItems;

		opportunity.SyncedQuoteId = quote.Id;
		update opportunity;

		return quote.Id;
	}
}