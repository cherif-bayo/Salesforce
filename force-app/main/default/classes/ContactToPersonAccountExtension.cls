public class ContactToPersonAccountExtension {
	public Contact Contact { get; set; }
	public Account[] Accounts { get; set; }

	public ContactToPersonAccountExtension(ApexPages.StandardController stdController) {
		this.Contact = (Contact) stdController.getRecord();
		this.Contact = [SELECT No_support__c, Second_mail__c, ShareIt_Auto__c, Systeme_d_exploitation__c, Website_Auto__c, XLSTAT_365__c, Piste_source_site__c, Piste_nombre_recommand__c, Piste_nombre_de_recommandations__c, Piste_premier_telechargement__c, Piste_date_dernier_recommand__c, Piste_date_derni_re_recommandation__c, Piste_date_cr_ation__c, Piste_nombre_de_t_l_chargements__c, Piste_date_dernier_t_l_chargement__c, Date_creation_compte_MyAccount__c, Compte_MyAccount_cree__c, Acces_MyAccount__c, Id, IsPersonAccount, AssistantName, AssistantPhone, Birthdate, CurrencyIsoCode, Department, DoNotCall, Email, HasOptedOutOfEmail, Fax, HasOptedOutOfFax, HomePhone, LeadSource, MobilePhone, FirstName, LastName, Salutation, OtherPhone, Phone, Title, Description, Ancien_email__c, Domaine_utilisateur__c, Import_auto__c, Langue__c, No_mailling__c, Organisation__c, Pays__c, Remarques__c, Revendeur__c, AccountId FROM Contact WHERE Id = :this.Contact.Id limit 1];

		this.Accounts = [SELECT BillingCity, BillingCountry, BillingPostalCode, BillingState, BillingStreet, ShippingCity, ShippingCountry, ShippingPostalCode, ShippingState, ShippingStreet FROM Account WHERE Id = :this.Contact.AccountId limit 1];
	}

	public PageReference Convert() {
		Opportunity[] accountOpportunitiesContact = [SELECT AccountId, Contact_Lie__c FROM Opportunity WHERE Contact_Lie__c = :this.Contact.Id];
		Order[] accountOrdersContact = [SELECT AccountId, Contact_Lie__c, Status FROM Order WHERE(Contact_Lie__c = :this.Contact.Id)];
		Opportunity[] accountOpportunitiesClient = [SELECT Client_final__c FROM Opportunity WHERE Client_final__c = :this.Contact.Id];
		Order[] accountOrdersClient = [SELECT Client_final__c, Status FROM Order WHERE(Client_final__c = :this.Contact.Id)];
		Map<String, List<Order>> ordersContactByStatus = new Map<String, List<Order>> ();
		Map<String, List<Order>> ordersClientsByStatus = new Map<String, List<Order>> ();
		for (Order order : accountOrdersContact) {
			if (ordersContactByStatus.containsKey(order.Status)) {
				ordersContactByStatus.get(order.Status).add(order);
			} else {
				List<Order> orders = new List<Order> ();
				orders.add(order);
				ordersContactByStatus.put(order.Status, orders);
			}
		}
		for (Order order : accountOrdersClient) {
			if (ordersClientsByStatus.containsKey(order.Status)) {
				ordersClientsByStatus.get(order.Status).add(order);
			} else {
				List<Order> orders = new List<Order> ();
				orders.add(order);
				ordersClientsByStatus.put(order.Status, orders);
			}
		}
		Flexera_Key__c[] contactFlexeraKeys = [SELECT Account__c, Contact__c FROM Flexera_Key__c WHERE Contact__c = :this.Contact.Id];

		Email__c[] contactEmails = [SELECT Contact__c, Order__c, Address__c,Type__c FROM Email__c WHERE Contact__c = :this.Contact.Id];

		Telechargement__c[] telechargements = [SELECT Contact__c FROM Telechargement__c WHERE Contact__c = :this.Contact.Id];

		XLSTAT_365_Activation__c[] activations = [SELECT Contact__c FROM XLSTAT_365_Activation__c WHERE Contact__c = :this.Contact.Id];

		Account personAccount = new Account();
		personAccount.PersonAssistantName = this.Contact.AssistantName;
		personAccount.PersonAssistantPhone = this.Contact.AssistantPhone;
		personAccount.PersonBirthdate = this.Contact.Birthdate;
		personAccount.CurrencyIsoCode = this.Contact.CurrencyIsoCode;
		personAccount.PersonDepartment = this.Contact.Department;
		personAccount.PersonDoNotCall = this.Contact.DoNotCall;
		personAccount.PersonEmail = this.Contact.Email;
		personAccount.PersonHasOptedOutOfEmail = this.Contact.HasOptedOutOfEmail;
		personAccount.Fax = this.Contact.Fax;
		personAccount.PersonHasOptedOutOfFax = this.Contact.HasOptedOutOfFax;
		personAccount.PersonHomePhone = this.Contact.HomePhone;
		personAccount.PersonLeadSource = this.Contact.LeadSource;
		personAccount.PersonMobilePhone = this.Contact.MobilePhone;
		personAccount.Salutation = this.Contact.Salutation;
		personAccount.FirstName = this.Contact.FirstName;
		personAccount.LastName = this.Contact.LastName;
		personAccount.Salutation = this.Contact.Salutation;
		personAccount.PersonOtherPhone = this.Contact.OtherPhone;
		personAccount.Phone = this.Contact.Phone;
		personAccount.PersonTitle = this.Contact.Title;
		personAccount.Description = this.Contact.Description;
		personAccount.Ancien_email__pc = this.Contact.Ancien_email__c;
		personAccount.Domaine_utilisateur__pc = this.Contact.Domaine_utilisateur__c;
		personAccount.Domaine_utilisateur__c = this.Contact.Domaine_utilisateur__c;
		personAccount.Import_auto__pc = this.Contact.Import_auto__c;
		personAccount.Langue__pc = this.Contact.Langue__c;
		personAccount.No_mailling__pc = this.Contact.No_mailling__c;
		personAccount.Organisation__pc = this.Contact.Organisation__c;
		personAccount.Pays__pc = this.Contact.Pays__c;
		personAccount.Remarques__c = this.Contact.Remarques__c;
		personAccount.Acces_MyAccount__pc = this.Contact.Acces_MyAccount__c;
		personAccount.Compte_MyAccount_cree__pc = this.Contact.Compte_MyAccount_cree__c;
		personAccount.Date_creation_compte_MyAccount__pc = this.Contact.Date_creation_compte_MyAccount__c;
		personAccount.Piste_date_dernier_t_l_chargement__pc = this.Contact.Piste_date_dernier_t_l_chargement__c;
		personAccount.Piste_nombre_de_t_l_chargements__pc = this.Contact.Piste_nombre_de_t_l_chargements__c;
		personAccount.Piste_date_cr_ation__pc = this.Contact.Piste_date_cr_ation__c;
		personAccount.Piste_date_derni_re_recommandation__pc = this.Contact.Piste_date_derni_re_recommandation__c;
		personAccount.Piste_date_dernier_recommand__pc = this.Contact.Piste_date_dernier_recommand__c;
		personAccount.Piste_premier_telechargement__pc = this.Contact.Piste_premier_telechargement__c;
		personAccount.Piste_nombre_de_recommandations__pc = this.Contact.Piste_nombre_de_recommandations__c;
		personAccount.Piste_nombre_recommand__pc = this.Contact.Piste_nombre_recommand__c;
		personAccount.Piste_source_site__pc = this.Contact.Piste_source_site__c;
		personAccount.Revendeur__pc = this.Contact.Revendeur__c;
		personAccount.XLSTAT_365__pc = this.Contact.XLSTAT_365__c;
		personAccount.Website_Auto__pc = this.Contact.Website_Auto__c;
		personAccount.Systeme_d_exploitation__pc = this.Contact.Systeme_d_exploitation__c;
		personAccount.ShareIt_Auto__pc = this.Contact.ShareIt_Auto__c;
		personAccount.Second_mail__pc = this.Contact.Second_mail__c;
		personAccount.No_support__pc = this.Contact.No_support__c;

		if (this.Accounts.size() > 0) {
			Account account = this.Accounts[0];

			personAccount.BillingCity = account.BillingCity;
			personAccount.BillingCountry = account.BillingCountry;
			personAccount.BillingPostalCode = account.BillingPostalCode;
			personAccount.BillingState = account.BillingState;
			personAccount.BillingStreet = account.BillingStreet;
			personAccount.ShippingCity = account.ShippingCity;
			personAccount.ShippingCountry = account.ShippingCountry;
			personAccount.ShippingPostalCode = account.ShippingPostalCode;
			personAccount.ShippingState = account.ShippingState;
			personAccount.ShippingStreet = account.ShippingStreet;
		}

		insert personAccount;

		for (Opportunity opportunity : accountOpportunitiesContact) {
			opportunity.AccountId = personAccount.Id;
			opportunity.Contact_Lie__c = null;
		}
		List<Order> ordersToUpdate = new List<Order> ();
		for (List<Order> orders : ordersContactByStatus.values()) {
			for (Order order : orders) {
				order.AccountId = personAccount.Id;
				order.Contact_Lie__c = null;
				order.Status = 'Version préliminaire';

				ordersToUpdate.add(order);
			}
		}
		for (List<Order> orders : ordersClientsByStatus.values()) {
			for (Order order : orders) {
				order.AccountId = personAccount.Id;
				order.Client_Final__c = null;
				order.Status = 'Version préliminaire';

				ordersToUpdate.add(order);
			}
		}
		update accountOpportunitiesContact;
		update ordersToUpdate;
		ordersToUpdate.clear();
		for (String status : ordersContactByStatus.keySet()) {
			for (Order order : ordersContactByStatus.get(status)) {
				order.Status = status;
				ordersToUpdate.add(order);
			}
		}
		for (String status : ordersClientsByStatus.keySet()) {
			for (Order order : ordersClientsByStatus.get(status)) {
				order.Status = status;

				ordersToUpdate.add(order);
			}
		}
		update ordersToUpdate;

		personAccount = [select Id, PersonContactId from Account where Id = :personAccount.Id limit 1];

		for (Opportunity opportunity : accountOpportunitiesClient) {
			opportunity.Client_final__c = personAccount.PersonContactId;
		}
		update accountOpportunitiesClient;

		for (Flexera_Key__c flexeraKey : contactFlexeraKeys) {
			flexeraKey.Contact__c = personAccount.PersonContactId;
			flexeraKey.Account__c = personAccount.Id;
		}
		update contactFlexeraKeys;

		for (Email__c email : contactEmails) {
			email.Contact__c = personAccount.PersonContactId;
		}
		update contactEmails;

		for (Telechargement__c telechargement : telechargements) {
			telechargement.Contact__c = contact.Id;
		}
		update telechargements;

		for (XLSTAT_365_Activation__c activation : activations) {
			activation.Contact__c = contact.Id;
		}
		update activations;

		//TODO delete old contact;

		PageReference pageRef = new PageReference('/' + personAccount.Id);
		pageRef.setRedirect(true);
		return pageRef;
	}
}