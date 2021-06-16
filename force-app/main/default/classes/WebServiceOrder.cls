/**
* @description Version du webservices correspondant aux commandes share-it
* A supprimer à échéance des paiements share-it
* plan.isAutoRenewal : il s'agit d'un renouvellement share-it automatique d'une annuelle
* order.Ref_ShareIt__c contient des , si il y a une renouvellement de l'option 3Dplot ou latent class aprés le renouvellement des solutions
*/ 
global class WebServiceOrder {
	private static Map<String, String> planLicenseTypeToLicenseTypeNalpeiron = new Map<String, String> { 'Annuelle' => 'ANNUAL', 'Perpétuelle' => 'PERPETUAL' };
	private static Map<String, Integer> licenseTypePriorities = new Map<String, Integer> { 'N.A.' => 0, 'Annuelle' => 1, 'Perpétuelle' => 2, 'Support et maintenance ( 1 an )' => 3, 'Réseau' => 4, 'Campus' => 5, 'Small Campus' => 5, 'Large Campus' => 5, 'Classroom' => 5 };
	private static Map<String, Integer> userDomainPriorities = new Map<String, Integer> { 'N.A.' => 0, 'Entreprise/Privé' => 1, 'Education' => 1, 'Etudiant' => 1, 'Campus' => 1, 'Editeur' => 1 };
	private static Map<String, String> productDomainToOrderDomain = new Map<String, String> { 'Entreprise/Privé' => 'Company', 'Education' => 'Academic', 'Etudiant' => 'Student' };
	private static Map<String, String> productLicenseTypeToOrderLicenseType = new Map<String, String> { 'Large Campus' => 'Campus', 'Small Campus' => 'Campus', 'Classroom' => 'Campus' };
	private static Map<String, String> languageToContactLanguage = new Map<String, String> { 'de' => 'DE', 'es' => 'ES', 'en' => 'US', 'ja' => 'JP', 'fr' => 'FR' };
	private static Map<String, String> affiliateToAccountId = new Map<String, String> { 'Mindware' => '0012400000ER4mV', 'Statcon' => '0012400000McLO8' };
	private static Integer INDEX_PRODUCT_CODE_USER_DOMAIN = 2;
	private static Integer INDEX_PRODUCT_CODE_LICENSE_TYPE = 3;
	private static String SEND_KEY_USER_DOMAIN_COMPANY = 'Company';
	private static String SEND_KEY_USER_DOMAIN_ACADEMIC = 'Academic';
	private static String SEND_KEY_LICENSE_TYPE_1 = 'Annuelle';
	private static String SEND_KEY_LICENSE_TYPE_2 = 'Perpétuelle';
	private static String SEND_KEY_LICENSE_TYPE_3 = 'Support et maintenance ( 1 an )';
	private static String GENERATE_LICENSE_USER_DOMAIN_1 = 'Entreprise/Privé';
	private static String GENERATE_LICENSE_USER_DOMAIN_2 = 'Etudiant';
	private static String GENERATE_LICENSE_USER_DOMAIN_3 = 'Education';
	private static String GENERATE_LICENSE_NO_TYPE_LICENSE_1 = 'Support et maintenance ( 1 an )';
	private static String GENERATE_LICENSE_NO_TYPE_LICENSE_3 = 'Campus';
	private static String PRODUCT_FAMILY_SOLUTION = 'Solution';
	private static String PRODUCT_FAMILY_OPTION = 'Module';
	private static Map<String, String> shareItLanguageToSfLanguage = new Map<String, String> { 'English' => 'US', 'French' => 'FR', 'German' => 'DE', 'Spanish' => 'ES', 'Japanese' => 'JP' };
	private static String DEFAULT_LANGUAGE = 'US';
	private static Integer MAX_LENGTH_FIRST_NAME = 40;
	private static Integer MAX_LENGTH_LAST_NAME = 80;
	private static Integer MAX_LENGTH_POSTAL_CODE = 20;
	private static Set<String> countriesCodesWithStatesCodes = new Set<String> { 'CA', 'AU', 'US' };
	private static Set<String> productCodePartOptions = new Set<String> { '3DP', 'CCR', 'LG' };
	private static String BILLING_WIRE = 'WireTransfer';
	private static String BILLING_CHECK = 'Check';
	private static String QUOTE_TYPE = 'Devis';
	private static Map<String, String> quoteTypeByBillingType = new Map<String, String> {
		BILLING_WIRE => 'Virement',
		BILLING_CHECK => 'Chèque'
	};

	global class PlanProduct {
		webservice String productCode;
		webservice String productName;
		webservice Integer quantity;
		webservice Decimal unitPrice;
		webservice String couponReference;
		webservice String affiliate;
		webservice String productFamily;
		webservice String currencyISOCode;
	}

	global class Customer {
		webservice String id;
		webservice String firstName;
		webservice String lastName;
		webservice String email;
		webservice String company;
		webservice String countryCode;
		webservice String street1;
		webservice String street2;
		webservice String stateCode;
		webservice String postalCode;
		webservice String city;
		webservice String language;
		webservice String vATNumber;
		webservice String phone;
	}

	global class Plan {
		webservice String id;
		webservice String currencyISOCode;
		webservice PlanProduct[] planProducts;
		webservice Customer customerDelivering;
		webservice Customer customerBilling;
		webservice String websiteProvenance;
		webservice String paymentMethod;
		webservice String licenseType;
		webservice String refShareIt;
		webservice Boolean generateLicense;
		webservice Boolean status;
		webservice String message;
		webservice Boolean isQuote;
		webservice String[] keysToUpdate;
		webservice Boolean isUpdate = false;
		webservice Boolean isAutoRenewal = false;
		webservice Boolean isMyAccount = false;
		webservice String oldRefShareIt;
	}

	private class CustomerWrapper {
		private Customer customer;

		public Boolean IsPersonAndHasCompanyDomain { get; set; }

		public Boolean accountUpdate { get; set; }
		public Boolean contactUpdate { get; set; }

		public Boolean status { get; set; }
		public String message { get; set; }

		public List<Account> account { get; set; }
		public List<Contact> contact { get; set; }

		public String PostalCode { get {
				return this.customer.postalCode;
			} }

		public CustomerWrapper(Customer customer) {
			this.customer = customer;
			this.IsPersonAndHasCompanyDomain = false;
		}

		public void InsertInSalesforce(Boolean isQuote, Boolean isAutoRenewal, String currencyIsoCode, String userDomain) {
			this.status = true;

			this.customer.firstName = this.customer.firstName.trim();
			this.customer.lastName = this.customer.lastName.trim();

			if (this.customer.postalCode.length() > MAX_LENGTH_POSTAL_CODE) {
				this.customer.postalCode = this.customer.postalCode.substring(0, MAX_LENGTH_POSTAL_CODE - 1);
			}

			this.account = new List<Account> ();
			this.contact = new List<Contact> ();
			this.accountUpdate = false;
			this.contactUpdate = false;

			if (States.StatesByCountryCode.containsKey(this.customer.countryCode)) {
				if (States.StatesByCountryCode.get(this.customer.countryCode).contains(this.customer.stateCode) == false) {
					this.customer.stateCode = '';
				}
			}

			String country = null;
			List<Schema.PicklistEntry> pick_list_values = Schema.SObjectType.Contact.fields.Pays__c.getPickListValues(); //grab the list of picklist values for the passed field on the sobject
			for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list
				if (a.getLabel().startsWith(this.customer.countryCode)) {
					country = a.getValue();
					break;
				}
			}

			if (this.customer.id != null && this.customer.id != '') {
				contact = [select Domaine_Utilisateur__c, Salutation, MailingCountryCode, MailingPostalCode, MailingStreet, MailingCity, MailingStateCode, Id, AccountId, FirstName, LastName, Email, Website_Auto__c, Pays__c, Langue__c, CurrencyIsoCode from Contact where Website_Id__c = :this.customer.id OR Id = :this.customer.id limit 1];

				if (contact.size() > 0) {
					account = [select Discount_Global__c, ShippingCountryCode, Salutation, Id, Name, IsPersonAccount, Industry, Sous_secteur__c, Num_ro_de_TVA__c, Type, Website_Auto__c, BillingCountryCode, BillingPostalCode, BillingStreet, BillingStateCode, BillingCity, CurrencyIsoCode, Selection_importance__c, Domaine_utilisateur__c from Account where Id = :contact[0].AccountId limit 1];

					this.contact[0].MailingCountryCode = this.customer.CountryCode != this.contact[0].MailingCountryCode ? this.contact[0].MailingCountryCode : this.customer.CountryCode;
					this.contact[0].MailingPostalCode = this.customer.PostalCode != this.contact[0].MailingPostalCode ? this.contact[0].MailingPostalCode : this.customer.PostalCode;
					if (this.customer.street2 != null) {
						this.contact[0].MailingStreet = this.customer.street1 + '\n\n' + this.customer.street2 != this.contact[0].MailingStreet ? this.contact[0].MailingStreet : this.customer.street1 + '\n\n' + this.customer.street2;
					} else {
						this.contact[0].MailingStreet = this.customer.street1 != this.contact[0].MailingStreet ? this.contact[0].MailingStreet : this.customer.street1;
					}
					this.contact[0].MailingStateCode = this.customer.StateCode != this.contact[0].MailingStateCode ? this.contact[0].MailingStateCode : this.customer.StateCode;
					this.contact[0].MailingCity = this.customer.City != this.contact[0].MailingCity ? this.contact[0].MailingCity : this.customer.City;

					update this.account[0];
				} else {
					this.status = false;
					this.message = 'No contact found for id: ' + this.customer.id;
				}

				if (account.size() > 0) {
					this.account[0].BillingCountryCode = this.customer.CountryCode != this.account[0].BillingCountryCode ? this.account[0].BillingCountryCode : this.customer.CountryCode;
					this.account[0].BillingPostalCode = this.customer.PostalCode != this.account[0].BillingPostalCode ? this.account[0].BillingPostalCode : this.customer.PostalCode;
					if (this.customer.street2 != null) {
						this.account[0].BillingStreet = this.customer.street1 + '\n\n' + this.customer.street2 != this.account[0].BillingStreet ? this.account[0].BillingStreet : this.customer.street1 + '\n\n' + this.customer.street2;
					} else {
						this.account[0].BillingStreet = this.customer.street1 != this.account[0].BillingStreet ? this.account[0].BillingStreet : this.customer.street1;
					}
					this.account[0].BillingStateCode = this.customer.StateCode != this.account[0].BillingStateCode ? this.account[0].BillingStateCode : this.customer.StateCode;
					this.account[0].BillingCity = this.customer.City != this.account[0].BillingCity ? this.account[0].BillingCity : this.customer.City;
					this.account[0].Num_ro_de_TVA__c = this.customer.vATNumber != null ? this.customer.vATNumber : this.account[0].Num_ro_de_TVA__c;

					update this.account[0];
				}
			} else {
				Boolean contactFoundAutoRenewal = false;
				if (isAutoRenewal) {
					contact = [select Domaine_Utilisateur__c, Salutation, MailingCountryCode, MailingPostalCode, MailingStreet, MailingCity, MailingStateCode, Id, AccountId, FirstName, LastName, Email, Website_Auto__c, Pays__c, Langue__c, CurrencyIsoCode from Contact where Email = :this.customer.email OR Second_mail__c = :this.customer.email];

					if (contact.size() > 0) {
						Integer indexContact = 0;
						Boolean contactFound = false;
						if (contact.size() > 1) {
							for (Integer i = 0; i<contact.size(); i++) {
								if (contact[i].Email == this.customer.email) {
									indexContact = i;
									contactFound = true;
									break;
								}
								indexContact++;
							}
						}
						if (contactFound == false) {
							indexContact = 0;
						}
						contact[0] = contact[indexContact];

						account = [select Discount_Global__c, ShippingCountryCode, Salutation, Id, Name, IsPersonAccount, PersonContactId, Industry, Sous_secteur__c, Num_ro_de_TVA__c, Type, Website_Auto__c, BillingCountryCode, BillingPostalCode, BillingStreet, BillingStateCode, BillingCity, CurrencyIsoCode, Selection_importance__c, Domaine_utilisateur__c from Account where Id = :contact[0].AccountId limit 1];

						contactFoundAutoRenewal = true;
					}
				}
				if (contactFoundAutoRenewal == false) {
					if (this.customer.company != null && this.customer.company != '' && userDomain != 'Etudiant') {
						account = [select Discount_Global__c, ShippingCountryCode, Salutation, Id, Name, IsPersonAccount, PersonContactId, Industry, Sous_secteur__c, Num_ro_de_TVA__c, Type, Website_Auto__c, BillingCountryCode, BillingPostalCode, BillingStreet, BillingStateCode, BillingCity, CurrencyIsoCode, Selection_importance__c, Domaine_utilisateur__c from Account where Name LIKE :this.customer.company limit 1];

						if (account.size()> 0) {
							if (account[0].BillingCountryCode == this.customer.countryCode) {
								contact = [select Domaine_Utilisateur__c, Salutation, MailingCountryCode, MailingPostalCode, MailingStreet, MailingCity, MailingStateCode, Id, AccountId, FirstName, LastName, Email, Website_Auto__c, Pays__c, Langue__c, CurrencyIsoCode from Contact where(Email = :this.customer.email OR Second_mail__c = :this.customer.email) and AccountId = :account[0].Id];

								accountUpdate = true;

								if (contact.size() > 0) {
									Integer indexContact = 0;
									Boolean contactFound = false;
									if (contact.size() > 1) {
										for (Integer i = 0; i<contact.size(); i++) {
											if (contact[i].Email == this.customer.email) {
												indexContact = i;
												contactFound = true;
												break;
											}
											indexContact++;
										}
									}
									if (contactFound == false) {
										indexContact = 0;
									}
									contact[0] = contact[indexContact];

									contact[0].AccountId = account[0].Id;
									contactUpdate = true;
								} else {
									Contact newContact = new Contact();
									contact.add(newContact);
								}
							} else {
								this.customer.company = this.customer.company + ' ' + this.customer.countryCode;
							}
						}
						if (accountUpdate == false) {
							account.clear();
							contact.clear();

							Account newAccount = new Account();
							account.add(newAccount);

							Contact newContact = new Contact();
							contact.add(newContact);
						}
						contact[0].Phone = contactUpdate == false ? this.customer.phone : contact[0].Phone;
						contact[0].Salutation = contactUpdate == false ? '' : contact[0].Salutation;
						contact[0].FirstName = formatName(this.customer.firstName).abbreviate(MAX_LENGTH_FIRST_NAME);
						contact[0].LastName = formatName(this.customer.lastName).abbreviate(MAX_LENGTH_LAST_NAME);
						contact[0].Email = contactUpdate == false || contact[0].Email == null ? this.customer.email : contact[0].Email;
						contact[0].Website_Auto__c = contactUpdate == false ? true : contact[0].Website_Auto__c;
						contact[0].Pays__c = contactUpdate == false || contact[0].Pays__c == null ? country : contact[0].Pays__c;
						if (contactUpdate == false || contact[0].Langue__c == null) {
							if (isQuote) {
								contact[0].Langue__c = languageToContactLanguage.get(this.customer.language.toLowerCase()) != null ? languageToContactLanguage.get(this.customer.language.toLowerCase()) : this.customer.language;
							} else {
								contact[0].Langue__c = shareItLanguageToSfLanguage.get(this.customer.language) != null ? shareItLanguageToSfLanguage.get(this.customer.language) : DEFAULT_LANGUAGE;
							}
						}
						contact[0].CurrencyIsoCode = contactUpdate == false || contact[0].CurrencyIsoCode == null ? currencyIsoCode : contact[0].CurrencyIsoCode;
						contact[0].MailingCountryCode = this.customer.countryCode != null ? this.customer.countryCode : contact[0].MailingCountryCode;
						contact[0].MailingPostalCode = this.customer.postalCode != null ? this.customer.postalCode : contact[0].MailingPostalCode;
						if (this.customer.street2 != null) {
							contact[0].MailingStreet = this.customer.street1 != null ? this.customer.street1 + '\n\n' + this.customer.street2 : contact[0].MailingStreet;
						} else {
							contact[0].MailingStreet = this.customer.street1 != null ? this.customer.street1 : contact[0].MailingStreet;
						}
						if (countriesCodesWithStatesCodes.contains(this.customer.countryCode)) {
							contact[0].MailingStateCode = this.customer.stateCode != null ? this.customer.stateCode : contact[0].MailingStateCode;
						}
						contact[0].MailingCity = this.customer.city != null ? this.customer.city : contact[0].MailingCity;
						if (contactUpdate == false || contact[0].Domaine_utilisateur__c == null) {
							contact[0].Domaine_utilisateur__c = productDomainToOrderDomain.get(userDomain) != null ? productDomainToOrderDomain.get(userDomain) : userDomain;
						}

						account[0].Num_ro_de_TVA__c = this.customer.vatNumber;
					} else {
						account = [select Discount_Global__c, PersonContactId, IsPersonAccount, Id, FirstName, LastName, Pays__pc, Langue__pc, PersonEmail, Type, Website_Auto__c, BillingCountryCode, BillingPostalCode, BillingStreet, BillingStateCode, BillingCity, CurrencyIsoCode, Selection_importance__c, Domaine_utilisateur__c from Account where PersonEmail = :this.customer.email OR Second_mail__pc = :this.customer.email];

						if (account.size()> 0) {
							accountUpdate = true;

							Integer indexAccount = 0;
							Boolean accountFound = false;
							if (account.size() > 1) {
								for (Integer i = 0; i<account.size(); i++) {
									if (account[i].PersonEmail == this.customer.email) {
										indexAccount = i;
										accountFound = true;
										break;
									}
									indexAccount++;
								}
							}
							if (accountFound == false) {
								indexAccount = 0;
							}
							account[0] = account[indexAccount];
						} else {
							account.clear();

							Account newAccount = new Account();
							account.add(newAccount);
						}
					}
					if (this.customer.company != null && this.customer.company != '' && account[0].IsPersonAccount != true && userDomain != 'Etudiant') {
						account[0].Name = accountUpdate == false || account[0].Name == null ? this.customer.company : account[0].Name;
					} else {
						account[0].Phone = this.customer.phone;
						account[0].FirstName = formatName(this.customer.firstName).abbreviate(MAX_LENGTH_FIRST_NAME);
						account[0].LastName = formatName(this.customer.lastName).abbreviate(MAX_LENGTH_LAST_NAME);
						account[0].PersonEmail = accountUpdate == false || account[0].PersonEmail == null ? this.customer.email : account[0].PersonEmail;
						account[0].Pays__pc = accountUpdate == false || account[0].Pays__pc == null ? country : account[0].Pays__pc;
						if (accountUpdate == false || account[0].Langue__pc == null) {
							if (isQuote) {
								account[0].Langue__pc = languageToContactLanguage.get(this.customer.language.toLowerCase()) != null ? languageToContactLanguage.get(this.customer.language.toLowerCase()) : this.customer.language;
							} else {
								account[0].Langue__pc = shareItLanguageToSfLanguage.get(this.customer.language) != null ? shareItLanguageToSfLanguage.get(this.customer.language) : DEFAULT_LANGUAGE;
							}
						}
						account[0].Salutation = accountUpdate == false ? '' : account[0].Salutation;
						if (userDomain == 'Etudiant') {
							account[0].PersonDepartment = customer.company;
						} else {
							this.IsPersonAndHasCompanyDomain = true;

							String emailDomain = customer.email.substringAfter('@');
							String emailDomain2 = emailDomain.substringBefore('.');
							Domaine_general__c[] companyDomains = [SELECT Id FROM Domaine_general__c WHERE Name = :emailDomain2];
							if (companyDomains.size() == 0) {
								companyDomains = [SELECT Id FROM Domaine_general__c WHERE Name = :emailDomain];
								if (companyDomains.size()> 0) {
									this.IsPersonAndHasCompanyDomain = false;
								}
							} else {
								this.IsPersonAndHasCompanyDomain = false;
							}
						}
					}
					if (accountUpdate == false) {
						account[0].Type = isQuote ? 'Prospect' : 'Client';
						account[0].Website_Auto__c = true;
					} else if (isQuote == false && account[0].Type == 'Prospect') {
						account[0].Type = 'Client';
					}
					account[0].BillingCountryCode = this.customer.countryCode != null ? this.customer.countryCode : account[0].BillingCountryCode;
					account[0].BillingPostalCode = this.customer.postalCode != null ? this.customer.PostalCode : account[0].BillingPostalCode;
					if (this.customer.street2 != null) {
						account[0].BillingStreet = this.customer.street1 != null ? this.customer.street1 + '\n' + this.customer.street2 : account[0].BillingStreet;
					} else {
						account[0].BillingStreet = this.customer.street1 != null ? this.customer.street1 : account[0].BillingStreet;
					}
					if (countriesCodesWithStatesCodes.contains(this.customer.countryCode)) {
						account[0].BillingStateCode = this.customer.stateCode != null ? this.customer.stateCode : account[0].BillingStateCode;
					}
					account[0].BillingCity = this.customer.city != null ? this.customer.city : account[0].BillingCity;
					account[0].CurrencyIsoCode = accountUpdate == false || account[0].CurrencyIsoCode == null ? currencyIsoCode : account[0].CurrencyIsoCode;
					account[0].Selection_importance__c = accountUpdate == false || account[0].Selection_importance__c == null ? '2 - Normal' : account[0].Selection_importance__c;
					if (accountUpdate == false || account[0].Domaine_utilisateur__c == null) {
						account[0].Domaine_utilisateur__c = productDomainToOrderDomain.get(userDomain) != null ? productDomainToOrderDomain.get(userDomain) : userDomain;
					}
					account[0].Num_ro_de_TVA__c = accountUpdate == false || account[0].Num_ro_de_TVA__c == null ? this.customer.vatNumber : account[0].Num_ro_de_TVA__c;
					account[0].ShippingCountryCode = accountUpdate == false || account[0].ShippingCountryCode == null || account[0].ShippingCountryCode == 'US' ? this.customer.countryCode : account[0].ShippingCountryCode;

					System.debug('WebServiceOrder#insertInSalesforce Account=' + account);
					if (accountUpdate) {
						update account;
					} else {
						insert account;
					}
					if (contact.size() > 0) {
						contact[0].AccountId = account[0].Id;
					}
					System.debug('WebServiceOrder#insertInSalesforce Contact=' + contact);
					if (contactUpdate) {
						update contact;
					} else {
						insert contact;
					}
				}
			}
		}
	}

	webservice static Plan SendOrder(Plan plan) {
		Boolean isQuote = plan.isQuote || plan.paymentMethod == BILLING_WIRE || plan.paymentMethod == BILLING_CHECK;

		if (isQuote == false) {
			plan.status = false;

			Customer customer = plan.customerBilling;
			Boolean clientFinalToAdd = false;
			if (plan.customerDelivering != null) {
				clientFinalToAdd = plan.customerDelivering.email != customer.email && plan.customerDelivering.id != null;
			}

			if (plan.generateLicense) {
				Integer quantitySolutions = 0;
				Map<String, Integer> optionsQuantitiesByOptionsNames = new Map<String, Integer> ();
				Map<String, Integer> optionsQuantitiesByOptionsFullNames = new Map<String, Integer> ();
				Boolean generateKey = true;
				Map<String, String> productTypeLicenseByProductCode = new Map<String, String> ();
				for (PlanProduct planProduct : plan.planProducts) {
					String productCode = planProduct.productCode;
					String[] productCodeSplitted = productCode.split('_');

					if (planProduct.productFamily == PRODUCT_FAMILY_SOLUTION) {
						quantitySolutions += planProduct.quantity;
					} else if (planProduct.productFamily == PRODUCT_FAMILY_OPTION) {
						if (productCodeSplitted.size() > 1) {
							optionsQuantitiesByOptionsNames.put(productCodeSplitted[1], planProduct.quantity);
							optionsQuantitiesByOptionsFullNames.put(planProduct.productName, planProduct.quantity);
						}
					}

					String licenseType = 'ANNUAL';
					if (productCodeSplitted[productCodeSplitted.size() - 1] == 'PP') {
						licenseType = 'PERPETUAL';
					}
					productTypeLicenseByProductCode.put(productCode, licenseType);
				}

				// Gestion d'erreur : Verifie que le nombre d'options achetées correspond aux nombre de solutions
				for (String optionName : optionsQuantitiesByOptionsNames.keySet()) {
					if (optionsQuantitiesByOptionsNames.get(optionName) != quantitySolutions) {
						generateKey = false;
						break;
					}
				}

				List<FlexeraController.ResultGenerateKey> resultsFlexeraGeneratedKey = new List<FlexeraController.ResultGenerateKey> ();
				Order order = [select Ref_ShareIt__c, Id, Account.Type, Domaine_Utilisateur__c, Status, Type_licence__c, Contact_Lie__r.Email, Client_final__r.Email, AccountId, Contact_Lie__c, Client_final__c, MyAccount_Auto__c, CurrencyIsoCode from Order where Id = :plan.id];
				Boolean orderIsAlreadyAutoRenewal = false;
				if (order.Ref_ShareIt__c != null) {
					orderIsAlreadyAutoRenewal = order.Ref_ShareIt__c.contains(',');
				}

				// Il y a-t-il des clés à générer
				if (generateKey == true) {

					// isUpdate signifie que le plan share-it contient le renouvellement automatique d'une annuelle
					if (plan.isUpdate == false) {

						// Calcul de generateKeyAlreadyAutoRenewal : ce boolean quand il vaut FALSE signifie que Share-it envoie un plan contenant
						// une option correspondant à une commande de renouvellement sans les solutions associées et qu'il faut modifier la clé déjà générée
						// pour les solutions
						Boolean generateKeyAlreadyAutoRenewal = !orderIsAlreadyAutoRenewal;
						if (generateKeyAlreadyAutoRenewal == false) { // Commande annuelle en renewal avec les solutions dedans : on régénere une clé annuelle pour le client et le distributeur (evt)
							System.debug('WebseriveOrder#sendPlan plan.planProducts' + plan.planProducts);
							for (PlanProduct planProduct : plan.planProducts) {
								if (planProduct.productFamily == PRODUCT_FAMILY_SOLUTION) {
									generateKeyAlreadyAutoRenewal = false;
									break;
								} else {
									generateKeyAlreadyAutoRenewal = true;
								}
							}
						}
						if (generateKeyAlreadyAutoRenewal == true) { // Commande annuelle en renewal avec les solutions dedans : on régénere une clé annuelle pour le client et le distributeur (evt)
							for (PlanProduct planProduct : plan.planProducts) {
								if (planProduct.productFamily == PRODUCT_FAMILY_SOLUTION) {
									Flexera_Key__c flexeraKey = new Flexera_Key__c();
									flexeraKey.Quantity__c = planProduct.quantity;
									flexeraKey.Domaine_Utilisateur__c = order.Domaine_Utilisateur__c;
									flexeraKey.Type_Licence__c = order.Type_Licence__c == SEND_KEY_LICENSE_TYPE_3 ? SEND_KEY_LICENSE_TYPE_2 : order.Type_Licence__c;
									if (flexeraKey.Domaine_Utilisateur__c == 'Campus') {
										if (flexeraKey.Type_Licence__c == 'Large Campus') {
											flexeraKey.Nb_Activations_Allowed__c = flexeraKey.Quantity__c * 1000;
										} else {
											flexeraKey.Nb_Activations_Allowed__c = flexeraKey.Quantity__c * 500;
										}
									} else {
										flexeraKey.Nb_Activations_Allowed__c = flexeraKey.Quantity__c< 20 ? flexeraKey.Quantity__c + 1 : Integer.valueof(flexeraKey.Quantity__c + flexeraKey.Quantity__c * 0.1);
									}
									flexeraKey.Date_Limite__c = Date.today().addYears(1);
									flexeraKey.Expiration__c = flexeraKey.Type_Licence__c == SEND_KEY_LICENSE_TYPE_2 ? FlexeraController.EXPIRATION_PERMANENT : FlexeraController.EXPIRATION_EXPIRING;
									flexeraKey.Type_client__c = order.Account.Type;
									flexeraKey.Order__c = order.Id;
									flexeraKey.Contact__c = customer.id;
									flexeraKey.XLSTAT_Solution__c = planProduct.productName;
									flexeraKey.XLSTAT_Options__c = '';
									for (String optionName : optionsQuantitiesByOptionsFullNames.keySet()) {
										flexeraKey.XLSTAT_Options__c += optionName + ';';
									}
									flexeraKey.Is_Network__c = flexeraKey.Type_Licence__c == 'Réseau';
									
									if (!Test.isRunningTest()) { // en tests erreur callout + dml 
										resultsFlexeraGeneratedKey.add(FlexeraController.Generate(1, flexeraKey, customer.firstName, customer.lastName, customer.email, customer.countryCode, null));
									}
								}
							}

							List<Flexera_Key__c> flexeraKeysToInsert = new List<Flexera_Key__c> ();
							for (FlexeraController.ResultGenerateKey resultFlexeraGeneratedKey : resultsFlexeraGeneratedKey) {
								if (resultFlexeraGeneratedKey.Status == true) {
									Flexera_Key__c[] resultKeys = resultFlexeraGeneratedKey.GeneratedKeys;
									for (Flexera_Key__c generatedKey : resultKeys) {
										flexeraKeysToInsert.add(generatedKey);
									}
								}
							}
							insert flexeraKeysToInsert;

							if (clientFinalToAdd) {
								List<Flexera_Key__c> flexeraKeysDelivering = new List<Flexera_Key__c> ();
								for (Flexera_Key__c key : flexeraKeysToInsert) {
									Flexera_Key__c keyCloned = key.Clone(false, true);
									keyCloned.Contact__c = plan.customerDelivering.Id;

									flexeraKeysDelivering.add(keyCloned);
								}
								insert flexeraKeysDelivering;
							}
						} else { // Gestion des cas de renewal commandes annuelles découpées entre les solutions et les options. Ce code ajoute les options reçues à la clé existante qui contient dèja la solution
							Flexera_Key__c[] keysAutoRenewal = [SELECT Account__r.Name, Nb_activations_allowed__c, Is_Network__c, Has_Student_Ext__c, Name, Campaign__c, Order__c, Contact__c, Date_limite__c, Domaine_utilisateur__c, Expiration__c, Modules__c, Nb_activations__c, Quantity__c, Type_client__c, Type_licence__c, XLSTAT_Options__c, XLSTAT_Solution__c, Version__c, Entitlement_Id__c FROM Flexera_Key__c WHERE Order__c = :plan.id];
							if (keysAutoRenewal.size() == 1) {
								Flexera_Key__c oldKey = keysAutoRenewal[0].clone(false, true);

								keysAutoRenewal[0].XLSTAT_Options__c = '';
								for (PlanProduct planProduct : plan.planProducts) {
									keysAutoRenewal[0].XLSTAT_Options__c += planProduct.productName + ';';
								}

								if (!Test.isRunningTest()) {
									FlexeraController.UpdateKey(oldKey, keysAutoRenewal[0]);
									update keysAutoRenewal;
								}
							}
						}
					} else { //  Creation des clés SF pour le support des perpets
						Date dateLimit = Date.today().addYears(1);

						for (String licenseKey : plan.keysToUpdate) {
							String expiration = order.Type_licence__c == SEND_KEY_LICENSE_TYPE_2 || order.Type_licence__c == SEND_KEY_LICENSE_TYPE_3 ? FlexeraController.EXPIRATION_PERMANENT : FlexeraController.EXPIRATION_EXPIRING;
							Boolean result = false;
							if (!Test.isRunningTest()) {
								result = FlexeraController.UpdateKeyLimit(null, licenseKey, expiration);
							}
							FlexeraController.ResultGenerateKey resultGenerateKey = new FlexeraController.ResultGenerateKey();
							resultGenerateKey.Status = result;
							resultsFlexeraGeneratedKey.add(resultGenerateKey);
						}

						Flexera_Key__c[] existingFlexeraKeys = [SELECT Share_It__c, Date_Limite__c, Order__c FROM Flexera_Key__c WHERE Name in :plan.keysToUpdate ORDER BY Date_Limite__c DESC];
						Map<String, Flexera_Key__c> existingFlexeraKeysSingles = new Map<String, Flexera_Key__c> ();
						for (Flexera_Key__c existingFlexeraKey : existingFlexeraKeys) {
							existingFlexeraKey.Date_Limite__c = dateLimit;
							if (existingFlexeraKeysSingles.containsKey(existingFlexeraKey.Name) == false) {
								existingFlexeraKeysSingles.put(existingFlexeraKey.Name, existingFlexeraKey);
							}
						}
						update existingFlexeraKeys;

						List<Flexera_Key__c> flexeraKeysToInsert = new List<Flexera_Key__c> ();
						for (Flexera_Key__c existingFlexeraKey : existingFlexeraKeysSingles.values()) {
							Flexera_Key__c newKey = existingFlexeraKey.clone();
							newKey.Date_Limite__c = dateLimit;
							newKey.Order__c = order.Id;
							newKey.Share_It__c = true;
							flexeraKeysToInsert.add(newKey);
						}
						insert flexeraKeysToInsert;

						for (Integer i = 0; i<resultsFlexeraGeneratedKey.size(); i++) {
							if (flexeraKeysToInsert.size()> i) {
								resultsFlexeraGeneratedKey[i].GeneratedKeys = new List<Flexera_Key__c> { flexeraKeysToInsert[i] };
							}
						}
					}
				}

				Boolean status = true;
				Contact[] contactLie = [select AccountId from Contact where Email = :order.Contact_lie__r.Email];
				Contact[] clientFinal = [select AccountId from Contact where Email = :order.Client_final__r.Email];
				List<String> contactsAccountIds = new List<String> ();
				for (Contact contact : contactLie) {
					contactsAccountIds.add(contact.AccountId);
				}
				for (Contact contact : clientFinal) {
					contactsAccountIds.add(contact.AccountId);
				}
				Account[] accounts = [select Discount_Global__c, Type from Account where Id in :contactsAccountIds and(Type = 'Distributeur' or Type = 'Revendeur')];
				Account account = [select Type, Discount_Global__c from Account where Id = :order.AccountId limit 1];
				String emailDomain = customer.email.substringAfter('@');

				List<Domaine_EDU_autorise__c> domaines = new List<Domaine_EDU_autorise__c> ();
				List<Order> oldValidatedOrders = new List<Order> ();
				if (order.Domaine_Utilisateur__c == SEND_KEY_USER_DOMAIN_ACADEMIC && emailDomain.contains('alumni') == false) {
					String[] emailDomainParts = emailDomain.split('\\.');
					String emailDomainQuery = emailDomain;
					domaines = [select Name from Domaine_EDU_autorise__c where Name = :emailDomainQuery];
					Boolean emailFound = false;
					if (domaines.size() == 0 && emailDomainParts.size()> 0) {
						Integer i = emailDomainParts.size() - 1;
						while (emailFound == false) {
							String domaineToCheck = '';
							for (Integer j = i; j<emailDomainParts.size(); j++) {
								domaineToCheck = domaineToCheck + emailDomainParts[j];
								if (j<emailDomainParts.size() - 1) {
									domaineToCheck = domaineToCheck + '.';
								}
							}
							domaines = [select Name from Domaine_EDU_autorise__c where Name = :domaineToCheck];
							if (domaines.size()> 0 || i == 0) {
								emailFound = true;
							}
							i--;
						}
					}

					if (domaines.size() == 0) {
						oldValidatedOrders = [SELECT Id FROM Order WHERE(Status = 'Payée' OR Status = 'Validée') AND Id = :order.AccountId];
					}
				}

				// Envoie d'email pour permettre l'annuluation d'un renouvellement de licence annuelle
				// l'email n'est envoyé que si le renouvellement concerne les solutions (ie pas s'il s'agit d'un appel de
				// renouvellement des options associées aux solutions)
				if (plan.isAutoRenewal == true && orderIsAlreadyAutoRenewal == false) {
					String contactId = clientFinalToAdd ? plan.customerDelivering.id : customer.id;
					EmailSendAutoRenewal.Send(contactId, order.Id);
				}

				Domaines_non_autorises__c[] domainsNotAllowed = [SELECT Id FROM Domaines_non_autorises__c WHERE Name = :emailDomain];

				// Envoi d'un email pour demander la preuve de carte étudiant à un student ou Academique
				Boolean sendKeyAcademic = (order.Domaine_Utilisateur__c == SEND_KEY_USER_DOMAIN_ACADEMIC && (domaines.size()> 0 || oldValidatedOrders.size() > 0)) || (order.MyAccount_Auto__c == true && order.Domaine_Utilisateur__c == SEND_KEY_USER_DOMAIN_ACADEMIC);
				if (sendKeyAcademic == false && plan.isAutoRenewal == false) {
					ApexPages.StandardController sc = new ApexPages.StandardController(order);
					SendEmailStuExtension ext = new SendEmailStuExtension(sc);
					ext.SendEmail();
					status = ext.Status;
				}
				Boolean sendKeyCompany = order.Domaine_Utilisateur__c == SEND_KEY_USER_DOMAIN_COMPANY;
				clientFinalToAdd = clientFinalToAdd || affiliateToAccountId.containsKey(plan.planProducts[0].affiliate);
				// Envoi de l'email avec la clé pour le cas d'achat d'une licence company ou Acad connu
				if ((order.Type_licence__c == SEND_KEY_LICENSE_TYPE_1 || order.Type_licence__c == SEND_KEY_LICENSE_TYPE_2 || order.Type_licence__c == SEND_KEY_LICENSE_TYPE_3) && ((accounts.size() > 0 && clientFinalToAdd == true) || accounts.size() == 0) && domainsNotAllowed.size() == 0 && plan.isAutoRenewal == false) {
					if (sendKeyCompany || sendKeyAcademic) {
						for (FlexeraController.ResultGenerateKey resultFlexeraGeneratedKey : resultsFlexeraGeneratedKey) {
							if (resultFlexeraGeneratedKey.Status) {
								Boolean emailSentResult = false;
								for (Flexera_Key__c flexeraKey : resultFlexeraGeneratedKey.GeneratedKeys) {
									FlexeraSendKeyByEmailFromWSController flexeraSendKeyByEmailFromWSController = new FlexeraSendKeyByEmailFromWSController(plan.isUpdate);
									flexeraSendKeyByEmailFromWSController.FlexeraKeyId = flexeraKey.Id;
									if (clientFinalToAdd) {
										flexeraSendKeyByEmailFromWSController.OtherContactEmail = plan.customerDelivering.email;
									}
									if (affiliateToAccountId.containsKey(plan.planProducts[0].affiliate)) {
										flexeraSendKeyByEmailFromWSController.ResellerAccountId = affiliateToAccountId.get(plan.planProducts[0].affiliate);
									}
									emailSentResult = flexeraSendKeyByEmailFromWSController.Send();

									if (emailSentResult == false) {
										break;
									}
								}

								if (emailSentResult) {
									order.Status = 'Payée';
									update order;

									Paiement__c paiement = new Paiement__c();
									paiement.Commande_lie__c = order.Id;
									paiement.CurrencyIsoCode = order.CurrencyIsoCode;
									paiement.Date_de_paiement_effectif__c = Date.today();
									paiement.Modalites_de_paiement__c = '+0j';
									String paymentMethod = 'ShareIt';
									if (plan.paymentMethod == 'Check') {
										paymentMethod = 'Chèque';
									} else if (plan.paymentMethod == 'WireTransfer') {
										paymentMethod = 'Virement';
									}
									paiement.Type_de_paiement__c = paymentMethod;

									insert paiement;
								} else {
									plan.message = 'Problem sending key.';
									status = false;
								}
							} else {
								status = false;
								plan.message = 'Problem generating keys';
							}
						}
					}
				}

				plan.status = status;
			}

			return plan;
		} else {
			Quote[] quote = [select Id, GenerateFactureEN__c, QuoteNumber, CurrencyISOCode, Opportunity.Client_Final__c, Opportunity.Contact_Lie__c from Quote where Id = :plan.id];

			if (quote.size() > 0) {
				Customer customer = plan.customerBilling;

				PageReference pg;
				if (quote[0].currencyIsoCode == 'JPY') pg = new PageReference('/apex/quote_jp?id=' + quote[0].Id);
				else if (!quote[0].GenerateFactureEN__c) pg = new PageReference('/apex/quote_fr?id=' + quote[0].Id);
				else pg = new PageReference('/apex/quote_en?id=' + quote[0].Id);

				Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();

				QuoteDocument quotedoc;
				if (!test.isRunningTest()) {
					quotedoc = new QuoteDocument();
					Blob b = pg.getContent();
					quotedoc.Document = b;
					quotedoc.QuoteId = plan.id;
					insert quotedoc;
					if (customer.language.toLowerCase() != 'fr') {
						efa.setFileName('XLSTAT_quote_' + quote[0].QuoteNumber + '.pdf');
					} else {
						efa.setFileName('XLSTAT_devis_' + quote[0].QuoteNumber + '.pdf');
					}
					efa.setBody(b);
				}

				Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
				if (plan.isQuote) {
					if (customer.language.toLowerCase() == 'fr') {
						email.setSubject('XLSTAT devis ' + quote[0].QuoteNumber);
					} else {
						email.setSubject('XLSTAT quote ' + quote[0].QuoteNumber);
					}
				} else {
					if (plan.paymentMethod == BILLING_WIRE) {
						if (customer.language.toLowerCase() == 'fr') {
							email.setSubject('XLSTAT virement ' + quote[0].QuoteNumber);
						} else {
							email.setSubject('XLSTAT wire ' + quote[0].QuoteNumber);
						}
					} else if (plan.paymentMethod == BILLING_CHECK) {
						if (customer.language.toLowerCase() == 'fr') {
							email.setSubject('XLSTAT chèque ' + quote[0].QuoteNumber);
						} else {
							email.setSubject('XLSTAT check ' + quote[0].QuoteNumber);
						}
					}
				}
				List<String> emailAddresses = new List<String> ();
				emailAddresses.add(customer.email);
				if (quote[0].CurrencyISOCode == 'JPY') {
					emailAddresses.add('sales@mindware-jp.com');
				}
				email.setToAddresses(emailAddresses);
				email.setBccAddresses(new List<String> {Label.emailSales});

				if (customer.language.toLowerCase() == 'fr') {
					email.setSenderDisplayName('Equipe commerciale XLSTAT');
				} else {
					email.setSenderDisplayName('XLSTAT Sales Team');
				}

				String emailTemplateName;
				if (plan.isQuote) {
					emailTemplateName = 'Quote ';
				} else {
					if (plan.paymentMethod == BILLING_WIRE) {
						emailTemplateName = 'Wire ';
					} else if (plan.paymentMethod == BILLING_CHECK) {
						emailTemplateName = 'Check ';
					}
				}
				if ((customer.language.toLowerCase() == 'japanese' || customer.language.toLowerCase() == 'ja') && plan.paymentMethod == BILLING_WIRE) {
					emailTemplateName += 'JA';
				} else {
					if (customer.language.toLowerCase() == 'fr') {
						emailTemplateName += 'FR';
					} else {
						emailTemplateName += 'EN';
					}
				}

				EmailTemplate emailTemplate = [SELECT Id, Subject, Body FROM EmailTemplate WHERE Name = :emailTemplateName];
				email.setPlainTextBody(emailTemplate.Body);

				if (!test.isRunningTest()) {
					email.setFileAttachments(new Messaging.EmailFileAttachment[] { efa });
				}
				Messaging.SendEmailResult[] sendEmailResult = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });

				if (sendEmailResult[0].success) {
					plan.status = true;
					plan.message = 'Quote created and sent by email.';

					List<Email__c> emailsToInsert = new List<Email__c> ();
					for (String emailAddress : emailAddresses) {
						Email__c e = new Email__c();
						e.Address__c = emailAddress;
						e.Contact__c = quote[0].Opportunity.Client_final__c == null ? quote[0].Opportunity.Contact_Lie__c : quote[0].Opportunity.Client_Final__c;
						e.Quote__c = quote[0].Id;
						e.Type__c = plan.IsQuote ? 'Devis' : (plan.paymentMethod == BILLING_WIRE ? 'Virement' : 'Chèque');
						e.Subject__c = email.getSubject();
						e.Attachment_Id__c = quotedoc != null ? quotedoc.Id : null;
						emailsToInsert.add(e);
					}

					insert emailsToInsert;
				} else {
					plan.status = false;
					plan.message = 'Problem on quote email.';
				}
			} else {
				plan.status = false;
				plan.message = 'No quote found';
			}

			return plan;
		}
	}

	private static String formatName(String name) {
		String newName = name.toLowerCase();
		if (newName.indexof(' ') != - 1) {
			String[] newNames = newName.split(' ');
			for (Integer i = 0; i<newNames.size(); i++) {
				newNames[i] = newNames[i].capitalize();
			}
			newName = String.join(newNames, ' ');
		} else {
			newName = newName.capitalize();
		}
		if (newName.indexof('-') != - 1) {
			String[] newNames = newName.split('-');
			for (Integer i = 0; i<newNames.size(); i++) {
				newNames[i] = newNames[i].capitalize();
			}
			newName = String.join(newNames, '-');
		}

		return newName;
	}

	webservice static Plan AddOrder(Plan plan) {
		Boolean isQuote = plan.isQuote || plan.paymentMethod == BILLING_WIRE || plan.paymentMethod == BILLING_CHECK;

		if (plan.isAutoRenewal == null) {
			plan.isAutoRenewal = false;
		}

		Customer customer = plan.customerBilling;
		PlanProduct[] planProducts = plan.planProducts;
		System.debug('WebServiceOrder#addOrder: planProducts : ' + planProducts);

		if (planProducts.size()> 0) {
			if (plan.customerDelivering != null) {
				if (plan.customerDelivering.company == null || plan.customerDelivering.company == '') {
					if (customer.email.substringAfter('@') == plan.customerDelivering.email.substringAfter('@')) {
						plan.customerDelivering.company = customer.company;
					}
				}
			}

			String currencyIsoCode = planProducts[0].currencyISOCode;
			System.debug('WebServiceOrder#addOrder: currency : ' + currencyISOCode);

			Pricebook2[] pricebook2 = [select Id from Pricebook2 where CurrencyIsoCode__c = :currencyIsoCode];
			System.debug('WebServiceOrder#addOrder: pricebook2 : ' + pricebook2);

			if (pricebook2.size()> 0) {
				String affiliate = planProducts[0].affiliate;

				Map<String, PlanProduct> productsCodes = new Map<String, PlanProduct> ();
				for (PlanProduct planProduct : planProducts) {
					productsCodes.put(planProduct.productCode, planProduct);
				}
				System.debug('WebServiceOrder#addOrder: productsCodes : ' + productsCodes);

				Product2[] products = [SELECT Domaine_utilisateur__c, Type_licence__c, Name, ProductCode, Family from Product2 where ProductCode in :productsCodes.keySet()];
				System.debug('WebServiceOrder#addOrder: products : ' + products);

				Map<String, Product2> productByProductCode = new Map<String, Product2> ();
				for (Product2 product : products) {
					productByProductCode.put(product.ProductCode, product);
				}
				System.debug('WebServiceOrder#addOrder: productByProductCode : ' + productByProductCode);

				for (Integer i = 0; i<plan.planProducts.size(); i++) {
					plan.planProducts[i].productFamily = productByProductCode.get(plan.planProducts[i].productCode).Family;
				}
				System.debug('WebServiceOrder#addOrder: plan.planProducts : ' + plan.planProducts);

				String userDomain = products[0].Domaine_utilisateur__c;
				String licenseType = products[0].Type_licence__c;
				for (Integer i = 1; i<products.size(); i++) {
					String licenseTypeProduct = products[i].Type_licence__c;
					String userDomainProduct = products[i].Domaine_utilisateur__c;
					if (licenseTypePriorities.get(licenseTypeProduct)> licenseTypePriorities.get(licenseType)) {
						licenseType = licenseTypeProduct;
					}
					if (userDomainPriorities.get(userDomainProduct)> userDomainPriorities.get(userDomain)) {
						userDomain = userDomainProduct;
					}
				}
				licenseType = productLicenseTypeToOrderLicenseType.get(licenseType) == null ? licenseType : productLicenseTypeToOrderLicenseType.get(licenseType);

				List<Account> distributeur = new List<Account> ();
				if (affiliate != null && affiliate != '') {
					distributeur = [select Id, Discount_Global__c from Account where Id = :affiliateToAccountId.get(affiliate)];

					if (distributeur.size() == 0) {
						plan.status = false;
						plan.message = 'No account matching affiliation';

						return plan;
					}
				}

				List<Coupon__c> coupon = new List<Coupon__c> ();
				for (PlanProduct planProduct : plan.planProducts) {
					if (planProduct.couponReference != null) {
						coupon = [select Id from Coupon__c where Name = :planProduct.couponReference];
						break;
					}
				}

				CustomerWrapper customerWrapper = new CustomerWrapper(customer);
				customerWrapper.InsertInSalesforce(isQuote, plan.isAutoRenewal, currencyIsoCode, userDomain);
				plan.customerBilling.postalCode = customerWrapper.PostalCode;
				customer.postalCode = customerWrapper.PostalCode;
				if (customerWrapper.status == true) {
					Customer customerDelivering = plan.customerDelivering;
					Boolean clientFinal = false;
					if (customerDelivering != null) {
						clientFinal = customerDelivering.email != customer.email;
					}

					if (customerWrapper.accountUpdate == false && customerWrapper.contact.size() == 0) {
						customerWrapper.account = [select Id, Discount_Global__c, PersonContactId, IsPersonAccount from Account where Id = :customerWrapper.account[0].Id limit 1];
					}
					CustomerWrapper customerDeliveringWrapper;
					if (clientFinal) {
						customerDeliveringWrapper = new CustomerWrapper(customerDelivering);
						customerDeliveringWrapper.InsertInSalesforce(isQuote, plan.isAutoRenewal, currencyIsoCode, userDomain);
						plan.customerDelivering.postalCode = customerDeliveringWrapper.PostalCode;
						customerDelivering.postalCode = customerDeliveringWrapper.PostalCode;
						if (customerDeliveringWrapper.accountUpdate == false && customerDeliveringWrapper.contact.size() == 0) {
							customerDeliveringWrapper.account = [select Id, Discount_Global__c, PersonContactId, IsPersonAccount from Account where Id = :customerDeliveringWrapper.account[0].Id limit 1];
						}
					}

					Order order = null;
					Opportunity opportunity = null;
					Quote quote = null;
					Boolean updateKey = false;
					if (isQuote) {
						opportunity = new Opportunity();

						if (customerWrapper.contact.size() > 0) {
							opportunity.AccountId = customerWrapper.contact[0].AccountId;

							if (customerWrapper.account[0].IsPersonAccount == false) {
								opportunity.Contact_Lie__c = customerWrapper.contact[0].Id;
							}
						} else {
							opportunity.AccountId = customerWrapper.account[0].Id;

							if (customerWrapper.account[0].IsPersonAccount == true) {
								opportunity.Contact_Lie__c = customerWrapper.account[0].PersonContactId;
							}
						}
						if (clientFinal) {
							if (customerDeliveringWrapper.contact.size() > 0) {
								if (customerDeliveringWrapper.account[0].IsPersonAccount == false) {
									opportunity.Client_Final__c = customerDeliveringWrapper.contact[0].Id;
								}
							} else {
								if (customerDeliveringWrapper.account[0].IsPersonAccount == true) {
									opportunity.Client_Final__c = customerDeliveringWrapper.account[0].PersonContactId;
								}
							}
						}
						Date dateToday = Date.today();
						DateTime dateTimeNow = DateTime.now();
						opportunity.Pricebook2Id = pricebook2[0].Id;
						opportunity.CurrencyISOCode = currencyIsoCode;
						opportunity.Name = 'Proposition en ligne ' + dateTimeNow;
						opportunity.StageName = 'Proposition/Devis';
						opportunity.CloseDate = dateToday.addDays(7);
						opportunity.Website_Auto__c = true;
						opportunity.Type = 'Nouvelle activité';

						insert opportunity;

						quote = new Quote();
						quote.OpportunityId = opportunity.Id;
						quote.Name = 'Devis en ligne ' + dateTimeNow;
						quote.Domaine_utilisateur__c = productDomainToOrderDomain.get(userDomain) != null ? productDomainToOrderDomain.get(userDomain) : userDomain;
						quote.Pricebook2Id = pricebook2[0].Id;
						quote.BillingCountryCode = customer.countryCode;
						quote.BillingPostalCode = customer.PostalCode;
						if (customer.street2 != null) {
							quote.BillingStreet = customer.street1 + '\n' + customer.street2;
						} else {
							quote.BillingStreet = customer.street1;
						}
						if (countriesCodesWithStatesCodes.contains(customer.countryCode)) {
							quote.BillingStateCode = customer.stateCode;
						}
						quote.BillingCity = customer.city;
						quote.ShippingCountryCode = customer.countryCode;
						quote.ShippingPostalCode = customer.postalCode;
						quote.ShippingStreet = customer.street1 + '\n\n' + customer.street2;
						if (countriesCodesWithStatesCodes.contains(customer.countryCode)) {
							quote.ShippingStateCode = customer.stateCode;
						}
						quote.ShippingCity = customer.city;
						quote.GenerateFactureEn__c = customer.language.toLowerCase() != 'fr';
						quote.Website_Auto__c = true;
						if (plan.isQuote) {
							quote.Type__c = QUOTE_TYPE;
						} else {
							quote.Type__c = quoteTypeByBillingType.get(plan.paymentMethod);
						}
						if (customer.company != null && customer.company != '') {
							quote.Affichage_Nom_Du_Compte__c = 'Nom du compte et nom du contact';
						} else {
							quote.Affichage_Nom_Du_Compte__c = 'Nom du compte seul';
						}
						if (coupon.size() > 0) {
							quote.Ref_du_coupon__c = coupon[0].Id;
						}

						insert quote;

						quote.Status = 'Présenté';
						update quote;
					} else {
						if (plan.isUpdate == true) {
							updateKey = true;
						} else {
							System.debug('>>>>>>>>>> licenseType='+licenseType+'  accountUpdate='+customerWrapper.accountUpdate);
							if (customerWrapper.accountUpdate && licenseType == GENERATE_LICENSE_NO_TYPE_LICENSE_1) {
								Boolean existingAccount = false;
								if (customer.company != null && customer.company != '') {
									if (customerWrapper.contactUpdate == true) {
										existingAccount = true;
									}
								} else {
									existingAccount = true;
								}

								if (existingAccount == true) {
									List<Id> existingOrdersIds = new List<Id> ();
									Map<Id, Date> ordersIdsByDates = new Map<Id, Date> ();
									for (Order existingOrder :[SELECT Id, EffectiveDate FROM Order WHERE AccountId = :customerWrapper.account[0].Id AND Status = 'Payée' ORDER By EffectiveDate DESC]) {
										existingOrdersIds.add(existingOrder.Id);
										ordersIdsByDates.put(existingOrder.Id, existingOrder.EffectiveDate);
									}

									Map<Id, Set<String>> existingOrderItemsByOrderId = new Map<Id, Set<String>> ();
									Map<Id, Set<String>> existingOrderItemsByOrderIdUpdateOrder = new Map<Id, Set<String>> ();
									for (OrderItem existingOrderItem :[SELECT OrderId, PricebookEntry.ProductCode FROM OrderItem WHERE OrderId in :existingOrdersIds]) {
										String[] productCodeSplitted = existingOrderItem.PricebookEntry.ProductCode.split('_');
										String productCodePart = productCodeSplitted[1];
										if (productCodeSPlitted[3] == 'AN') {
											if (existingOrderItemsByOrderId.containsKey(existingOrderItem.OrderId)) {
												existingOrderItemsByOrderId.get(existingOrderItem.OrderId).add(productCodePart);
											} else {
												Set<String> orderItemsIds = new Set<String> { productCodePart };
												existingOrderItemsByOrderId.put(existingOrderItem.OrderId, orderItemsIds);
											}
										} else if (productCodeSplitted[3] == 'XS') {
											if (existingOrderItemsByOrderIdUpdateOrder.containsKey(existingOrderItem.OrderId)) {
												existingOrderItemsByOrderIdUpdateOrder.get(existingOrderItem.OrderId).add(productCodePart);
											} else {
												Set<String> orderItemsIds = new Set<String> { productCodePart };
												existingOrderItemsByOrderIdUpdateOrder.put(existingOrderItem.OrderId, orderItemsIds);
											}
										}
									}

									String orderIdToUpdateLicense;
									for (String existingOrderId : existingOrderItemsByOrderId.keySet()) {
										Boolean containsAllPlanProducts = true;
										if (plan.planProducts.size() == existingOrderItemsByOrderId.get(existingOrderId).size()) {
											for (PlanProduct planProduct : plan.planProducts) {
												if (existingOrderItemsByOrderId.get(existingOrderId).contains(planProduct.ProductCode.split('_') [1]) == false) {
													containsAllPlanProducts = false;
													break;
												}
											}
										} else {
											containsAllPlanProducts = false;
										}
										if (containsAllPlanProducts == true) {
											orderIdToUpdateLicense = existingOrderId;
											break;
										}
									}

									Boolean orderIdAlreadyUpdatedFound = false;
									String orderIdAlreadyUpdated;
									for (String existingOrderId : existingOrderItemsByOrderIdUpdateOrder.keySet()) {
										Boolean containsAllPlanProducts = true;
										if (plan.planProducts.size() == existingOrderItemsByOrderIdUpdateOrder.get(existingOrderId).size()) {
											for (PlanProduct planProduct : plan.planProducts) {
												if (existingOrderItemsByOrderIdUpdateOrder.get(existingOrderId).contains(planProduct.ProductCode.split('_') [1]) == false) {
													containsAllPlanProducts = false;
													break;
												}
											}
										} else {
											containsAllPlanProducts = false;
										}
										if (containsAllPlanProducts) {
											orderIdAlreadyUpdated = existingOrderId;
											orderIdAlreadyUpdatedFound = true;
											break;
										}
									}
								}
							}
						}

						// Renewal d'une licence annuelle
						if (plan.oldRefShareIt != null && plan.isAutoRenewal == true) {
							Boolean orderRenewalIsOnlyOptions = true;
							for (PlanProduct planProduct : plan.planProducts) {
								String productCode = planProduct.productCode;
								String[] productCodeSplitted = productCode.split('_');
								if (productCodePartOptions.contains(productCodeSplitted[1]) == false) {
									orderRenewalIsOnlyOptions = false;
									break;
								}
							}


							// Dans le cas d'un renewal, si le plan correspond à des options sans la solution
							// On complère le refshare-it en ajoutant le refshare-it actuel (après une ,)
							if (orderRenewalIsOnlyOptions == true) {
								DateTime oldDate = DateTime.now().addHours(- 12);
								Order[] oldOrders = [SELECT Id, CurrencyIsoCode, Status, OrderNumber, Ref_ShareIt__c FROM Order WHERE OId_Ref_ShareIt__c = :plan.oldRefShareIt AND CreatedDate >= :oldDate];
								if (oldOrders.size() > 0) {
									order = oldOrders[0];
									order.Ref_ShareIt__c = order.Ref_ShareIt__c + ',' + plan.refShareIt;
								}
							}
						}
						if (order == null) {
							order = new Order();
							if (customer.Id != null || plan.isUpdate == true) {
								order.MyAccount_Auto__c = true;
							}
							if (updateKey == true) {
								plan.isUpdate = true;
							}
							if (distributeur.size() > 0) {
								order.AccountId = distributeur[0].Id;
								if (customerWrapper.account[0].IsPersonAccount == false) {
									order.Client_Final__c = customerWrapper.contact[0].Id;
								} else {
									order.Client_Final__c = customerWrapper.account[0].PersonContactId;
								}
							} else {
								if (customerWrapper.contact.size() > 0) {
									order.AccountId = customerWrapper.contact[0].AccountId;

									if (customerWrapper.account[0].IsPersonAccount == false) {
										order.Contact_Lie__c = customerWrapper.contact[0].Id;
									}
								} else {
									order.AccountId = customerWrapper.account[0].Id;
								}
							}
							if (customerWrapper.IsPersonAndHasCompanyDomain == true) {
								order.HasPersonAccountAndCompanyDomain__c = true;
							}
							Boolean clientFinalOrder = clientFinal;
							if (customer.company != null && customer.company != '' && clientFinal == true) {
								clientFinalOrder = customerDelivering.company != customer.company;
							}
							if (clientFinalOrder) {
								if (customerDeliveringWrapper.contact.size() > 0) {
									if (customerDeliveringWrapper.account[0].IsPersonAccount == false) {
										order.Client_Final__c = customerDeliveringWrapper.contact[0].Id;
									}
								} else {
									if (customerDeliveringWrapper.account[0].IsPersonAccount == true) {
										order.Client_Final__c = customerDeliveringWrapper.account[0].PersonContactId;
									}
								}
								if (customerDeliveringWrapper.IsPersonAndHasCompanyDomain == true) {
									order.HasPersonAccountAndCompanyDomain__c = true;
								}
							}
							order.Discount_Client_Activated__c = customerWrapper.account[0].Discount_Global__c != null && customerWrapper.account[0].Discount_Global__c != 0;
							order.Status = 'Version préliminaire';
							order.EffectiveDate = Date.today();
							order.BillingCountryCode = customer.countryCode;
							order.BillingPostalCode = customer.PostalCode;
							order.BillingStreet = customer.street1 + '\n\n' + customer.street2;
							if (countriesCodesWithStatesCodes.contains(customer.countryCode)) {
								order.BillingStateCode = customer.stateCode;
							}
							order.BillingCity = customer.city;
							order.ShippingCountryCode = customer.countryCode;
							order.ShippingPostalCode = customer.postalCode;
							order.ShippingStreet = customer.street1 + '\n\n' + customer.street2;
							if (countriesCodesWithStatesCodes.contains(customer.countryCode)) {
								order.ShippingStateCode = customer.stateCode;
							}
							order.ShippingCity = customer.city;
							order.Pricebook2Id = pricebook2[0].Id;
							order.CurrencyISOCode = currencyIsoCode;
							order.Type_licence__c = licenseType;
							order.Domaine_utilisateur__c = productDomainToOrderDomain.get(userDomain) != null ? productDomainToOrderDomain.get(userDomain) : userDomain;
							order.Website_Auto__c = true;
							order.Provenance__c = 'ShareIt';
							order.Provenance_du_site_web__c = plan.websiteProvenance;
							order.Provenance_d_affiliation__c = 'Site XLSTAT';
							if (coupon.size() > 0) {
								order.Ref_du_coupon__c = coupon[0].Id;
								order.Discount_coupon_activated__c = true;
							}
							order.Ref_ShareIt__c = plan.refShareIt;
							if (plan.isAutoRenewal) {
								order.Renewal_Auto__c = true;
							}
							order.OId_Ref_ShareIt__c = plan.oldRefShareIt;

							insert order;

							order = [SELECT Id, CurrencyIsoCode, Status, OrderNumber FROM Order WHERE Id = :order.Id LIMIT 1];

							List<Email__c> emailsToInsert = new List<Email__c> ();
							if (customer.Id != null && customer.company != null && customer.company != '' && customerWrapper.account[0].Name != customer.company) {
								Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
								message.toAddresses = new String[] { 'sales@xlstat.com' };
								message.subject = 'Commande automatique: nom d\'entreprise différent sur le client facturé';
								message.plainTextBody = 'Bonjour,\n\nUne commande automatique a été générée.\nLe nom de l\'entreprise renseigné par le client : ' + customer.company + ' était différent du nom de l\'entreprise déjà inscrit dans Salesforce: ' + customerWrapper.account[0].Name + '.\nLa référence de la commande est: ' + order.OrderNumber + '.\n\nCordialement,\nLe robot Salesforce';
								Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> { message };
								Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);

								if (results[0].Success == true) {
									Email__c e = new Email__c();
									e.Address__c = message.toAddresses[0];
									e.Contact__c = customerWrapper.contact[0].Id;
									e.Order__c = order.Id;
									e.Type__c = 'Nom entreprise différent';
									e.Subject__c = message.subject;
									emailsToInsert.add(e);
								}
							}
							if (clientFinalOrder) {
								if (customerDelivering.Id != null && customerDelivering.company != null && customerDelivering.company != '' && customerDeliveringWrapper.account[0].Name != customerDelivering.company) {
									Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
									message.toAddresses = new String[] { 'sales@xlstat.com' };
									message.subject = 'Commande automatique: nom d\'entreprise différent sur le client livré';
									message.plainTextBody = 'Bonjour,\n\nUne commande automatique a été générée.\nLe nom de l\'entreprise renseigné par le client: ' + customerDelivering.company + ' était différent du nom de l\'entreprise déjà inscrit dans Salesforce: ' + customerDeliveringWrapper.account[0].Name + '.\nLa référence de la commande est: ' + order.OrderNumber + '.\n\nCordialement,\nLe robot Salesforce';
									Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> { message };
									Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);

									if (results[0].Success == true) {
										Email__c e = new Email__c();
										e.Address__c = message.toAddresses[0];
										e.Contact__c = customerDelivering.Id;
										e.Order__c = order.Id;
										e.Type__c = 'Nom entreprise différent client livré';
										e.Subject__c = message.subject;
										emailsToInsert.add(e);
									}
								}
							}

							insert emailsToInsert;
						}
					}

					Map<String, Integer> orderProductsQuantities = new Map<String, Integer> ();
					for (PlanProduct planProduct : plan.planProducts) {
						orderProductsQuantities.put(planProduct.productCode, planProduct.quantity);
					}

					Map<String, ID> productsIdsByProductCode = new Map<String, ID> ();
					for (Product2 product :[select Id, ProductCode from Product2 where ProductCode in :orderProductsQuantities.keySet()]) {
						productsIdsByProductCode.put(product.ProductCode, product.Id);
					}

					if (productsIdsByProductCode.keySet().size() > 0) {
						if (isQuote) {
							List<QuoteLineItem> quoteLineItems = new List<QuoteLineItem> ();
							for (PlanProduct planProduct : plan.planProducts) {
								QuoteLineItem quoteLineItem = new QuoteLineItem();
								quoteLineItem.PricebookEntryId = [select Id from PricebookEntry where Product2.Id = :productsIdsByProductCode.get(planProduct.productCode) and Pricebook2.Id = :pricebook2[0].Id limit 1].Id;
								quoteLineItem.Quantity = orderProductsQuantities.get(planProduct.productCode);
								quoteLineItem.QuoteId = quote.Id;
								quoteLineItem.UnitPrice = planProduct.unitPrice;

								if (quoteLineItem.Quantity > 0) quoteLineItems.add(quoteLineItem);
							}

							insert quoteLineItems;

							opportunity.SyncedQuoteId = quote.Id;
							update opportunity;

							plan.status = true;
							plan.id = quote.Id;
							plan.generateLicense = true;
							plan.message = 'Quote created';
						} else {
							List<OrderItem> orderItems = new List<OrderItem> ();
							for (PlanProduct planProduct : plan.planProducts) {
								OrderItem orderItem = new OrderItem();
								orderItem.PricebookEntryId = [select Id from PricebookEntry where Product2.Id = :productsIdsByProductCode.get(planProduct.productCode) and Pricebook2.Id = :pricebook2[0].Id limit 1].Id;
								orderItem.Quantity = orderProductsQuantities.get(planProduct.productCode);
								orderItem.OrderId = order.Id;
								orderItem.UnitPrice = planProduct.unitPrice;

								orderItems.add(orderItem);
							}

							// Decrease order status in order to add orderitems
							order.Status = 'Version préliminaire';
							update order;

							insert orderItems;

							order.Status = 'ShareIt - Envoyer clé Nalpeiron';
							update order;

							Integer indexPlanProductToRemove;
							Boolean planProductHasIndexToRemove = false;
							for (Product2 product : products) {
								PlanProduct planProduct = (productsCodes.get(product.ProductCode));
								for (Integer i = 0; i<plan.planProducts.size(); i++) {
									if (plan.planProducts[i] == planProduct) {
										plan.planProducts[i].productName = product.Name;

										if (product.Family == 'Shipping') {
											indexPlanProductToRemove = i;
											planProductHasIndexToRemove = true;
										}
									}
								}
							}
							plan.licenseType = licenseType;
							plan.status = true;
							plan.id = order.Id;
							if (customerWrapper.contact.size()> 0) {
								plan.customerBilling.id = customerWrapper.contact[0].Id;
							} else {
								if (customerWrapper.accountUpdate == false) {
									customerWrapper.account = [select Id, PersonContactId, Discount_Global__c from Account where Id = :customerWrapper.account[0].Id limit 1];
								}
								plan.customerBilling.id = customerWrapper.account[0].PersonContactId;
							}
							if (plan.customerDelivering != null && clientFinal) {
								if (customerDeliveringWrapper.contact.size() > 0) {
									plan.customerDelivering.id = customerDeliveringWrapper.contact[0].Id;
								} else {
									if (customerDeliveringWrapper.accountUpdate == false) {
										customerDeliveringWrapper.account = [select Id, PersonContactId, Discount_Global__c from Account where Id = :customerDeliveringWrapper.account[0].Id limit 1];
									}
									plan.customerDelivering.id = customerDeliveringWrapper.account[0].PersonContactId;
								}
							}

							if (planProductHasIndexToRemove) {
								Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
								message.toAddresses = new String[] { 'sales@xlstat.com' };
								message.subject = 'Commande automatique: CD';
								message.plainTextBody = 'Bonjour,\n\nUne commande automatique a été générée avec le numéro de commande: ' + order.OrderNumber + '.\nLe client a commandé un CD.' + '.\n\nCordialement,\nVotre collaborateur préféré, Martin';
								Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> { message };
								Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);

								if (results[0].Success == true) {
									Email__c e = new Email__c();
									e.Address__c = message.toAddresses[0];
									e.Contact__c = plan.customerDelivering != null && clientFinal ? plan.customerDelivering.Id : plan.customerBilling.id;
									e.Order__c = order.Id;
									e.Type__c = 'CD commandé';
									e.Subject__c = message.subject;

									insert e;
								}

								plan.planProducts.remove(indexPlanProductToRemove);
							}

							plan.generateLicense = (userDomain == GENERATE_LICENSE_USER_DOMAIN_1 || userDomain == GENERATE_LICENSE_USER_DOMAIN_2 || userDomain == GENERATE_LICENSE_USER_DOMAIN_3) && (licenseType != GENERATE_LICENSE_NO_TYPE_LICENSE_1 || (licenseType == GENERATE_LICENSE_NO_TYPE_LICENSE_1 && updateKey == true)) && licenseType != GENERATE_LICENSE_NO_TYPE_LICENSE_3;
						}
					} else {
						plan.status = false;
						plan.message = customerWrapper.message;
					}
				} else {
					plan.status = false;
					plan.message = customerWrapper.Message;
				}
			} else {
				plan.status = false;
				plan.message = 'No products matching products codes.';
			}
		} else {
			plan.status = false;
			plan.message = 'No products sent';
		}

		return plan;
	}
}