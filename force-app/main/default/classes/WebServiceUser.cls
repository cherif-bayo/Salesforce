global class WebServiceUser {

	/* Variable Declaration */
	private static String PRODUCT_CODE_START = 'S_';

	private static Map<String, String> optionsSolutionsCodesByNames = new Map<String, String> { 'XLSTAT-3DPlot' => '3DP', 'XLSTAT-LatentClass' => 'LG' };

	private static String[] ModulesLibelles = new String[] {
		'XLSTAT-Pro',
		'XLSTAT-3DPlot',
		'XLSTAT-MX',
		'XLSTAT-Time',
		'XLSTAT-PLS',
		'XLSTAT-Pivot',
		'XLSTAT-SPC',
		'XLSTAT-Dose',
		'XLSTAT-Life',
		'XLSTAT-PLSPM',
		'XLSTAT-ADA',
		'XLSTAT-Power',
		'XLSTAT-Education',
		'XLSTAT-DOE',
		'XLSTAT-Sim',
		'XLSTAT-Conjoint',
		'XLSTAT-CCR',
		'XLSTAT-Danone',
		'XLSTAT-LG',
		'XLSTAT-OMICS'
	};

	private static Map<String, String> keysDomainsToProductCode = new Map<String, String> { 'company' => 'CMP', 'academic' => 'EDU', 'student' => 'STU', 'campus' => 'CAM' };

	private static Map<String, String> orderTypesToKeysTypes = new Map<String, String> {
		'Annuelle' => 'annual',
		'Perpétuelle' => 'perpetual',
		'Support et maintenance ( 1 an )' => 'perpetual',
		'Réseau' => 'network',
		'Small Campus' => 'small-campus',
		'Large Campus' => 'large-campus',
		'Classroom' => 'classroom'
	};

	private static Map<String, String> keysTypesToProductCode = new Map<String, String> {
		'annual' => 'AN',
		'perpetual' => 'PP',
		'update' => 'XS',
		'large-campus' => 'LC',
		'small-campus' => 'SC',
		'network' => 'NT',
		'classroom' => 'CR'
	};

	/* Classes Declaration */
	global class Activation {
		public Integer nb;
		public Integer nbAllowed;
	}

	global class Key {
		public String id;
		public String description;
		public String version;
		public Date expiration;
		public Activation activation;
		public Integer quantity;
		public List<String> products;
		public Boolean expired;
	}

	global class Customer {
		public String id;
		public String firstName;
		public String lastName;
		public String street1;
		public String postalCode;
		public String city;
		public String stateCode;
		public String countryCode;
		public String company;
		public String vatNumber;
		public String phone;
		public String email;
	}

	global class KeyDistrib {
		public Boolean expired;
		public Customer customer;
		public Date expiration;
		public Integer quantity;
		public String id;
		public String domain;
		public String type;
		public String description;
		public List<String> products;
		public String version;
		public String refOrder;
	}

	global class ResultJsonDistrib {
		public List<KeyDistrib> licenses;
		public Customer distributor;
	}

	global class MyAccount {
		webservice String id;
		webservice String firstName;
		webservice String lastName;
	}

	global class Result {
		webservice Boolean status;
		webservice String message;
	}

	global class ResultMyAccount {
		webservice Boolean status;
		webservice String message;
		webservice MyAccount myAccount;
	}

	global class ResultLicensesInformations {
		webservice Boolean status;
		webservice String message;
		webservice String json;
	}

	global class ResultLicenses {
		webservice Boolean status;
		webservice String message;
		webservice List<String> licenses;
	}

	/**
	 * [CanCreateAccount description]
	 * @param  email [description]
	 * @param  code  [description]
	 * @return       Class ResultMyAccount
	 */
	webservice static ResultMyAccount CanCreateAccount(String email, String code) {
		/* Variable Return */
		ResultMyAccount result = new ResultMyAccount();
		result.status = false;
		result.message = 'Client with email: ' + email + ' and code: ' + code + ' was not found.';

		try {
			//SELECT Contact informations
			Contact[] contact = [SELECT Website_Id__c, FirstName, LastName, Acces_MyAccount__c, Compte_MyAccount_cree__c FROM Contact WHERE email = :email AND Code_MyAccount__c = :code LIMIT 1];

			//IF query returns a result
			if (contact.size() > 0) {
				result.status = !contact[0].Compte_MyAccount_cree__c;

				if (result.status) {
					result.status = contact[0].Acces_MyAccount__c;

					if (result.status) {
						result.myAccount = new MyAccount();
						result.myAccount.firstName = contact[0].FirstName;
						result.myAccount.lastName = contact[0].LastName;
						result.myAccount.id = contact[0].Website_Id__c;

						result.message = 'Client can create account.';
					} else {
						result.message = 'Client found but not allowed to create an account.';
					}

					//Account's client existing
				} else {
					result.message = 'Client has already created his account.';
				}
			}

		} catch(Exception ex) {
			result.message = ex.getMessage();
		}

		return result;
	}

	/**
	 * [CanAuthenticate description]
	 * @param  email [description]
	 * @return       Class ResultMyAccount
	 */
	webservice static ResultMyAccount CanAuthenticate(String email) {
		ResultMyAccount result = new ResultMyAccount();
        String hasNotCreateHisAccount = 'Client has not created his account.';

		try {
			List<Contact> contact = [SELECT Website_Id__c, FirstName, LastName, Acces_MyAccount__c, Compte_MyAccount_cree__c FROM Contact Where email = :email];

			if (contact.isEmpty()) {
				result.message = 'Client with email: ' + email + ' was not found.';
				result.status = false;
				return result;
			}
            
            if (contact.size() > 1){
                Map<Boolean, Contact> contactsByActivation = new Map<Boolean, Contact> ();
                
                for (Contact ctt : contact) if (ctt.Compte_MyAccount_cree__c != false) {
					contactsByActivation.put(ctt.Compte_MyAccount_cree__c, ctt);
				}
                if (!contactsByActivation.isEmpty()){
                    List<Contact> listToLoopOns = contactsByActivation.values();
                    for (Contact ct : listToLoopOns) {
                        result.status = true;
                        result.message = 'Authentification successfull';
                        result.myAccount = new MyAccount();
                        result.myAccount.firstName = ct.FirstName;
                        result.myAccount.lastName = ct.LastName;
                        result.myAccount.id = ct.Website_Id__c;
                    }       
                }else {
                    result.message = hasNotCreateHisAccount;
                    result.status = false;
                    return result;
                }
            }else {
                if (!contact.get(0).Compte_MyAccount_cree__c) {
                    result.message = hasNotCreateHisAccount;
                    result.status = false;
                    return result;
                }
    
                if (!contact.get(0).Acces_MyAccount__c) {
                    result.message = 'Client found but not allowed to connect to his account.';
                    result.status = false;
                    return result;
                }
    
                // return personnal infos about associated contact
                result.status = true;
                result.message = 'Authentification successfull';
                result.myAccount = new MyAccount();
                result.myAccount.firstName = contact.get(0).FirstName;
                result.myAccount.lastName = contact.get(0).LastName;
                result.myAccount.id = contact.get(0).Website_Id__c;
             }
			
		} catch(Exception ex) {
			result.status = false;
			result.message = ex.getMessage();
		}

		return result;
	}

	/**
	 * [Create description]
	 * @param  email [description]
	 * @param  code  [description]
	 * @return       Class Result{status, message}
	 */
	webservice static Result Create(String email, String code) {
		/* Variable Return */
		Result result = new Result();
		result.status = false;
		result.message = 'Client with email: ' + email + ' and code : ' + code + ' was not found.';

		try {
			Contact[] contact = [SELECT Date_creation_compte_MyAccount__c, Compte_MyAccount_cree__c FROM Contact Where email = :email AND Code_MyAccount__c = :code AND Compte_MyAccount_cree__c = false AND Acces_MyAccount__c = true limit 1];

			if (contact.size() > 0) {
				contact[0].Compte_MyAccount_cree__c = true;
				contact[0].Date_creation_compte_MyAccount__c = DateTime.now();

				update contact;

				result.status = true;
				result.message = 'Client updated.';
			}
		} catch(Exception ex) {
			result.message = ex.getMessage();
		}

		return result;
	}

	/**
	 * [Unsubscribe description]
	 * @param  email [description]
	 * @return       Class Result{status, message}
	 */
	webservice static Result Unsubscribe(String email) {
		/* Variable Return */
		Result result = new Result();
		result.status = true;

		try {
			Contact[] contact = [SELECT No_mailling__c FROM Contact WHERE Email = :email OR Second_mail__c = :email];
			Lead[] lead = [SELECT No_mailling__c FROM Lead WHERE Email = :email];

			if (contact.size() > 0) {
				for (Contact c : contact) {
					c.No_mailling__c = true;
				}

				update contact;
			}
			if (lead.size() > 0) {
				for (Lead l : lead) {
					l.No_mailling__c = true;
				}

				update lead;
			}
			if (contact.size() == 0 && lead.size() == 0) {
				Lead l = new Lead();
				l.Email = email;
				l.LastName = email;
				l.Company = email;
				l.Status = 'Ne souhaite pas être contactée';
				l.No_mailling__c = true;

				insert l;

				result.message = 'User with email: ' + email + ' inserted';
			} else {
				result.message = 'User with email: ' + email + ' updated';
			}
		} catch(Exception e) {
			result.message = e.getMessage();
			result.status = false;
		}

		return result;
	}

	/**
	 * [CreateForTest description]
	 * @param  email [description]
	 * @return       Class Result{status, message}
	 */
	webservice static Result CreateForTest(String email) {
		/* Variable Return */
		Result result = new Result();
		result.status = true;

		try {
			Account contact = new Account();
			contact.Type = 'Test';
			contact.FirstName = email;
			contact.LastName = email;
			contact.PersonEmail = email;

			insert contact;

			contact = [SELECT Code_MyAccount__pc FROM Account WHERE Id = :contact.Id limit 1];

			result.message = contact.Code_MyAccount__pc;

		} catch(Exception e) {
			result.message = e.getMessage();
			result.status = false;
		}

		return result;
	}

	/**
	 * [formatProductCode description]
	 * @param  solutionName [description]
	 * @param  domain       [description]
	 * @param  licenseType  [description]
	 * @return              Class ResultLicensesInformations
	 */
	private static String formatProductCode(String solutionName, String domain, String licenseType) {
		return PRODUCT_CODE_START + solutionName + '_' + keysDomainsToProductCode.get(domain) + '_' + keysTypesToProductCode.get(licenseType);
	}

	/**
	 * [GetLicensesInformations description]
	 * @param  licenses [description]
	 * @return          [description]
	 */
	webservice static ResultLicensesInformations GetLicensesInformations(List<String> licenses) {
		/* Variable Return */
		ResultLicensesInformations result = new ResultLicensesInformations();
		result.status = true;
		result.message = '';

		try {
			Map<String, Activation> activationById = new Map<String, Activation> ();
			Map<String, Integer> quantityById = new Map<String, Integer> ();
			Map<String, List<String>> productsByLicense = new Map<String, List<String>> ();
			Boolean licenseActivationsFound = true;
			SolutionConverter solutionConverter = new SolutionConverter();

			Map<String, String> KeyEntitlementIdByName = new Map<String, String> ();
			Flexera_Key__c[] allKeys = [SELECT Name, Entitlement_Id__c FROM Flexera_Key__c WHERE Name in :licenses];
			for (Flexera_Key__c key : allKeys) if (key.Entitlement_Id__c != null) KeyEntitlementIdByName.put(key.name, key.Entitlement_Id__c);

			for (Integer i = licenses.size() - 1; i >= 0; i--) {
				String license = licenses[i];

				if (KeyEntitlementIdByName.containsKey(license)) { // Si la license a un entitlementId dans salesforce
					FlexeraController.ResultGetInformations resultGetInformations = FlexeraController.GetInformations(KeyEntitlementIdByName.get(license));
					if (!resultGetInformations.Status) { // Si la licence existe encore dans cryptlex
						licenses.remove(i);
					} else {
						Activation activation = new Activation();
						activation.Nb = resultGetInformations.QuantityActivated;
						activation.NbAllowed = resultGetInformations.Quantity;
						activationById.put(license, activation);
						quantityById.put(license, resultGetInformations.QuantityBought);
						productsByLicense.put(license, solutionConverter.FindFromProductsCodes(resultGetInformations.Products));
					}
				} else {
					licenses.remove(i);
				}
			}

			Flexera_Key__c[] flexeraKeys = [SELECT Id, Version__c, Domaine_utilisateur__c, Type_licence__c, Name, Modules__c, Version__r.Name, Date_Limite__c, Order__c FROM Flexera_Key__c WHERE Name in :licenses ORDER BY Date_Limite__c DESC];

			if (flexeraKeys.size() > 0) {
				Map<String, Flexera_Key__c> mapFlexeraKeys = new Map<String, Flexera_Key__c> ();
				for (Flexera_Key__c flexeraKey : flexeraKeys) {
					if (mapFlexeraKeys.containsKey(flexeraKey.Name) == false) {
						mapFlexeraKeys.put(flexeraKey.Name, flexeraKey);
					}
				}

				Date todayDate = Date.today();

				Date minDate = null;
				List<Flexera_Key__c> keysWithNoVersion = new List<Flexera_Key__c> ();
				for (Flexera_Key__c key : mapFlexeraKeys.values()) {
					if (key.Version__c == null) {
						keysWithNoVersion.add(key);
						if (minDate == null || key.Date_Limite__c<minDate) {
							minDate = key.Date_Limite__c;
						}
					}
				}

				Map<Id, String> versionsNamesByKeyId = new Map<Id, String> ();
				if (keysWithNoVersion.size()> 0) {
					Version__c[] versions = [select Id, Name, Date__c from Version__c where Date__c <= :minDate order by Date__c DESC];

					for (Flexera_Key__c key : keysWithNoVersion) {
						for (Version__c version : versions) {
							if (version.Date__c <= key.Date_Limite__c) {
								versionsNamesByKeyId.put(key.Id, version.Name);
								break;
							}
						}
					}
				}

				Map<String, Map<String, List<Key>>> keysByDomain = new Map<String, Map<String, List<Key>>> ();
				for (Flexera_Key__c flexeraKey : mapFlexeraKeys.values()) {
					Key key = new Key();
					key.Id = flexeraKey.Name;
					key.Description = flexeraKey.Modules__c;
					key.Version = flexeraKey.Version__c == null ? versionsNamesByKeyId.get(flexeraKey.Id) : flexeraKey.Version__r.Name;
					key.Expiration = flexeraKey.Date_Limite__c;
					key.Activation = activationById.get(flexeraKey.Name);
					if (flexeraKey.Type_Licence__c == 'Réseau') {
						key.Activation.NbAllowed = 1;
					}
					key.Quantity = flexeraKey.Domaine_Utilisateur__c == 'Campus' ? 1 : quantityById.get(flexeraKey.Name);
					if (flexeraKey.Type_Licence__c == 'Réseau') {
						Integer quantityToChange = quantityById.get(flexeraKey.Name);
						key.Quantity = quantityToChange< 20 ? quantityToChange + 1 : Integer.valueof(quantityToChange + quantityToChange * 0.1);
					}
					key.Expired = flexeraKey.Date_Limite__c<todayDate;

					String domain = flexeraKey.Domaine_Utilisateur__c.toLowerCase();
					if (domain == 'editeur') {
						domain = 'student';
					}
					String type = orderTypesToKeysTypes.get(flexeraKey.Type_Licence__c);

					if (keysByDomain.ContainsKey(domain)) {
						if (keysByDomain.get(domain).ContainsKey(type)) {
							keysByDomain.get(domain).get(type).add(key);
						} else {
							List<Key> keys = new List<Key> { key };
							keysByDomain.get(domain).put(type, keys);
						}
					} else {
						Map<String, List<Key>> keysByType = new Map<String, List<Key>> ();
						List<Key> keys = new List<Key> { key };
						keysByType.put(type, keys);
						keysByDomain.put(domain, keysByType);
					}

					key.products = new List<String> ();
					for (String product : productsByLicense.get(flexeraKey.Name)) {
						key.products.Add(formatProductCode(product, domain, type));
					}
				}

				if (result.status == true) {
					result.json = JSON.serialize(keysByDomain);
				}
			} else {
				result.status = false;
			}
		} catch(Exception e) {
			result.status = false;
			result.message = e.getMessage();
		}

		return result;
	}

	/**
	 * [GetLicensesInformationsDistrib description]
	 * @param  contactDistributeurId [description]
	 * @return                       [description]
	 */
	webservice static ResultLicensesInformations GetLicensesInformationsDistrib(String contactDistributeurId) {
		ResultLicensesInformations result = new ResultLicensesInformations();
		result.status = false;
		result.message = 'method deprecated';

		//RETURN 
		return result;
	}

	/**
	 * [GetLicenses description]
	 * @param  id [description]
	 * @return    [description]
	 */
	webservice static ResultLicenses GetLicenses(String websiteId) {
		ResultLicenses result = new ResultLicenses();
		result.status = true;
		result.licenses = new List<String> ();

		try {
			AggregateResult[] groupedResults;
			groupedResults
			= [SELECT Name, MAX(Date_Limite__c), MAX(Order__r.CreatedDate)
				FROM Flexera_Key__c
				WHERE Contact__r.Website_Id__c = :websiteId AND Is_Inactive__c = false AND (Order__r.Status in ('Validée','Payée') OR Campaign__c != null)
				GROUP BY Name];
			if (groupedResults.size()> 0) {
				for (AggregateResult ar : groupedResults) {
					String name = (String) ar.get('Name');
					if ((name.contains('-') && name.length() != 44) || name.contains('-') == false) {
						result.licenses.add(name);
					}
				}
			} else {
				result.status = false;
				result.message = 'No keys found for contact id: ' + websiteId;
			}
		} catch(Exception e) {
			result.status = false;
			result.message = e.getMessage();
		}

		return result;
	}

}