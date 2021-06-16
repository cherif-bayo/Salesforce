global class TaxamoFacade {

	private static String TAXAMO_ENDPOINT_TAXE = 'https://services.taxamo.com/api/v2/tax/calculate';
	private static String TAXAMO_ENDPOINT_TRANSACTION = 'https://services.taxamo.com/api/v2/transactions';
	private static String API_PRIVATE_KEY = Parameters.getString('Taxamo_Key');
	private static String CONTENT_TYPE = 'application/json;charset=UTF-8';
    private static String PRODUCT_TAX_CODE = '210116';
	private static Integer TIMEOUT_LIMIT = 60000;
	private static TaxamoServiceParams params;

	global class TaxamoServiceParams {
		public String currency_code;
		public TaxamoInvoiceAddress invoice_address;
		public TaxamoTaxData tax_data;
		public TaxamoProductLineItem[] transaction_lines;
		public String billing_country_code;
	}

	global class TaxamoTaxData {
		public Certificate certificat;
	}

	global class Certificate {
		public String certificate_id;
	}

	global class TaxamoInvoiceAddress {
		public String building_number;
		public String street_name;
		public String city;
		public String region;
		public String postal_code;
		public String country;
	}

	global class TaxamoProductLineItem {
		public String custom_id; //missing-required-key
		public String product_type; //Computer software
		public Decimal unit_price; //10
		public Integer quantity; //10
		public String product_code; //BASIC
		public String description; //Solution simple
        public String product_tax_code; // Product code to calaculate taxes
	}

	public static String getTaxamoJsonResponse(TaxamoServiceParams p, Boolean isTransaction) {
		System.debug ('Taxamo params :'+p);
		params = p;
		Integer tax_amount = 0; //Default Tax
		String json = getJsonPayload();
				
		// Choix du endpoint transaction (enregistrement dans le livre de compte Taxamo) ou taxe (calcul pour information)
		String endpoint = isTransaction? TAXAMO_ENDPOINT_TRANSACTION :TAXAMO_ENDPOINT_TAXE;

		// Appel du webservices de taxe
		System.debug('[CryptlexFacade] Trame HTTP envoyée au service Taxamo: ' + json);
		HttpRequest request = new HttpRequest();
		request.setMethod('POST');
		request.setTimeOut(TIMEOUT_LIMIT);
		request.setEndpoint(endpoint);
		request.setHeader('Content-Type', CONTENT_TYPE);
		request.setHeader('Private-Token', API_PRIVATE_KEY);
		request.setBody(json);
		HttpResponse response = new Http().send(request);
		System.debug(response.getBody());
		
		// Erreur de calcul de taxe
		if (response.getStatusCode() != 200) {
			System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getBody());
			throw new TaxamoException('Erreur de récupération de taxe :' + response.getBody() + p );
		}

		System.debug('Récupération de taxe :' + response.getBody());		
		return response.getBody();
	}

	private static String getJsonPayload() {
	// Generation du paylod json
		JSONGenerator gen = JSON.createGenerator(true);
		gen.writeStartObject();
		gen.writeFieldName('transaction');
		gen.writeStartObject();
		if (params.currency_code != null)			gen.writeStringField('currency_code', params.currency_code);
		if (params.billing_country_code != null)	gen.writeStringField('billing_country_code', params.billing_country_code);

		gen.writeFieldName('invoice_address');
		gen.writeStartObject();
		if (params.invoice_address.building_number != null) gen.writeStringField('building_number', params.invoice_address.building_number);
		if (params.invoice_address.street_name != null)		gen.writeStringField('street_name', params.invoice_address.street_name);
		if (params.invoice_address.city != null)			gen.writeStringField('city', params.invoice_address.city);
		if (params.invoice_address.postal_code != null)		gen.writeStringField('postal_code', params.invoice_address.postal_code);
		if (params.invoice_address.region != null)			gen.writeStringField('region', params.invoice_address.region);
		if (params.invoice_address.country != null)			gen.writeStringField('country', params.invoice_address.country);
        
		gen.writeEndObject();

		if (params.tax_data != null) {
			gen.writeFieldName('tax_data');
			gen.writeStartObject();
			gen.writeFieldName('us_tax_exemption_certificate');
			gen.writeStartObject();
			gen.writeStringField('certificate_id', params.tax_data.certificat.certificate_id);
			gen.writeEndObject();
			gen.writeEndObject();			
		}

		gen.writeFieldName('transaction_lines');
		gen.writeStartArray();
		for (TaxamoProductLineItem item :params.transaction_lines) {
			gen.writeStartObject();
			if (item.custom_id != null)			gen.writeStringField('custom_id', item.custom_id);
			if (item.product_type != null)		gen.writeStringField('product_type', item.product_type);
			if (item.unit_price != null)		gen.writeNumberField('unit_price', item.unit_price);
			if (item.quantity != null)			gen.writeNumberField('quantity', item.quantity);
			if (item.product_code != null)		gen.writeStringField('product_code', item.product_code);
			if (item.product_code != null)		gen.writeStringField('description', item.product_code);
           	if (item.product_tax_code != null)	gen.writeStringField('product_tax_code', PRODUCT_TAX_CODE);
            
			gen.writeEndObject();
		}
		gen.writeEndArray();

		gen.writeEndObject();
		gen.writeEndObject();

		return gen.getAsString();
	}
}