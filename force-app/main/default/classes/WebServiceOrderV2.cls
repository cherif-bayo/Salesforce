global class WebServiceOrderV2 {
	private static CL001_CustomerWrapper customerBillingWrapper;
	private static CL001_CustomerWrapper customerDeliveringWrapper;
	public static Plan currentPlan;

	public static Integer QUOTE_CREATION_FAILED = 1;
	public static Integer ORDER_CREATION_FAILED = 2;
	public static Integer PURCHASE_ORDER_FAILED = 3;
	public static Integer SENDING_PURCHASE_ORDER_FAILED = 4;
	public static Integer CUSTOMER_BILLING_CREATION_FAILED = 6;
	public static Integer CUSTOMER_DELIVRING_CREATION_FAILED = 5;
	public static Integer KEY_CREATION_FAILED = 7;
	public static Integer KEY_SENDING_FAILED = 8;
	public static Integer INVALID_PLAN = 9;

	global class Customer {
		webService String id; //Myaccount
		webService String firstName;
		webService String lastName;
		webService String email;
		webService String company;
		webService String countryCode;
		webService String street1;
		webService String street2;
		webService String stateCode;
		webService String postalCode;
		webService String city;
		webService String language;
		webService String vATNumber;
		webService String phone;
	}

	global class PlanProduct {
		webService String productCode;
		webService Integer quantity;
		webService String couponReference;
	}

	global class Plan {
		webService Integer affiliate;
		webService String currencyISOCode;
		webService PlanProduct[] planProducts;
		webService Customer customerBilling;
		webService Customer customerDelivering;
		webService Integer paymentMethod;
	}

	global class Payment {
		webService String orderNumber;
		webService String customerToken;
		webService String paymentToken; //PaymentIntent
		webService String paymentMethodToken;
		webService Integer exchangeRate; //taux de change midrate lors du payment
		webService String lastCreditCardDigits;
	}

	global class Result {
		webService Boolean status;
		webService Integer errorCode;
		webService String id; // ordernumber or quotenumber
	}


	// Crée le devis et envoie le devis : on ne génère pas de licence */
	webService static Result createQuote(Plan plan) {
		// validation du plan avec ses customers
		Result result = planWithCustomersValidation(plan, true);
		if (!result.status) { return result; } // Cas Ko

		// Creation de la commande ou du devis dans salesforce
		String quoteId = CL001_UTL_QuoteCreationInSF.create(plan, customerBillingWrapper, customerDeliveringWrapper);
		System.debug('WebServiceOrderV2#createOrder creation du devis ' + quoteId);
		if (quoteId == null) { return HelperResult.getResultKoWithErrorCode(QUOTE_CREATION_FAILED); }

		// Envoi de l'email avec le devis
		CL001_QuoteProcessing processing = new CL001_QuoteProcessing(
				quoteId, plan.customerBilling.language.toLowerCase(), plan.customerBilling.email, CL001_UTL_EmailCreationForSendingQuote.QuoteType.QUOTE
		);
		System.schedule('Quote process ' + quoteId, SchedulerHelper.getSchedulerForNSecondesFromNow(15), processing);
		return HelperResult.getResultOkWithId(quoteId);
	}

	// Crée la commande attention on doit générer les licences pour les paiements par cheque ou virement */
	webService static Result createOrder(Plan plan) {
		// validation du plan avec ses customers
		Result result = planWithCustomersValidation(plan, false);
		if (!result.status) { // Cas d'erreur
			return result;
		}
		// Commande avec un bon de commande (cheque ou virement)
		if (plan.paymentMethod == ParametersForOrders.BILLING_WIRE || plan.paymentMethod == ParametersForOrders.BILLING_CHECK) {
			// Creation du bon de commande dans salesforce pour les paiements cheques ou virement (devis)
			String purchaseOrderId = CL001_UTL_QuoteCreationInSF.create(plan, customerBillingWrapper, customerDeliveringWrapper);
			if (purchaseOrderId == null) { return HelperResult.getResultKoWithErrorCode(PURCHASE_ORDER_FAILED); }

			// Calcul du type de devis
			CL001_UTL_EmailCreationForSendingQuote.QuoteType quoteType;
			if (plan.paymentMethod == ParametersForOrders.BILLING_WIRE) { quoteType = CL001_UTL_EmailCreationForSendingQuote.QuoteType.WIRING;
			} else { quoteType = CL001_UTL_EmailCreationForSendingQuote.QuoteType.CHECK; }
			// Envoi du bon de commande par mail 
			CL001_QuoteProcessing processing = new CL001_QuoteProcessing(purchaseOrderId, plan.customerBilling.language.toLowerCase(), plan.customerBilling.email, quoteType);
			System.schedule('Purchase Order process ' + purchaseOrderId, SchedulerHelper.getSchedulerForNSecondesFromNow(15), processing);
			return HelperResult.getResultOkWithId(purchaseOrderId);
		} else { // Paiement par CB
			// Creation de la commande
			String orderId = CL001_UTL_OrderCreationInSF.create(plan, customerBillingWrapper, customerDeliveringWrapper);
			System.debug('WebServiceOrderV2#createOrder creation de la commande ' + orderId);
			/*if (orderId == null) { return HelperResult.getResultKoWithErrorCode(ORDER_CREATION_FAILED); }
			return HelperResult.getResultOkWithId(orderId);*/
			return orderId == null ? HelperResult.getResultKoWithErrorCode(ORDER_CREATION_FAILED) : HelperResult.getResultOkWithId(orderId) ;
		}
	}

	// Valide le paiement génère la clé et envoie la clé par mail au clientpayment
	// Methode remplacée par un webhook sur Stripe
	webService static Result setOrderStatusToPaid(Payment payment) { return HelperResult.getResultOk(); }

	private static Result planWithCustomersValidation(Plan plan, Boolean isQuote) {
		currentPlan = plan;

		// Vérification du plan passé en paramètre 
		if (!CL001_HelperPlan.isValidPlan(plan)) return HelperResult.getResultKoWithErrorCode(INVALID_PLAN);

		// Crée ou MAJ les accounts et contacts salesforce correspondant au customer billing
		customerBillingWrapper = upsertCustomer(plan.customerBilling, isQuote);
		if (customerBillingWrapper == null) return HelperResult.getResultKoWithErrorCode(CUSTOMER_BILLING_CREATION_FAILED);

		// Crée ou MAJ les accounts et contacts salesforce correspondant au customer delivring si nécessaire        
		if (CL001_HelperPlan.isPlanWithCustomerDelivering(plan)) {
			customerDeliveringWrapper = upsertCustomer(plan.customerDelivering, isQuote);
			if (customerDeliveringWrapper == null) return HelperResult.getResultKoWithErrorCode(CUSTOMER_DELIVRING_CREATION_FAILED);
		}
		return HelperResult.getResultOk();
	}

	//Met à jour ou crée un nouveau account pro avec un contact (ou account perso) à partir d'un plan.customer
	//Parametre customer candidat pour l'upsert
	private static CL001_CustomerWrapper upsertCustomer(WebServiceOrderV2.Customer customer, Boolean isQuote) {
		System.debug('WebServiceOrderV2#upsertCustomer : customer : ' + customer);

		// Upsert dans salesforce
		CL001_CustomerWrapper customerWrapper = new CL001_CustomerWrapper(customer);
		customerWrapper.InsertInSalesforce(isQuote, currentPlan.currencyISOCode, CL001_HelperPlan.getUserDomain(currentPlan));

		// Teste si l'insertion dans salesforce du customer billing
		if (customerWrapper.status == false) {
			return null;
		}

		// Recuperation des infos existantes sur le client associé au customer billing 
		if (!customerWrapper.accountUpdate && customerWrapper.contact2 == null) {
			customerWrapper.account2 = [
					SELECT Id, Discount_global__c, PersonContactId, IsPersonAccount
					FROM Account
					WHERE Id = :customerWrapper.account2.Id LIMIT 1
			];
		}

		return customerWrapper;
	}
}