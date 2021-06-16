public class Miner3dKeyExtension {

	private static Integer maxDigits = 8;
	private static final Map<String, String> SFDC_2_MINER3D = new Map<String, String> {
		'TRIAL' => 'trial',
		'MINER3D BASIC' => 'basic',
		'MINER3D PROFESSIONNAL' => 'professional',
		'MINER3D ENTERPRISE' => 'enterprise'
	};

	public CleMiner3D__c Key { get; set; }

	public Miner3dKeyExtension(ApexPages.StandardController stdController) {
		this.key = (CleMiner3D__c) stdController.getRecord();
	}

	public PageReference Save() {

		try {
			System.debug('[GenerateLicenceForMiner3Ds] Clés à générér sur le serveur Miner3d : ' + key);
			key.serialNumber__c = Math.round(Math.random() * (Math.pow(10, maxDigits)));

			// Appel du webservices de clé
			JSONGenerator gen = JSON.createGenerator(true);
			gen.writeStartObject();
			gen.writeFieldName('license');
			gen.writeStartObject();
			gen.writeStringField('owner', key.Proprietaire__c);
			gen.writeStringField('product', SFDC_2_MINER3D.get(key.Solution__c));
			if ('TRIAL'.equalsIgnoreCase(key.Solution__c)) gen.writeStringField('type ', 'trial');
			gen.writeStringField('serialNumber', String.valueOf(key.serialNumber__c));
			gen.writeDateField('expiration', key.DateLimite__c);
			gen.writeEndObject();
			gen.writeStringField('customer', key.Proprietaire__c);
			gen.writeEndObject();

			String HttpBody = gen.getAsString();
			System.debug('[GenerateLicenceForMiner3Ds] Trame HTTP envoyée au service : ' + HttpBody);
			Http http = new Http();
			HttpRequest request = new HttpRequest();
			request.setEndpoint('callout:m3dlicense/api/licenses');
			request.setMethod('POST');
			request.setHeader('Content-Type', 'application/json;charset=UTF-8');
			request.setBody(HttpBody);
			HttpResponse response = http.send(request);

			if (response.getStatusCode() != 200) {
				System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
				System.debug(response.getBody());
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Erreur de génération de clé Miner3D :' + response.getBody()));
				return null;
			} else {
				System.debug(response.getBody());

				JSONParser parser = JSON.createParser(response.getBody());
				while (parser.nextToken() != null) {
					if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'activationKey')) {
						parser.nextToken();
						key.ActivationKey__c = parser.getText();
					} else if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'licenseKey')) {
						parser.nextToken();
						key.LicenceKey__c = parser.getText();
					}
				}
			}
			insert key;
			System.debug('[GenerateLicenceForMiner3Ds] Clés générée sur le serveur Miner3d : ' + key);

			PageReference pageRef = new PageReference('/' + this.key.Id);
			pageRef.setRedirect(true);
			return pageRef;
		} catch(Exception e) {
			System.debug(e.getLineNumber() + ':' + e.getMessage());
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Erreur de génération de clé Miner3D :' + e.getMessage()));
			return null;
		}
	}
}