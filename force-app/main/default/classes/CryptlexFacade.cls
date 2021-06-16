global without sharing class CryptlexFacade {
	private static String LICENCE_ENDPOINT = 'https://api.cryptlex.com/v3/licenses';
	private static String PUT_LICENCE_ENDPOINT = 'https://activation.xlstat.com/api/CryptlexProxy/';
	private static String ACTIVATION_ENDPOINT = 'https://api.cryptlex.com/v3/activations';
	private static String BEARER_TOKEN = 'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJzY29wZSI6WyJsaWNlbnNlOnJlYWQiLCJsaWNlbnNlOndyaXRlIiwibGljZW5zZVBvbGljeTpyZWFkIiwibGljZW5zZVBvbGljeTp3cml0ZSIsInByb2R1Y3Q6cmVhZCIsInByb2R1Y3Q6d3JpdGUiXSwic3ViIjoiNGE4MTBjOTEtMjZkOC00OWUyLWE0ODQtYWVmZTc3MzBmMDljIiwiZW1haWwiOiJkdHJ1dEB4bHN0YXQuY29tIiwianRpIjoiMWRkZDFkZWMtZWZkMi00MDQxLWJjNzktYzU0YWM4MWJkODUxIiwiaWF0IjoxNTkyMzc5ODA2LCJ0b2tlbl91c2FnZSI6InBlcnNvbmFsX2FjY2Vzc190b2tlbiIsInRlbmFudGlkIjoiNjdkM2ExOGEtYjFkNS00MzVkLTlhNDMtMmZkNDBkNmNhYTYyIiwiYXVkIjoiaHR0cHM6Ly9hcGkuY3J5cHRsZXguY29tIn0.aP79bF7xf97VCxEfNiBGXJwwrEcIG7ULTCc17z7ikSNTyxoN0F2CDzeHcaVlxL6GiwrATRoQ594cR0dzzjuayNDr4dJT5tzSTLhMsKACIbjUNx-qia0HCv3GJy1Km3U_o_eyHZbuLXPPjPMYgUF9pmvnq6VwTA0UwzpyUN6GjfzCVkKsDznnn96MwTXyvFMXdjK7XShYtbVuwI6649CvFmCY5HnYWKGSceTBwt5IrCEeUuMlvMK64TNBlFeJjRB0Ht_6sqpX6qfVyA30Ncc8_aMOBFhiqIFWPNqYwYu_G2qCe3Arob7Km23Tf9BmOCsuZFHpzf5jFXotIdAehDPYbw';
	private static String CONTENT_TYPE = 'application/json;charset=UTF-8';
	private static String STANDARD_POLICY_ID = '9794fb83-9059-413f-8aa8-6631aecec7ae';
	private static String PERPETUAL_POLICY_ID = 'b755c847-c736-4ce8-a3cb-3f5bf7aeb10e';
	private static String NETWORK_POLICY_ID = '0393f933-19e6-4aa6-9340-f54965719cbb';
	private static String EXPIRATION_AT_ACTIVATION = 'delayed';


	public static LicenseKey getNewTrialKey(String softwareCode) {
		LicenseKey params = new LicenseKey();
		System.debug('>>>> getNewTrialKey - softwareCode = '+softwareCode);
		Software__c software = new SoftwareService().getSoftwareFromCode(softwareCode);
		HelperCryptlexMetaData helper = HelperCryptlexMetadataFactory.getHelperCryptlexMetadata(software);
		params.metadata = helper.getMetaDataForTrial();
		params.nbActivations = Integer.valueOf(Parameters.getString('Trial_Number_Activations'));
		params.validity = 14 * 24 * 60 * 60; // 14jours
		params.policy = STANDARD_POLICY_ID;
		params.Expiration = EXPIRATION_AT_ACTIVATION;
		params.allowVmActivation = false;
		return getNewKey(params);
	}

	public static LicenseKey getNewAnnualKey(String domain, String licenceType, List<String> products, Decimal nbActivations, Date endDate) {
		LicenseKey params = new LicenseKey();
		Software__c software = new SoftwareService().getSoftwareFromName(products[0]);
		System.debug('>>>> getNewAnnualKey - software = '+software);
		HelperCryptlexMetaData helper = HelperCryptlexMetadataFactory.getHelperCryptlexMetadata(software);
		params.metadata = helper.getMetaDataForAnnual(domain, licenceType, products);
		params.nbActivations = Integer.valueOf(nbActivations);
		params.policy = STANDARD_POLICY_ID;
		params.ExpirationDate = endDate;
		return getNewKey(params);
	}

	public static LicenseKey getNewPerpetualKey(String domain, String licenceType, List<String> products, Decimal nbActivations, Date dateSupport) {
		LicenseKey params = new LicenseKey();
		Software__c software = new SoftwareService().getSoftwareFromName(products[0]);
		System.debug('>>>> getNewPerpetualKey - software = '+software);
		HelperCryptlexMetaData helper = HelperCryptlexMetadataFactory.getHelperCryptlexMetadata(software);
		params.metadata = helper.getMetaDataForPerpetual(domain, licenceType, products, dateSupport.addYears(1));
		params.nbActivations = Integer.valueOf(nbActivations);
		params.policy = PERPETUAL_POLICY_ID;
		System.debug('[CryptlexFacade] Generation de clé perpetuelle params =' + params);
		return getNewKey(params);
	}

	public static LicenseKey getNewNetworkKey(String domain, String licenceType, List<String> products, Decimal nbActivations, Date endDate) {
		LicenseKey params = new LicenseKey();
		Software__c software = new SoftwareService().getSoftwareFromName(products[0]);
		System.debug('>>>> getNewNetworkKey - software = '+software);
		HelperCryptlexMetaData helper = HelperCryptlexMetadataFactory.getHelperCryptlexMetadata(software);
		params.metadata = helper.getMetaDataForNetwork(domain, licenceType, products);
		params.allowedFloatingClients = Integer.valueOf(nbActivations);
		params.policy = NETWORK_POLICY_ID;
		params.ExpirationDate = endDate;
		System.debug('[CryptlexFacade] Generation de clé réseau params =' + params);
		return getNewKey(params);
	}

	private static LicenseKey getNewKey(LicenseKey params) {
		LicenseKey newKey = new LicenseKey();
		System.debug('[CryptlexFacade] getNewKey : '+params.metadata.productId);
		// Appel du webservices de clé
		JSONGenerator gen = JSON.createGenerator(true);
		gen.writeStartObject();
		gen.writeStringField('productid', params.metadata.productId);
		gen.writeBooleanField('disableGeoLocation', true);
		if (params.validity > 0) gen.writeNumberField('validity', params.validity);
		if (params.metadata.scope == Cryptlex.SCOPE_STATION) gen.writeBooleanField('UserLocked', false);
		// MetaData (Duplication de Code !!!!)
		gen.writeFieldName('metadata');
		gen.writeStartArray();
		if (params.metadata.domain != null) {
			gen.writeStartObject();
			gen.writeBooleanField('visible', true);
			gen.writeStringField('key', 'DOMAIN');
			gen.writeStringField('value', String.valueOf(params.metadata.domain));
			gen.writeEndObject();
		}
		if (params.metadata.access != null) {
			gen.writeStartObject();
			gen.writeBooleanField('visible', true);
			gen.writeStringField('key', 'ACCESS');
			gen.writeStringField('value', String.valueOf(params.metadata.access));
			gen.writeEndObject();
		}
		if (params.metadata.scope != null) {
			gen.writeStartObject();
			gen.writeBooleanField('visible', true);
			gen.writeStringField('key', 'SCOPE');
			gen.writeStringField('value', String.valueOf(params.metadata.scope));
			gen.writeEndObject();
		}
		if (params.metadata.endUp != null) {
			String strENDUPD = Datetime.newInstance(params.metadata.endUp.year(), params.metadata.endUp.month(), params.metadata.endUp.day()).format('yyyy-MM-dd');
			gen.writeStartObject();
			gen.writeBooleanField('visible', true);
			gen.writeStringField('key', 'ENDUPD');
			gen.writeStringField('value', strENDUPD);
			gen.writeEndObject();
		}
		gen.writeEndArray();
		gen.writeStringField('licensePolicyId', params.policy);
		if (params.Expiration != null) gen.writeStringField('expirationStrategy', params.Expiration);
		if (params.ExpirationDate != null) gen.writeNumberField('validity', Date.today().daysBetween(params.ExpirationDate) * 24 * 60 * 60);
		if (!params.allowVmActivation) gen.writeBooleanField('allowVmActivation', false);
		if (params.allowedFloatingClients != null && params.allowedFloatingClients > 0) gen.writeNumberField('allowedFloatingClients', params.allowedFloatingClients);
		else gen.writeNumberField('allowedActivations', params.nbActivations);
		gen.writeEndObject();
		String genAsString = gen.getAsString();
		System.debug('[CryptlexFacade] Trame HTTP envoyée au service : ' + genAsString);
		HttpResponse response = new Http().send(getHttpRequest('POST', LICENCE_ENDPOINT, genAsString));
		System.debug(response.getBody());
		// Erreur de génération de clé chez cryptlex
		if (response.getStatusCode() != 201) {
			System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getBody());
			throw new CryptlexException('Erreur de génération de clé cryptlex :' + response.getBody());
		}
		// Get key from response
		Boolean keyfound = false; // To get only the first object in json whith a key named key!
		JSONParser parser = JSON.createParser(response.getBody());
		while (parser.nextToken() != null) {
			if (!keyfound && JSONToken.FIELD_NAME.equals(parser.getCurrentToken()) && 'key'.equalsIgnoreCase(parser.getCurrentName())) {
				parser.nextToken();
				newKey.keyNumber = parser.getText();
				keyfound = true;
			} else if (JSONToken.FIELD_NAME.equals(parser.getCurrentToken()) && 'id'.equalsIgnoreCase(parser.getCurrentName())) {
				parser.nextToken();
				newKey.id = parser.getText();
			}
		}
		return newKey;
	}

	public static Boolean updateKey(String Id, String domain, String licenceType, List<String> products, Decimal nbActivations) {
		// Appel du webservices de clé
		System.debug('>>>> updateKey - Id = '+Id+' | domain = '+domain+' | licenceType = '+licenceType+' | nbActivations = '+nbActivations+'');
		System.debug('>>>> List<String> products '+products);
		Software__c software = new SoftwareService().getSoftwareFromName(products[0]);
		System.debug('>>>> updateKey - software = '+software);
		HelperCryptlexMetaData helper = HelperCryptlexMetadataFactory.getHelperCryptlexMetadata(software);
		CryptlexMetaData metadata = helper.getMetaDataForAnnual(domain, licenceType, products);
		System.debug('>>>> metadata = '+metadata);
		JSONGenerator gen = JSON.createGenerator(true);
		gen.writeStartObject();
		// MetaData
		gen.writeFieldName('metadata');
		gen.writeStartArray();
		if (metadata.domain != null) {
			gen.writeStartObject();
			gen.writeBooleanField('visible', true);
			gen.writeStringField('key', 'DOMAIN');
			gen.writeStringField('value', String.valueOf(metadata.domain));
			gen.writeEndObject();
		}
		if (metadata.access != null) {
			gen.writeStartObject();
			gen.writeBooleanField('visible', true);
			gen.writeStringField('key', 'ACCESS');
			gen.writeStringField('value', String.valueOf(metadata.access));
			gen.writeEndObject();
		}
		if (metadata.scope != null) {
			gen.writeStartObject();
			gen.writeBooleanField('visible', true);
			gen.writeStringField('key', 'SCOPE');
			gen.writeStringField('value', String.valueOf(metadata.scope));
			gen.writeEndObject();
		}
		if (metadata.endUp != null) {
			String strENDUPD = Datetime.newInstance(metadata.endUp.year(), metadata.endUp.month(), metadata.endUp.day()).format('yyyy-MM-dd');
			gen.writeStartObject();
			gen.writeBooleanField('visible', true);
			gen.writeStringField('key', 'ENDUPD');
			gen.writeStringField('value', strENDUPD);
			gen.writeEndObject();
		}
		gen.writeEndArray();
		gen.writeNumberField('allowedActivations', nbActivations);
		gen.writeEndObject();
		System.debug('[CryptlexFacade] updateKey Trame HTTP envoyée au service : ' + gen.getAsString());
		HttpResponse response = new Http().send(getHttpRequest('PUT', PUT_LICENCE_ENDPOINT + '/' + Id, gen.getAsString()));
		System.debug('>>>> HttpResponse response = '+response);
		// Erreur de génération de clé chez cryptlex
		if (response.getStatusCode() != 200) {
			System.debug('updateKey - The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getBody());
			throw new CryptlexException('Erreur de mise à jour de clé cryptlex :' + response.getBody());
		}
		return true;
	}

	public static void revokeKey(String Id) {
		System.debug('[CryptlexFacade] révoke la clé Id =' + Id);
		// Appel du webservices de clé
		JSONGenerator gen = JSON.createGenerator(true);
		gen.writeStartObject();
		gen.writeBooleanField('revoked', true);
		gen.writeEndObject();
		System.debug('[CryptlexFacade] Trame HTTP envoyée au service : ' + gen.getAsString());
		HttpResponse response = new Http().send(getHttpRequest('PUT', PUT_LICENCE_ENDPOINT + '/' + Id, gen.getAsString()));
		System.debug(response.getBody());
		// Erreur de génération de clé chez cryptlex
		if (response.getStatusCode() != 200) {
			System.debug('revokeKey - The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getBody());
			throw new CryptlexException('Erreur de mise à jour de clé cryptlex :' + response.getBody());
		}
	}

	public static Boolean setSuspendStateKey(String Id, Boolean status) {
		System.debug('[CryptlexFacade] change etat suspendu de la clé Id =' + Id + ' status:' + status);
		// Appel du webservices de clé
		JSONGenerator gen = JSON.createGenerator(true);
		gen.writeStartObject();
		if (status) gen.writeBooleanField('suspended', true);
		else gen.writeBooleanField('suspended', false);
		gen.writeEndObject();
		System.debug('[CryptlexFacade] Trame HTTP envoyée au service : ' + gen.getAsString());
		HttpResponse response = new Http().send(getHttpRequest('PUT', PUT_LICENCE_ENDPOINT + '/' + Id, gen.getAsString()));
		System.debug(response.getBody());
		// Erreur de génération de clé chez cryptlex
		if (response.getStatusCode() != 200) {
			System.debug('setSuspendStateKey - The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getBody());
			throw new CryptlexException('Erreur de mise à jour de clé cryptlex :' + response.getBody());
		}
		return true;
	}

	public static Boolean extendingKey(String id, Integer nbOfDays) {
		Integer extensionLength = nbOfDays * 24 * 60 * 60;
		System.debug('[CryptlexFacade] extension de clé annuelle Id =' + id);
		// Appel du webservices de clé		
		JSONGenerator gen = JSON.createGenerator(true);
		gen.writeStartObject();
		gen.writeNumberField('extensionLength', extensionLength);
		gen.writeEndObject();
		System.debug('[CryptlexFacade] Trame HTTP envoyée au service : ' + gen.getAsString());
		HttpResponse response = new Http().send(getHttpRequest('POST', LICENCE_ENDPOINT + '/' + id + '/extend', gen.getAsString()));
		System.debug(response.getBody());
		// Erreur de prolongement de clé chez cryptlex
		if (response.getStatusCode() != 200) {
			System.debug('extendingKey - The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getBody());
			throw new CryptlexException('Erreur de renouvellement de clé cryptlex :' + response.getBody());
		}
		return true;
	}

	public static Boolean extendingPerpetualKey(String id, Integer nbOfDays) {
		System.debug('[CryptlexFacade] extension de support de clé perpet Id =' + id);
		// Recuperation de la date de fin de support actuelle
		LicenseKey params = GetInformations(id);
		Date dateFinSupport = params.metadata.endUp;
		// Prolongement du support de la clé perpet : modification de la metadata ENDUP
		Date dateFinSupportNew = dateFinSupport.addDays(nbOfDays);
		Datetime dt = Datetime.newInstance(dateFinSupportNew.year(), dateFinSupportNew.month(), dateFinSupportNew.day());
		JSONGenerator gen = JSON.createGenerator(true);
		gen.writeStartObject();
		gen.writeFieldName('metadata');
		gen.writeStartArray();
		gen.writeStartObject();
		gen.writeStringField('key', 'ENDUPD');
		gen.writeStringField('value', dt.format('yyyy-MM-dd'));
		gen.writeEndObject();
		gen.writeEndArray();
		gen.writeEndObject();
		System.debug('[CryptlexFacade] Trame HTTP envoyée au service : ' + gen.getAsString());
		HttpResponse response = new Http().send(getHttpRequest('PUT', PUT_LICENCE_ENDPOINT + '/' + id, gen.getAsString()));
		System.debug(response.getBody());
		// Erreur de modification de clé chez cryptlex
		if (response.getStatusCode() != 200) {
			System.debug('extendingPerpetualKey - The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getBody());
			throw new CryptlexException('Erreur de mise à jour de clé cryptlex :' + response.getBody());
		}
		return true;
	}

	public static Boolean renewingPerpetualKey(String id) {
		System.debug('[CryptlexFacade] renouvellement de support de clé perpet Id =' + id);
		// Recuperation de la date de fin de support actuelle
		LicenseKey params = GetInformations(id);
		Date dateFinSupport = params.metadata.endUp;
		// Prolongement du support de la clé perpet : modification de la metadata ENDUP
		Date dateFinSupportNew = dateFinSupport.addYears(1);
		Datetime dt = Datetime.newInstance(dateFinSupportNew.year(), dateFinSupportNew.month(), dateFinSupportNew.day());
		JSONGenerator gen = JSON.createGenerator(true);
		gen.writeStartObject();
		gen.writeFieldName('metadata');
		gen.writeStartArray();
		gen.writeStartObject();
		gen.writeStringField('key', 'ENDUPD');
		gen.writeStringField('value', dt.format('yyyy-MM-dd'));
		gen.writeEndObject();
		gen.writeEndArray();
		gen.writeEndObject();
		System.debug('[CryptlexFacade] Trame HTTP envoyée au service : ' + gen.getAsString());
		HttpResponse response = new Http().send(getHttpRequest('PUT', PUT_LICENCE_ENDPOINT + '/' + id, gen.getAsString()));
		System.debug(response.getBody());
		// Erreur de modification de clé chez cryptlex
		if (response.getStatusCode() != 200) {
			System.debug('renewingPerpetualKey - The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getBody());
			throw new CryptlexException('Erreur de mise à jour de clé cryptlex :' + response.getBody());
		}
		return true;
	}

	public static Boolean renewingAnnualKey(String id) {
		System.debug('[CryptlexFacade] renouvellement de clé annuelle Id =' + id);
		// Appel du webservices de clé
		HttpResponse response = new Http().send(getHttpRequest('POST', LICENCE_ENDPOINT + '/' + id + '/renew', null));
		System.debug(response.getBody());
		// Erreur de renouvellement de clé chez cryptlex
		if (response.getStatusCode() != 200) {
			System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus() + ' ' + response.getBody());
			throw new CryptlexException('Erreur de renouvellement de clé cryptlex :' + response.getBody());
		}
		return true;
	}

	public static FlexeraController.ResultGetInformations GetInformationsForController(String id) {
		FlexeraController.ResultGetInformations result = new FlexeraController.ResultGetInformations();
		LicenseKey infos = GetInformations(id);
		// Convert Key -> Flexera 
		result.Status = true;
		result.IsInactive = infos.IsInactive;
		result.ExpirationDate = infos.ExpirationDate;
		result.Expiration = infos.Expiration;
		result.StartDate = infos.StartDate;
		result.Quantity = infos.Quantity;
		result.QuantityActivated = infos.QuantityActivated;
		if (infos.products != null) {
			result.Products = String.join(infos.products, ',');
		}
		result.EntitlementId = infos.id;
		// Recherche du domain dans les metadata (sauf trial)
		if (infos.metadata.domain != null) {
			result.licenseModel = Cryptlex.domainByCode.get(infos.metadata.domain);
		}
		// Remplacement de la date de fin sur les perptuelle
		if (infos.metadata.endUp != null) result.ExpirationDate = infos.metadata.endUp;
		// Remplacement du nombre d'activation sur les réseaux
		if (infos.allowedFloatingClients > 0) {
			result.Quantity = infos.allowedFloatingClients;
		}
		// Calcul de  la quantité achetée à partir de la quantité vendue :-((((
		result.QuantityBought = Integer.valueOf(ActivationHelper.getQuantityBoughtFromNbActivationsAllowed(result.Quantity));
		return result;
	}

	public static LicenseKey GetInformations(String id) {
		Boolean isRevoked, isSuspended;
		LicenseKey result = new LicenseKey();
		// Appel du webservices de license
		HttpResponse response2 = new Http().send(getHttpRequest('GET', LICENCE_ENDPOINT + '/' + id, null));
		System.debug(response2.getBody());
		// Erreur de renouvellement de clé chez cryptlex
		if (response2.getStatusCode() != 200) {
			System.debug('The status code returned was not expected: ' + response2.getStatusCode() + ' ' + response2.getStatus() + ' ' + response2.getBody());
			throw new CryptlexException('Erreur de recuperation d information dans cryptlex :' + response2.getBody());
		}
		// Get licenseId from response
		Integer totalActivations, totalDeactivations;
		JSONParser parser2 = JSON.createParser(response2.getBody());
		Map<String, String> mapMetadata = new Map<String, String> ();
		while (parser2.nextToken() != null) {
			if (JSONToken.FIELD_NAME.equals(parser2.getCurrentToken()) && 'suspended'.equalsIgnoreCase(parser2.getCurrentName())) {
				parser2.nextToken();
				isSuspended = parser2.getBooleanValue();
			} else if (JSONToken.FIELD_NAME.equals(parser2.getCurrentToken()) && 'revoked'.equalsIgnoreCase(parser2.getCurrentName())) {
				parser2.nextToken();
				isRevoked = parser2.getBooleanValue();
			} else if (JSONToken.FIELD_NAME.equals(parser2.getCurrentToken()) && 'expiresAt'.equalsIgnoreCase(parser2.getCurrentName())) {
				parser2.nextToken();
				System.debug('[CryptlexFacade] GetInformations expiresAt=' + parser2.getText());
				if (parser2.getText() != 'null') {
					Datetime dT = parser2.getDateTimeValue();
					result.ExpirationDate = Date.newInstance(dT.year(), dT.month(), dT.day());
				}
			} else if (JSONToken.FIELD_NAME.equals(parser2.getCurrentToken()) && 'expirationStrategy'.equalsIgnoreCase(parser2.getCurrentName())) {
				parser2.nextToken();
				result.Expiration = parser2.getText();
			} else if (JSONToken.FIELD_NAME.equals(parser2.getCurrentToken()) && 'id'.equalsIgnoreCase(parser2.getCurrentName())) {
				parser2.nextToken();
				result.id = parser2.getText();
			} else if (JSONToken.FIELD_NAME.equals(parser2.getCurrentToken()) && 'productId'.equalsIgnoreCase(parser2.getCurrentName())) {
				parser2.nextToken();
				result.productId = parser2.getText();
			} else if (JSONToken.FIELD_NAME.equals(parser2.getCurrentToken()) && 'createdAt'.equalsIgnoreCase(parser2.getCurrentName())) {
				parser2.nextToken();
				System.debug('[CryptlexFacade] GetInformations createdAt=' + parser2.getText());
				Datetime dT = parser2.getDateTimeValue();
				result.StartDate = Date.newInstance(dT.year(), dT.month(), dT.day());
			} else if (JSONToken.FIELD_NAME.equals(parser2.getCurrentToken()) && 'allowedActivations'.equalsIgnoreCase(parser2.getCurrentName())) {
				parser2.nextToken();
				System.debug('[CryptlexFacade] GetInformations allowedActivations=' + parser2.getText());
				result.Quantity = parser2.getIntegerValue();
			} else if (JSONToken.FIELD_NAME.equals(parser2.getCurrentToken()) && 'allowedFloatingClients'.equalsIgnoreCase(parser2.getCurrentName())) {
				parser2.nextToken();
				System.debug('[CryptlexFacade] GetInformations allowedFloatingClients=' + parser2.getText());
				result.allowedFloatingClients = parser2.getIntegerValue();
			} else if (JSONToken.FIELD_NAME.equals(parser2.getCurrentToken()) && 'totalActivations'.equalsIgnoreCase(parser2.getCurrentName())) {
				parser2.nextToken();
				System.debug('[CryptlexFacade] GetInformations totalActivations=' + parser2.getText());
				totalActivations = parser2.getIntegerValue();
			} else if (JSONToken.FIELD_NAME.equals(parser2.getCurrentToken()) && 'totalDeactivations'.equalsIgnoreCase(parser2.getCurrentName())) {
				parser2.nextToken();
				System.debug('[CryptlexFacade] GetInformations totalDeactivations=' + parser2.getText());
				totalDeactivations = parser2.getIntegerValue();
			} else if (JSONToken.FIELD_NAME.equals(parser2.getCurrentToken()) && 'metadata'.equalsIgnoreCase(parser2.getCurrentName())) {
				String key, value;
				while (parser2.nextToken() != JSONToken.END_ARRAY) { // Recuperation des metadata
					if (JSONToken.FIELD_NAME.equals(parser2.getCurrentToken()) && 'key'.equalsIgnoreCase(parser2.getCurrentName())) {
						parser2.nextToken();
						key = parser2.getText();
					} else if (JSONToken.FIELD_NAME.equals(parser2.getCurrentToken()) && 'value'.equalsIgnoreCase(parser2.getCurrentName())) {
						parser2.nextToken();
						value = parser2.getText();
						mapMetadata.put(key, value);
					}
				}
			}
		}
		// Clé active ou pas?
		result.IsInactive = isRevoked || isSuspended;
		// Nomber d'activations
		result.QuantityActivated = totalActivations;
		System.debug(mapMetadata);
		System.debug(response2.getBody().substringAfter('metadata'));
		// Recuperation des metadata
		System.debug('>>>> result.id = '+result.id);
		String softwareName = new SoftwareService().getSoftwareNameFromCryptlexProductId(result.productId);
		Software__c software = new SoftwareService().getSoftwareFromName(softwareName);
		System.debug('>>>> GetInformations - software = '+software);
		HelperCryptlexMetaData helper = HelperCryptlexMetadataFactory.getHelperCryptlexMetadata(software);
		result.metadata = helper.getMetaDataFromMap(mapMetadata);
		result.products = helper.getProducts(result);
		return result;
	}

	private static HttpRequest getHttpRequest(String verb, String endpoint, String body) {
		HttpRequest request = new HttpRequest();
		request.setMethod(verb);
		request.setTimeout(60000);
		request.setEndpoint(endpoint);
		request.setHeader('Content-Type', CONTENT_TYPE);
		request.setHeader('Content-Length','0');
		request.setHeader('Authorization', 'Bearer ' + BEARER_TOKEN);
		if (body != null && body.length() > 0) { request.setBody(body); }
		return request;
	}
}