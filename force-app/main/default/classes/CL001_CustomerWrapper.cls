public class CL001_CustomerWrapper {

	private static String DEFAULT_LANGUAGE = 'US';
	private static Integer MAX_LENGTH_FIRST_NAME = 40; // Limit Salesforce
	private static Integer MAX_LENGTH_LAST_NAME = 80; // Limit Salesforce
	private static Integer MAX_LENGTH_POSTAL_CODE = 20; // Limit Salesforce
	private static Map<String, String> productDomainToOrderDomain = new Map<String, String> { 'Entreprise/Privé' => 'Company', 'Education' => 'Academic', 'Etudiant' => 'Student' };
	private static Map<String, String> languageToContactLanguage = new Map<String, String> { 'de' => 'DE', 'es' => 'ES', 'en' => 'US', 'ja' => 'JP', 'fr' => 'FR' };
	private static Set<String> countriesCodesWithStatesCodes = new Set<String> { 'CA', 'AU', 'US' };

	private Boolean isQuote;
	private String currencyIsoCode;
	private String userDomain;

	public WebServiceOrderV2.Customer customer { get; set; }
	public Boolean IsPersonAndHasCompanyDomain { get; set; }
	public Boolean accountUpdate { get; set; }
	public Account account2 { get; set; }
	public Contact contact2 { get; set; }
	public Boolean status { get; set; }
	public String message { get; set; }

	public String PostalCode { get {
			return this.customer.postalCode;
		} }

	public CL001_CustomerWrapper(WebServiceOrderV2.Customer customer) {
		System.debug('[#CL001_CustomerWrapper] customer : ' + customer);
		this.customer = customer;
		this.IsPersonAndHasCompanyDomain = false;
		this.accountUpdate = false;
	}

	public boolean InsertInSalesforce(Boolean isQuote, String currencyIsoCode, String userDomain) {
		this.isQuote = isQuote;
		this.currencyIsoCode = currencyIsoCode;
		this.userDomain = userDomain;

		status = true;

		//Sanitarisation des données : Nom & Prenom
		if (customer.postalCode != null && customer.postalCode.length() > MAX_LENGTH_POSTAL_CODE) customer.postalCode = customer.postalCode.substring(0, MAX_LENGTH_POSTAL_CODE - 1);
		if (customer.firstName != null) customer.firstName = customer.firstName.trim();
		if (customer.lastName != null) customer.lastName = customer.lastName.trim();

		//Sanitarisation des données : StateCode
		if (States.StatesByCountryCode.containsKey(customer.countryCode)
		    && !States.StatesByCountryCode.get(customer.countryCode).contains(customer.stateCode)) {
			customer.stateCode = '';
		}

		if (customer.id != null && customer.id != '') { //On doit retrouver le numo de client dans salesforce
			if (!updateExistingContactAndAccount(customer)) {
				status = false;
				message = 'no account found in SFDC';
				return false;
			}
		} else { // Pas de customer.id
			insertContactAndHisAccount();
		}
		return true;
	}

	private boolean updateExistingContactAndAccount(WebServiceOrderV2.Customer customer) {

		// Mise à jour des infos du contact associé au customer.Id s'il existe
		List<Contact> contacts = [select Domaine_Utilisateur__c, Salutation, Phone, MailingCountryCode, MailingPostalCode, MailingStreet, MailingCity, MailingStateCode, Id, AccountId, FirstName, LastName, Email, Website_Auto__c, Pays__c, Langue__c, CurrencyIsoCode from Contact where Website_Id__c = :customer.id and IsPersonAccount = false limit 1];
		if (contacts.size() > 0) {
			Contact contact = contacts[0];
			updateExistingContact(contact);

			// Mise à jour des infos du compte associé au contact
			List<account> accounts = [select Discount_Global__c, ShippingCountryCode, Salutation, Id, Name, IsPersonAccount, Industry, Sous_secteur__c, Num_ro_de_TVA__c, Type, Website_Auto__c, BillingCountryCode, BillingPostalCode, BillingStreet, BillingStateCode, BillingCity, CurrencyIsoCode, Selection_importance__c, Domaine_utilisateur__c from Account where Id = :contact.AccountId limit 1];
			if (accounts.size() > 0) {
				Account account = accounts[0];
				account.BillingCountryCode = getBestValue(customer.CountryCode, account.BillingCountryCode);
				account.BillingPostalCode = getBestValue(customer.PostalCode, account.BillingPostalCode);
				account.BillingStreet = getBestValue(customer.street1, account.BillingStreet);
				if (customer.street2 != null && customer.street2 != 'null') account.BillingStreet += '\n' + customer.street2;
				account.BillingStateCode = getBestValue(customer.StateCode, account.BillingStateCode);
				account.BillingCity = getBestValue(customer.City, account.BillingCity);
				account.Num_ro_de_TVA__c = getBestValue(customer.vATNumber, account.Num_ro_de_TVA__c);
				update account;
				accountUpdate = true;
				account2 = account;
			}
			return true;
		} else { // Mise à jour du compte personnel associé au customer.Id
			List<Account> personnalAccounts = [select Discount_Global__c,Domaine_Utilisateur__c, Phone, PersonMailingCountryCode, PersonMailingPostalCode,
			                                   PersonMailingStreet, PersonMailingCity, PersonMailingStateCode, FirstName, LastName, PersonContactId,
			                                   PersonEmail, Website_Auto__c, Langue__c, BillingCountryCode, BillingPostalCode, IsPersonAccount,
											   BillingStreet, BillingStateCode, BillingCity, Num_ro_de_TVA__c, CurrencyIsoCode from Account
			                                   where Website_Id__pc = :customer.id and IsPersonAccount = true limit 1];
			if (personnalAccounts.size() > 0) {
				Account personnalAccount = personnalAccounts[0];

				personnalAccount.PersonMailingStreet = getBestValue(customer.street1, personnalAccount.PersonMailingStreet);
				if (customer.street2 != null && customer.street2 != 'null') personnalAccount.PersonMailingStreet += '\n' + customer.street2;
				personnalAccount.PersonMailingPostalCode = getBestValue(customer.PostalCode, personnalAccount.PersonMailingPostalCode);
				personnalAccount.PersonMailingCity = getBestValue(customer.City, personnalAccount.PersonMailingCity);
				personnalAccount.PersonMailingStateCode = getBestValue(customer.StateCode, personnalAccount.PersonMailingStateCode);
				personnalAccount.PersonMailingCountryCode = getBestValue(customer.CountryCode, personnalAccount.PersonMailingCountryCode);
				personnalAccount.Phone = getBestValue(customer.phone, personnalAccount.Phone);
				personnalAccount.Website_Auto__c = true;
				personnalAccount.BillingCountryCode = getBestValue(customer.CountryCode, personnalAccount.BillingCountryCode);
				personnalAccount.BillingPostalCode = getBestValue(customer.PostalCode, personnalAccount.BillingPostalCode);
				personnalAccount.BillingStreet = getBestValue(customer.street1, personnalAccount.BillingStreet);
				if (customer.street2 != null && customer.street2 != 'null') personnalAccount.BillingStreet += '\n' + customer.street2;
				personnalAccount.BillingStateCode = getBestValue(customer.StateCode, personnalAccount.BillingStateCode);
				personnalAccount.BillingCity = getBestValue(customer.City, personnalAccount.BillingCity);
				personnalAccount.Num_ro_de_TVA__c = getBestValue(customer.vATNumber, personnalAccount.Num_ro_de_TVA__c);
				update personnalAccount;
				accountUpdate = true;
				account2 = personnalAccount;
				return true;
			}
		}
		return false;
	}

	private String getBestValue(String customerValeur, String contactValue) {
		if (customerValeur != null && customerValeur.length() > 0) return customerValeur.abbreviate(CL003_Constants.MAX_LENGTH_VATNUMBER);
		else return contactValue;
	}

	private void updateExistingContact(Contact contact) {
		contact.MailingStreet = getBestValue(customer.street1, contact.MailingStreet);
		if (customer.street2 != null && customer.street2 != 'null') contact.MailingStreet += '\n' + customer.street2;
		contact.MailingPostalCode = getBestValue(customer.PostalCode, contact.MailingPostalCode);
		contact.MailingCity = getBestValue(customer.City, contact.MailingCity);
		contact.MailingStateCode = getBestValue(customer.StateCode, contact.MailingStateCode);
		contact.MailingCountryCode = getBestValue(customer.CountryCode, contact.MailingCountryCode);
		contact.Phone = getBestValue(customer.phone, contact.Phone);
		contact.Website_Auto__c = true;
		update contact;
		contact2 = contact;
	}

	private boolean insertContactAndHisAccount() {

		if (isProfessionalAccount()) { // Recherche d'un compte Professionnel existant dans SFDC avec le nom du customer.company
			List<Account> accounts = [select Discount_Global__c, ShippingCountryCode, Salutation, Id, Name, IsPersonAccount, PersonContactId, Industry, Sous_secteur__c, Num_ro_de_TVA__c, Type, Website_Auto__c, BillingCountryCode, BillingPostalCode, BillingStreet, BillingStateCode, BillingCity, CurrencyIsoCode, Selection_importance__c, Domaine_utilisateur__c from Account where Name LIKE :customer.company limit 1];
			if (accounts.size() > 0) {
				Account account = accounts[0];
				if (account.BillingCountryCode == customer.countryCode) {
					account.Num_ro_de_TVA__c = customer.vatNumber;
					update account;
                    
                    Map<String, Account> personAccountToFind = new Map<String, Account>();
					List<Account> personAccounts = [select Discount_Global__c, PersonContactId, Num_ro_de_TVA__c, ShippingCountryCode, IsPersonAccount, Id, FirstName, LastName, Pays__pc, Langue__pc, PersonEmail, Type, Website_Auto__c, BillingCountryCode, BillingPostalCode, BillingStreet, BillingStateCode, BillingCity, CurrencyIsoCode, Selection_importance__c, Domaine_utilisateur__c from Account where PersonEmail = :customer.email OR Second_mail__pc = :customer.email];
                    for (Account acc : personAccounts){
                        personAccountToFind.put(acc.FirstName +' '+ acc.LastName, acc);
                    }
                    
                    System.debug('personAccountToFind: ' +personAccountToFind.keySet());
                    Boolean PersonAccountEqualsAcountName = personAccountToFind.keySet().contains(account.Name);
                    System.debug('PersonAccountEqualsAcountName:' +PersonAccountEqualsAcountName);
                    
                    if (!PersonAccountEqualsAcountName) {
                        // Recherche de contact appartenant au compte trouvé dans SFDC et possédant comme email le customer.email
                        List<Contact> contacts = [select Domaine_Utilisateur__c, Salutation, Phone, MailingCountryCode, MailingPostalCode, MailingStreet, MailingCity, MailingStateCode, Id, AccountId, FirstName, LastName, Email, Website_Auto__c, Pays__c, Langue__c, CurrencyIsoCode from Contact where(Email = :customer.email OR Second_mail__c = :customer.email) and AccountId = :account.Id];
                        if (contacts.size() > 0) updateExistingContact(getBestContact(contacts));
                        else createContactFromCustomerForAccount(account);
                        return true;
                    } else {
                        customer.company = '';
                        Account personalAccount = getBestPersonnalAccount(personAccounts);
				        updateExistingPersonalAccount(personalAccount);
				        return true;
                    }
					
				} else { // Modification du nom de la company sur le customer s'il s'agit d'une filiale dans un autre pays
					customer.company = customer.company + ' ' + customer.countryCode;
				}
			} // Fin du traitement du compte professionnel reconnu dans salesforce
		} else { // Recherche de compte personnel (étudiant ou indépendant) avec l'email du customer
			List<Account> accounts = [select Discount_Global__c, PersonContactId, Num_ro_de_TVA__c, ShippingCountryCode, IsPersonAccount, Id, FirstName, LastName, Pays__pc, Langue__pc, PersonEmail, Type, Website_Auto__c, BillingCountryCode, BillingPostalCode, BillingStreet, BillingStateCode, BillingCity, CurrencyIsoCode, Selection_importance__c, Domaine_utilisateur__c from Account where PersonEmail = :customer.email OR Second_mail__pc = :customer.email];
			if (accounts.size() > 0) {
				Account personalAccount = getBestPersonnalAccount(accounts);
				updateExistingPersonalAccount(personalAccount);
				return true;
			}
		}
		// Il n'existe pas de compte professionel ou personnel dans Salesforce donc il faut le créer
		Account account = createNewAccount();
		account2 = account;

		// Si il s'agit d'un compte professionel on cree un contact
		if (isProfessionalAccount()) createContactFromCustomerForAccount(account);
		return true;
	}

	private boolean isProfessionalAccount() {
		System.debug('[CL001_CustomerWrapper#isProfessionalAccount] customer.company =' + customer.company + ' userDomain' + userDomain);
		return customer.company != null && customer.company != '' && userDomain != 'Etudiant';
	}

	private Contact getBestContact(List<Contact> contacts) {
		Integer index = 0;
		Boolean found = false;
		if (contacts.size() > 1) {
			for (Integer i = 0; i<contacts.size(); i++) {
				if (contacts[i].Email == customer.email) {
					index = i;
					found = true;
					break;
				}
				index++;
			}
		}
		if (!found) index = 0;
		return contacts[index];
	}

	private Account getBestPersonnalAccount(List<Account> accounts) {
		Integer index = 0;
		Boolean found = false;
		if (accounts.size()> 1) {
			for (Integer i = 0; i<accounts.size(); i++) {
				Account account = accounts[i];
				if (account.PersonEmail == customer.email) {
					index = i;
					found = true;
					break;
				}
				index++;
			}
		}
		if (!found) index = 0;
		return accounts[index];
	}

	private void createContactFromCustomerForAccount(Account account) {
		Contact contact = new Contact();
		contact.FirstName = formatName(customer.firstName).abbreviate(MAX_LENGTH_FIRST_NAME);
		contact.LastName = formatName(customer.lastName).abbreviate(MAX_LENGTH_LAST_NAME);
		contact.Phone = customer.phone;
		contact.Email = customer.email;
		contact.Website_Auto__c = true;
		contact.MailingStreet = customer.street1;
		if (customer.street2 != null && customer.street2 != 'null') contact.MailingStreet += '\n' + customer.street2;
		contact.MailingCity = customer.city;
		contact.MailingCountryCode = customer.countryCode;
		contact.MailingPostalCode = customer.postalCode;
		contact.MailingStateCode = customer.StateCode;
		contact.currencyIsoCode = currencyIsoCode;
		contact.Domaine_utilisateur__c = productDomainToOrderDomain.get(userDomain) != null ? productDomainToOrderDomain.get(userDomain) : userDomain;
		contact.Langue__c = languageToContactLanguage.get(customer.language.toLowerCase()) != null ? languageToContactLanguage.get(customer.language.toLowerCase()) : DEFAULT_LANGUAGE;
		contact.AccountId = account.Id;
		System.debug('[CL001_CustomerWrapper#createContactFromCustomerForAccount] contact : ' + contact);
		insert contact;
		contact2 = contact;
	}

	private void updateExistingPersonalAccount(Account account) {
		if (!isQuote) account.Type = 'Client';
		account.BillingCountryCode = getBestValue(customer.countryCode, account.BillingCountryCode);
		account.BillingPostalCode = getBestValue(customer.postalCode, account.BillingPostalCode);
		account.BillingCity = getBestValue(customer.city, account.BillingCity);
		account.BillingStreet = getBestValue(customer.street1, account.BillingStreet);
		if (customer.street2 != null && customer.street2 != 'null') account.BillingStreet += '\n' + customer.street2;
		account.Num_ro_de_TVA__c = getBestValue(customer.vatNumber, account.Num_ro_de_TVA__c);
		account.ShippingCountryCode = getBestValue(customer.countryCode, account.ShippingCountryCode);
		account.CurrencyIsoCode = getBestValue(currencyIsoCode, account.CurrencyIsoCode);
		if (account.Domaine_utilisateur__c == null) account.Domaine_utilisateur__c = productDomainToOrderDomain.get(userDomain) != null ? productDomainToOrderDomain.get(userDomain) : userDomain;
		account.Selection_importance__c = account.Selection_importance__c == null ? '2 - Normal' : account.Selection_importance__c;
		if (countriesCodesWithStatesCodes.contains(customer.countryCode)) account.BillingStateCode = customer.stateCode != null ? customer.stateCode : account.BillingStateCode;
		if (!isProfessionalAccount() || account.IsPersonAccount) { // Compte Personnel : indépendant ou étudiant
			account.Phone = customer.phone;
			account.FirstName = formatName(customer.firstName).abbreviate(MAX_LENGTH_FIRST_NAME);
			account.LastName = formatName(customer.lastName).abbreviate(MAX_LENGTH_LAST_NAME);
			account.PersonEmail = account.PersonEmail == null ? customer.email : account.PersonEmail;
			if (account.Langue__pc == null) account.Langue__pc = languageToContactLanguage.get(customer.language.toLowerCase()) != null ? languageToContactLanguage.get(customer.language.toLowerCase()) : DEFAULT_LANGUAGE;
			if (userDomain == 'Etudiant') { // étudiants
				account.PersonDepartment = customer.company;
			} else {
				this.IsPersonAndHasCompanyDomain = true;
			}
		}
		System.debug('[CL001_CustomerWrapper#updateExistingPersonalAccount] account : ' + account);
		update account;
		accountUpdate = true;
		account2 = account;
	}

	private Account createNewAccount() {
		Account account = new Account();
		account.Type = isQuote ? 'Prospect' : 'Client';
		account.Website_Auto__c = true;
		account.BillingCountryCode = customer.countryCode;
		account.BillingPostalCode = customer.PostalCode;
		account.BillingCity = customer.city;
		account.BillingStreet = customer.street1;
		if (customer.street2 != null && customer.street2 != 'null') account.BillingStreet += '\n' + customer.street2;
		account.Num_ro_de_TVA__c = customer.vatNumber;
		account.ShippingCountryCode = customer.countryCode;
		account.CurrencyIsoCode = currencyIsoCode;
		account.Domaine_utilisateur__c = productDomainToOrderDomain.get(userDomain) != null ? productDomainToOrderDomain.get(userDomain) : userDomain;
		account.Selection_importance__c = '2 - Normal';
		if (countriesCodesWithStatesCodes.contains(customer.countryCode)) account.BillingStateCode = customer.stateCode != null ? customer.stateCode : account.BillingStateCode;

		if (isProfessionalAccount()) { // compte Professionel
			account.Name = customer.company;
		} else { // compte Personnel
			account.Phone = customer.phone;
			account.Salutation = '';
			account.FirstName = formatName(customer.firstName).abbreviate(MAX_LENGTH_FIRST_NAME);
			account.LastName = formatName(customer.lastName).abbreviate(MAX_LENGTH_LAST_NAME);
			account.PersonEmail = customer.email;
			account.Langue__pc = languageToContactLanguage.get(customer.language.toLowerCase()) != null ? languageToContactLanguage.get(customer.language.toLowerCase()) : DEFAULT_LANGUAGE;
			if (userDomain == 'Etudiant') {
				account.PersonDepartment = customer.company;
			}
		}
		System.debug('[CL001_CustomerWrapper#createNewAccount] account : ' + account);
		insert account;
		account2 = account;

		return account;
	}

	private String formatName(String name) {
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
}