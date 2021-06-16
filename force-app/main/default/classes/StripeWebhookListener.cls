@RestResource(urlMapping = '/webhooks/v1/*')
global class StripeWebhookListener {

	@HttpPost
	global static void doPost() {
		RestRequest req = RestContext.request;
		System.debug('[StripeWebhookListener] req=' + req);

		Map<String, Object> o = (Map<String, Object>) SYSTEM.JSON.deserializeUntyped(req.requestBody.toString());
		Map<String, Object> data = (Map<String, Object>) o.get('data');
		Map<String, Object> obj = (Map<String, Object>) data.get('object');

		if ('payment_intent'.equals(obj.get('object'))) parsePaymentIntent(obj);
		else if ('charge'.equals(obj.get('object'))) parseRefund(obj, req.requestBody.toString());

	}

	private static void parseRefund(Map<String, Object> obj, String request) {

		// Récupération du montant du remboursement
		Decimal montant = Integer.valueOf(obj.get('amount_refunded'));

		// Recuperation du numero de commande et de l'Id de la compagnie
		Map<String, Object> metadata = (Map<String, Object>) obj.get('metadata');
		String salesforce_order_id = (String) metadata.get('salesforce_order_id');

		System.debug('[StripeWebhookListener] parseRefund salesforce_order_id=' + salesforce_order_id + ' montant=' + montant);

		// Creation de l'avoir dans salesforce
		Avoir__c avoir = new Avoir__c(Stripe_Request__c = request, Montant__c = montant / 100, Libelle__c = 'Remboursement Stripe', Impact_Order_Price__c = false);
		List<Order> orders = [select Id, status, (select id from Factures__r order by createdDate desc), (select Is_Inactive__c, Entitlement_Id__c from Cles_Flexera__r)  from Order where OrderNumber = :salesforce_order_id];
		if (orders.size() > 0) {
			avoir.Commande_lie__c = orders[0].Id;
			if (orders[0].factures__r != null && orders[0].factures__r.size() > 0) avoir.Facture_liee__c = orders[0].factures__r[0].Id;
            orders[0].status = 'Annulée';
            for (Flexera_Key__c key :orders[0].cles_Flexera__r) {
                key.Is_Inactive__c = True;
                CryptlexFacade.revokeKey(key.Entitlement_Id__c);
            }
            update orders[0].cles_Flexera__r;
            update orders;
            
            insert avoir;

		SCH001_SendEmailAvoir emailAvoir = new SCH001_SendEmailAvoir(avoir.Id);
		System.schedule('Email Avoir for ' + avoir.Id, SchedulerHelper.getSchedulerForNSecondesFromNow(10), emailAvoir);
		}

	}

	private static void parsePaymentIntent(Map<String, Object> obj) {

		// Recuperation du paymentToken
		String paymentIntentId = (String) obj.get('id');

		// Recuperation du customerToken
		String customerId = (String) obj.get('customer');
		System.debug('[StripeWebhookListener] customerId=' + customerId);

		// Recuperation du paymentMethod
		String payment_method = (String) obj.get('payment_method');
		System.debug('[StripeWebhookListener] payment_method=' + payment_method);

		// Recuperation du numero de commande du quote et l'Id de la compagnie
		Map<String, Object> metadata = (Map<String, Object>) obj.get('metadata');			
		String salesforce_order_id = (String) metadata.get('salesforce_order_id');
		String salesforce_quote_id = (String) metadata.get('salesforce_quote_id');
		System.debug('[StripeWebhookListener] salesforce_order_id=' + salesforce_order_id);
                    System.debug('[StripeWebhookListener] salesforce_quote_id=' + salesforce_quote_id);
	 
		// Recuperation de l'identifiant du charge
		Map<String, Object> charges = (Map<String, Object>) obj.get('charges');
		list<Object> data = (list<Object>) charges.get('data');
		map<String, Object> charge = (map<String, Object>) data[0];
		String chargeId = (String) charge.get('id');
		System.debug('[StripeWebhookListener] chargeId=' + chargeId);

		// Passage au statut payé de la commande
		if (salesforce_order_id != null && salesforce_order_id.length() > 1) CL001_OrderProcessing.generateLicenceAndSendEmailToCustomerWithKey(salesforce_order_id, customerId, paymentIntentId, chargeId, payment_method);

		// Passage du devis au status lien de paiement validé
		else if (salesforce_quote_id != null && salesforce_quote_id.length() > 1) setQuotePayed(salesforce_quote_id, paymentIntentId, customerId, payment_method, chargeId);
	}

	@TestVisible
	public static void setQuotePayed(String quoteId, String QuotepaymentIntent, String QuoteCustomerId, String QuotePaymentMethod, String QuoteChargeId) {
		List<Quote> quotes = [select Id from Quote where QuoteNumber = :quoteId];
		if (quotes.size() > 0) {
			quotes[0].payed__c = true;
            quotes[0].QuotePaymentIntentToken__c = QuotepaymentIntent;
            quotes[0].QuoteChargeToken__c = QuoteChargeId;
            quotes[0].QuoteCustomerToken__c = QuoteCustomerId;
            quotes[0].QuotePaymentMethod__c = QuotePaymentMethod;
            quotes[0].IsFromStripe__c = true;
            quotes[0].PayementDateInStripe__c = Date.today();

            quotes[0].HasCD__c = false;
            
			update quotes[0];
		}
       
        List<Order> order = [select Id from Order where OrderNumber = :quoteId];
        // If we need to automate key generation, invoice and payment creation we can use the code below
        if (order.size() > 0) {CL001_OrderProcessingFromCustomPayment.updateOrderFromCustomPayment(quoteId, QuoteCustomerId, QuotepaymentIntent, QuoteChargeId, QuotePaymentMethod);}
       
	}
}