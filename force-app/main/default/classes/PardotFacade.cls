public class PardotFacade {

	private static String APIkey;
	private static String listId;

	public static void upsertProspectsWithListAssociated(List<Pardot.Prospect> prospects, String listId) {
		PardotFacade.listId = listId;

		// récupération d'une nouvelle clé API
		getAPIKey();

		// création de lots de 5 prospects envoyés à Pardot
		List<Pardot.Prospect> prospectsShortList = new List<Pardot.Prospect> ();
		String json;
		for (Integer i = 0; i<prospects.size(); i++) {
			prospectsShortList.add(prospects.get(i));
			if (Math.mod(i, 5) == 0) {
				json = getJsonPardotProspects(prospectsShortList);
				insertProspectInPardot(json);
				prospectsShortList.clear();
			}
		}
	}

	private static void getAPIKey() {
		String body = 'email=' + Pardot.LOGIN_EMAIL + '&';
		body += 'password=' + Pardot.LOGIN_PASSWORD + '&';
		body += 'user_key=' + Pardot.USER_KEY + '&';

		// Appel du webservices de generation de cle		
		HttpRequest request = new HttpRequest();
		request.setMethod('POST');
		request.setTimeOut(60000);
		request.setEndpoint(Pardot.ENDPOINT_LOGIN);
       	request.setBody(body);

		System.debug('[PardotFacade] request for APIKey: ' + request);

		HttpResponse response = new Http().send(request);
		System.debug('[PardotFacade] response with APIKey: ' + response.getBody());

		// Erreur de génération de clé API Pardot
		if (response.getStatusCode() != 200 && response.getStatusCode() != 201) {
			System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getBody());
			throw new PardotException('Impossible de récupérer la clé API Pardot:' + response.getBody());
		}

		DOM.Document document = new DOM.Document();
		document.load(response.getBody());
		APIKey = document.getRootElement().getChildElement('api_key', null).getText();
		System.debug('[PardotFacade] APIKey: ' + APIKey);
	}

	private static String getJsonPardotProspects(List<Pardot.Prospect> prospects) {
		JSONGenerator gen = JSON.createGenerator(true);
		gen.writeStartObject();
		gen.writeFieldName('prospects');
		gen.writeStartArray();
		for (Pardot.Prospect prospect : prospects) {
			gen.writeStartObject();
			gen.writeNumberField('list_' + listId, 1);
			if (prospect.fid != null) gen.writeStringField('fid', prospect.fid);
			if (prospect.first_name != null) gen.writeStringField('first_name', prospect.first_name);
			if (prospect.last_name != null) gen.writeStringField('last_name', prospect.last_name);
			if (prospect.email != null) gen.writeStringField('email', prospect.email);
			if (prospect.Montant_Panier != null) gen.writeNumberField('Montant_Panier', prospect.Montant_Panier);
			if (prospect.Produit_Panier != null) gen.writeStringField('Produit_Panier', prospect.Produit_Panier);
			if (prospect.Devise_Panier != null) gen.writeStringField('Devise_Panier', prospect.Devise_Panier);
			gen.writeEndObject();
		}
		gen.writeEndArray();
		gen.writeEndObject();

		return EncodingUtil.urlEncode(gen.getAsString(), 'UTF-8');
	}

	private static void insertProspectInPardot(String json) {
		// QueryString de la requete
		String url = Pardot.ENDPOINT_BATCH_UPSERT + '?';
		url += 'prospects=' + json + '&';

		// Appel du webservices de generation de cle		
		HttpRequest request = new HttpRequest();
		request.setMethod('POST');
        request.setHeader('Authorization', 'Pardot api_key='+APIkey+', user_key='+Pardot.USER_KEY);
		request.setTimeOut(60000);
		request.setEndpoint(url);
		System.debug('[PardotFacade] request for upsert prospects :' + request);

		HttpResponse response = new Http().send(request);
		System.debug('[PardotFacade] response for upsert: ' + response.getBody());

		// Erreur de génération de clé API Pardot
		if (response.getStatusCode() != 200 && response.getStatusCode() != 201) {
			System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getBody());
			throw new PardotException('Impossible de faire l upsert des prospects dans Pardot:' + response.getBody());
		}
	}
}