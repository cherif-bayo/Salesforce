public class FlexeraController {

	private static String DISTRIBUTEUR_ATTRIBUTE = 'Distributeur';
	public static String EXPIRATION_PERMANENT = 'Permanent';
	public static String EXPIRATION_EXPIRING = 'Expiring';
	public static String LICENSETYPE_PERPETUAL = 'Perpétuelle';
	public static String LICENCE_TYPE_NT = 'Réseau';

	public static Boolean DeactivateEntitlement(String Id) {
		return CryptlexFacade.setSuspendStateKey(Id,true);
	}

	public static ResultGenerateKey Generate(Integer nbKeys, Flexera_Key__c key, String firstName, String lastName, String email, String countryCode, Account account) {
		System.debug('>>>> FlexeraController - Generate 1');
		return Generate(nbKeys, key, firstName, lastName, email, countryCode, account, false, null, null);
	}

	public static ResultGenerateKey Generate(Integer nbKeys, Flexera_Key__c key, Contact contact) {
		System.debug('>>>> FlexeraController - Generate 2');
		return Generate(nbKeys, key, contact.FirstName, contact.LastName, contact.Email, contact.MailingCountryCode, null, false, null, contact);
	}

	public static ResultGenerateKey Generate(Flexera_Key__c key, Lead lead) { // Pour les versions d'essai
		System.debug('>>>> FlexeraController - Generate 3');
		return Generate(1, key, lead.FirstName, lead.LastName, lead.Email, lead.CountryCode, null, true, lead, null);
	}

	public static ResultGenerateKey Generate(Integer nbKeys, Flexera_Key__c key, String firstName, String lastName, String email, String countryCode, Account account, Boolean hasLead, Lead lead, Contact contact) {
		System.debug('>>>> FlexeraController - Generate 4');
		ResultGenerateKey resultGenerateKey = new ResultGenerateKey();
		System.debug('key=' + key + ' email:' + email);
		try {
			for (Integer i = 0; i<nbKeys; i++) {
				LicenseKey ckey;
				if (EXPIRATION_PERMANENT.equals(key.Expiration__c) || LICENSETYPE_PERPETUAL.equalsIgnoreCase(key.Type_licence__c)) {
					ckey = CryptlexFacade.getNewPerpetualKey(key.Domaine_utilisateur__c,
					                                         key.Type_licence__c,
					                                         getProductsFromSolutionsAndOptions(key.XLSTAT_Solution__c, key.XLSTAT_Options__c),
					                                         key.Nb_activations_allowed__c,
					                                         Date.today());
				} else if (LICENCE_TYPE_NT.equals(key.Type_licence__c) || key.Is_Network__c) {
					ckey = CryptlexFacade.getNewNetworkKey(key.Domaine_utilisateur__c,
					                                      key.Type_licence__c,
					                                      getProductsFromSolutionsAndOptions(key.XLSTAT_Solution__c, key.XLSTAT_Options__c),
					                                      key.Nb_activations_allowed__c,
														  key.Date_limite__c);
				} else {
					ckey = CryptlexFacade.getNewAnnualKey(key.Domaine_utilisateur__c,
					                                      key.Type_licence__c,
					                                      getProductsFromSolutionsAndOptions(key.XLSTAT_Solution__c, key.XLSTAT_Options__c),
					                                      key.Nb_activations_allowed__c,
														  key.Date_limite__c);
				}

				Flexera_Key__c generatedKey = key.clone(false, true);
				generatedKey.Name = ckey.keyNumber;
				generatedKey.Entitlement_Id__c = ckey.id;
				if (hasLead) {
					generatedKey.Lead__c = lead.Id;
				} else {
					System.debug('>>>> generatedKey = '+generatedKey);
					if (contact != null) {
						System.debug('>>>> contact = '+contact);
						generatedKey.Contact__c = contact.Id;
					} else {
						generatedKey.Contact__c = key.Contact__c;
					}
				}
				resultGenerateKey.Status = true;
				resultGenerateKey.GeneratedKeys.add(generatedKey);
			}
		} catch(CryptlexException ce) {
			resultGenerateKey.Status = false;
		}

		return resultGenerateKey;
	}
	
	public static Boolean UpdateKey(Flexera_Key__c oldKey, Flexera_Key__c key) {
		System.debug('key=' + key);

		return CryptlexFacade.updateKey(oldKey.Entitlement_Id__c,
		                                key.Domaine_utilisateur__c,
		                                key.Type_licence__c,
		                                getProductsFromSolutionsAndOptions(key.XLSTAT_Solution__c, key.XLSTAT_Options__c),
		                                key.Nb_activations_allowed__c);
	}

	public static ResultGetInformations GetInformations(String entitlementId) {
		ResultGetInformations result;

		try {
			result = CryptlexFacade.GetInformationsForController(entitlementId);
			System.debug('[FlexeraController] GetInformations key='+entitlementId);
		} catch(CryptlexException ce) {
			System.debug('[FlexeraController] GetInformations exception lors de la recuperation de '+entitlementId+' message='+ce.getStackTraceString());
			result = new ResultGetInformations();
			result.Status = false;result.ErrorMessage = 'Aucune clé n\'existe avec cet id d\'activation.' + ce.getMessage() + ' : ' + ce.getStackTraceString();
		}

		return result;
	}

	public static Boolean UpdateKeyLimit(String entitlementId, String activationId, String expiration) {
		Boolean result = false;

		try {
			if (expiration.equals(EXPIRATION_PERMANENT)) {
				result = CryptlexFacade.renewingPerpetualKey(entitlementId);
			} else {
				result = CryptlexFacade.renewingAnnualKey(entitlementId);
			}
		} catch(CryptlexException ce) {
			System.debug('Impossible de prolonger la clé dans cryptlex :' + ce.getMessage() + ' -> ' + ce.getStackTraceString());
		}

		return result;
	}

	private static List<String> getProductsFromSolutionsAndOptions(String solution, String stringOptions) {
		String SEPARATOR_OPTIONS = ';';
		List<String> products = new List<String> (new List<String> { solution });
		List<String> options = new List<String> ();

		if (stringOptions != null && stringOptions.length()> 1) options = stringOptions.split(SEPARATOR_OPTIONS);
		products.addAll(options);

		return products;

	}

	public class ResultGetInformations {
		public String EntitlementId { get; set; }
		public String Contact { get; set; }
		public String LicenseModel { get; set; }
		public String Expiration { get; set; }
		public Date StartDate { get; set; }
		public Datetime ExpirationDate { get; set; }
		public Integer Quantity { get; set; }
		public Integer QuantityActivated { get; set; }
		public Integer QuantityBought { get; set; }
		public String Products { get; set; }
		public Boolean Status { get; set; }
		public String ErrorMessage { get; set; }
		public Boolean IsInactive { get; set; }
		public String ActivationId { get; set; }
        public Integer totalDeactivations { get; set; }

		public ResultGetInformations() {
			this.Status = false;
		}
	}

	public class ResultCreateEntitlement {
		public Boolean Status { get; set; }
		public String ActivationId { get; set; }
		public String EntitlementId { get; set; }

		public ResultCreateEntitlement() {
			this.Status = false;
		}
	}

	public class ResultGenerateKey {
		public Boolean Status { get; set; }
		public List<Flexera_Key__c> GeneratedKeys { get; set; }

		public ResultGenerateKey() {
			this.Status = false;
			this.GeneratedKeys = new List<Flexera_Key__c> ();
		}
	}

	public class FlexeraException extends Exception { }
}