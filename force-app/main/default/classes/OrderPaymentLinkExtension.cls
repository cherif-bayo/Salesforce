public class OrderPaymentLinkExtension {

	public static String PAYMENT_LINK_ENDPOINT = Parameters.getString('URL_PaymentLink');
    public static String ADDINSOFT_INC_COMPANY = Parameters.getString('Company_Addinsoft_Inc');
    public static String TRAINING_PRODUCT = 'Formation';
    

	public Decimal montant { get; set; }
	public String email { get; set; }
	public Order order { get; set; }

	public class PaymentLinkException extends Exception {}

	public OrderPaymentLinkExtension(ApexPages.StandardController stdController) {
		order = [SELECT CurrencyIsoCode, OrderNumber, AddinSoftCompany__c, Contact_Email__c, Contact_li_langue__c, TotalAmountAfterDiscount__c, AmountTVA__c, Account.billingCountryCode, Type_licence__c, PaymentLinkAmount__c From Order WHERE Id = :stdController.getId()];
		email = order.Contact_Email__c;
		montant = order.PaymentLinkAmount__c.setScale(2);
	}

	public PageReference generateLink() {
		try {
			String lang = order.Contact_li_langue__c != null ? order.Contact_li_langue__c :'en';
            Integer AddinsoftCustomLinkValue = Integer.valueOf(Parameters.getString('Custom_Link_Addinsoft'));
            Integer AddinsoftIncCustomLinkValue = Integer.valueOf(Parameters.getString('Custom_Link_Addinsoft_Inc'));
            
            List<String> customLinkCompany = System.Label.CustomLinkInc.split(';');
			boolean isAddinsoftInc = customLinkCompany.contains(order.Account.billingCountryCode);
            Integer addinsoftCompany = AddinsoftCustomLinkValue;
            
            if(isAddinsoftInc){addinsoftCompany = AddinsoftIncCustomLinkValue;}
            if(order.Type_licence__c == TRAINING_PRODUCT){addinsoftCompany = Integer.valueOf(Parameters.getString('Custom_Link_Addinsoft'));}
            
            Integer montantCentimes = order.CurrencyIsoCode == 'JPY' ? Math.round(montant) : Math.round(montant * 100);
			// Paramètres d'appel du webservices Lien de Paiement
			String payLoad =  'email=' + EncodingUtil.urlEncode(email,'UTF-8') 
							+ '&currencyISOCode=' + EncodingUtil.urlEncode(order.CurrencyIsoCode, 'UTF-8') 
							+ '&amount=' + EncodingUtil.urlEncode(String.valueOf(montantCentimes), 'UTF-8')
                			+ '&companyId=' + EncodingUtil.urlEncode(String.valueOf(addinsoftCompany), 'UTF-8')
							+ '&quoteNumber=' + EncodingUtil.urlEncode(order.OrderNumber, 'UTF-8') 
							+ '&language=' + EncodingUtil.urlEncode(lang, 'UTF-8');
			System.debug('[OrderPaymentLinkExtension] Payload HTTP envoyée au service : ' + payLoad);

			// Request - Response Payment Link
			HttpRequest request = new HttpRequest();
			request.setMethod('POST');
			request.setTimeOut(60000);
			request.setEndpoint(PAYMENT_LINK_ENDPOINT);
			request.setBody(payLoad);

			HttpResponse response = new Http().send(request);
			System.debug(response.getBody());

			// Cas d'Erreur de génération de lien de paiement
			if (response.getStatusCode() != 201) throw new PaymentLinkException ('Code Retour Service Lien de Paiement Invalide (' + response.getStatusCode() + ') :' + response.getBody());

			// Get Payement Link from response
			JSONParser parser = JSON.createParser(response.getBody());
			while (parser.nextToken() != null) {
				if (JSONToken.FIELD_NAME.equals(parser.getCurrentToken()) && 'url'.equalsIgnoreCase(parser.getCurrentName())) {
					parser.nextToken();
					order.CustomLink__c = parser.getText();
				} 
			}

			// Save url of payment link
			update order;

			PageReference pageRef = new PageReference('/' + order.Id);
			pageRef.setRedirect(true);

			return pageRef;
		} catch(Exception e) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Impossible de générer un lien de paiement :' + e.getMessage()));
		}
		return null;
	}

	public PageReference cancel() {
		PageReference pageRef = new PageReference('/' + order.Id);
		pageRef.setRedirect(true);

		return pageRef;
	}
}