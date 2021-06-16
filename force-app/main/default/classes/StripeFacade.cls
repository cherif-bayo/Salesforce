global class StripeFacade {

	private static String STRIPE_ENDPOINT_REFUND = 'https://api.stripe.com/v1/refunds';	
	public static String API_PRIVATE_KEY = Parameters.getString('Stripe_Private_Key');
	public static String CONTENT_TYPE = 'application/x-www-form-urlencoded';
	public static Integer TIMEOUT_LIMIT = 60000;

	private static Refund params;

	global class Refund {
		public String payment_intent;
		public String reason;

	}

	public static void refundCommand(Refund p) {
		System.debug('Stripe params :' + p);
		params = p;
		String payload = gePayloadRefund();

		// Appel du webservices de taxe
		System.debug('[StripeFacade] Trame HTTP envoyée au service StripeFacade: ' + payload);
		HttpRequest request = new HttpRequest();
		request.setMethod('POST');
		request.setTimeOut(TIMEOUT_LIMIT);
		request.setEndpoint(STRIPE_ENDPOINT_REFUND);
		request.setHeader('Content-Type', CONTENT_TYPE);
		request.setHeader('Authorization', 'Bearer ' + API_PRIVATE_KEY);
		request.setBody(payload);

		HttpResponse response = new Http().send(request);
		System.debug(response.getBody());

		// Erreur de calcul de taxe
		if (response.getStatusCode() != 200) {
			System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getBody());
			throw new StripeException('Erreur de récupération de remboursement :' + response.getBody());
		}

		System.debug('Réponse du WS remboursement :' + response.getBody());
	}

	private static String gePayloadRefund() {
		String payload = '';

		try {
			payload += '&payment_intent=' + EncodingUtil.urlEncode(params.payment_intent, 'UTF-8');
			payload += '&reason=' + EncodingUtil.urlEncode(params.reason, 'UTF-8');
			System.debug(payload);
		} catch(Exception e) {
			throw new StripeException('information de payment absentes');
		}

		return payload;
	}	
}