public class StripeReportFacade  {

	private static String STRIPE_ENDPOINT_PAYOUT = 'https://api.stripe.com/v1/payouts';
	private static String STRIPE_ENDPOINT_REPORT = 'https://api.stripe.com/v1/reporting/report_runs';
	
	private static String API_PRIVATE_KEY = Parameters.getString('Stripe_Private_Key');
	private static String CONTENT_TYPE = 'application/x-www-form-urlencoded';
	private static String STATUS_PAID = 'paid';
	private static List<String> columns = new List<String>{'customer_id','customer_email','charge_created_utc','balance_transaction_id','created_utc','currency','gross','fee','net','reporting_category','source_id','description','customer_facing_amount','customer_facing_currency','charge_id'};
	private static Integer TIMEOUT_LIMIT = 60000;

	public static PayoutsListResponse getPayoutSince(Date startDate) {
		String query = '?status=' + STATUS_PAID;
		query += '&created[gte]=';
		query += DateTime.newInstance(startDate.year(), startDate.month(), startDate.day()).getTime() / 1000; //ms -> secondes		

		// Appel du webservices de payout
		System.debug('[StripeFacade] Requete au service StripeReportFacade: ' + query);
		HttpRequest request = new HttpRequest();
		request.setMethod('GET');
		request.setTimeOut(TIMEOUT_LIMIT);
		request.setEndpoint(STRIPE_ENDPOINT_PAYOUT + query);
		request.setHeader('Content-Type', CONTENT_TYPE);
		request.setHeader('Authorization', 'Bearer ' + API_PRIVATE_KEY);

		HttpResponse response = new Http().send(request);
		System.debug('Réponse du WS payout :' + response.getBody());

		// Erreur de recuperation de payout
		if (response.getStatusCode() != 200) {
			System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getBody());
			throw new StripeException('Erreur de récupération des payouts :' + response.getBody());
		}

		return PayoutsListResponse.parse(response.getBody());
	}

	public static String generateReportPayout(String idPayout) {
		String requestBody = 'report_type=payout_reconciliation.by_id.itemized.1';
		requestBody += '&parameters[payout]='+idPayout;
		for (String col :columns) requestBody += '&parameters[columns][]=' + col;

		// Appel du webservices de report
		System.debug('[StripeFacade] Requete au service StripeReportFacade: ' + requestBody);
		HttpRequest request = new HttpRequest();
		request.setMethod('POST');
		request.setTimeOut(TIMEOUT_LIMIT);
		request.setEndpoint(STRIPE_ENDPOINT_REPORT);
		request.setHeader('Content-Type', CONTENT_TYPE);
		request.setHeader('Authorization', 'Bearer ' + API_PRIVATE_KEY);
		request.setBody(requestBody);

		HttpResponse response = new Http().send(request);
		System.debug('Réponse du WS report :' + response.getBody());

		// Erreur de generation de rapport
		if (response.getStatusCode() != 200) {
			System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getBody());
			throw new StripeException('Erreur de génération des rapport pour les payouts :' + response.getBody());
		}

		return GenerateReportPayoutResponse.parse(response.getBody()).id;		
	}

	public static String manageReportPayout(String idReport) {
		// Appel du webservices de report
		HttpRequest request = new HttpRequest();
		request.setMethod('GET');
		request.setTimeOut(TIMEOUT_LIMIT);
		request.setEndpoint(STRIPE_ENDPOINT_REPORT+'/'+idReport);
		request.setHeader('Content-Type', CONTENT_TYPE);
		request.setHeader('Authorization', 'Bearer ' + API_PRIVATE_KEY);

		HttpResponse response = new Http().send(request);
		System.debug('Réponse du WS report :' + response.getBody());

		// Erreur de recuperation de l'etat du rapport
		if (response.getStatusCode() != 200) {
			System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getBody());
			throw new StripeException('Erreur de management des rapport pour les payouts :' + response.getBody());
		}

		// Retourne l'URL si la création du rapport est terminé côté Stripe
		StripeReportResponse stripeResponse = StripeReportResponse.parse(response.getBody());
		if (stripeResponse.result != null) return stripeResponse.result.url;

		return '';		
	}

	public static String getReport(String urlReport) {
		// Appel du webservices de report
		HttpRequest request = new HttpRequest();
		request.setMethod('GET');
		request.setTimeOut(TIMEOUT_LIMIT);
		request.setEndpoint(urlReport);
		request.setHeader('Content-Type', CONTENT_TYPE);
		request.setHeader('Authorization', 'Bearer ' + API_PRIVATE_KEY);

		HttpResponse response = new Http().send(request);
		System.debug('Réponse du WS report :' + response.getBody());

		// Erreur de recuperation de l'etat du rapport
		if (response.getStatusCode() != 200) {
			System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getBody());
			throw new StripeException('Erreur de management des rapport pour les payouts :' + response.getBody());
		}

		return response.getBody();		
	}
}