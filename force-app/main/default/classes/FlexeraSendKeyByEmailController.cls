public class FlexeraSendKeyByEmailController {
	public static String STATCON_ACCOUNT_ID = '0012400000D3NyB'; //PROD
	public static String STATCON_ACCOUNT_NAME = 'StatCon GmbH';
	private static String STATCON_SH_ACCOUNT_ID = '0012400000McLO8';
	private static String MINDWARE_ACCOUNT_ID = '0012400000D3NsA';
	private static String MINDWARE_SH_ACCOUNT_ID = '0012400000ER4mV';
	private static String STATCON_EMAIL_TEMPLATE = 'Statcon';
	private static String STATCON_EMAIL_TEMPLATE_PERSON_ACCOUNT = 'Statcon person account';
	private static String GENERIC_TEMPLATE_PREFIX = 'ORDER_OK_';
	private static String GENERIC_TEMPLATE_SUFFIX = '_GENERIC';

	private static String COUNTRY_FRANCE = 'FR';
	private static String LANGUAGE_FRANCE = 'FR';
	private static String LANGUAGE_OTHER = 'EN';
	private static String TEMPLATE_NAME_START = 'Licence key';
	private static String EXPIRING_TYPE = 'Expiring';

	private List<EmailMessageWrapper> listEmailMessageWrapper;
	private Flexera_Key__c key;
	private UtilityClassV2 utilityClass;
	private Map<String, Texte_Email__c> textesEmailByCode;

	public List<Contact> contact { get; set; }
	public String LicenceKey { get; set; }
	public String LicenceModules { get; set; }
	public String LicenceNbUsers { get; set; }
	public String LicenceType { get; set; }
	public String OrderId { get; set; }
	public Boolean EmailSent { get; set; }
	public String RemarqueEmail { get; set; }
	public String ContactName { get; set; }
	public Boolean HasPreview { get; set; }
	//public String AccountName { get; set; }
	public String HTAmount { get; set; }
	public String ShareItFee { get; set; }
	public String AmountStatcon { get; set; }
	public Order order { get; set; }

	public String HtmlBody { get; set; }

	private Map<String, String> mapBodyParams;
	private Map<String, String> mapSubjectParams;
	private Boolean isAnnual;
	private Boolean isFR;
	public Boolean getIsAnnualFR() { return isAnnual && isFR; }
	public Boolean getIsPerpetualFR() { return !isAnnual && isFR; }
	public Boolean getIsAnnualEN() { return isAnnual && !isFR; }
	public Boolean getIsPerpetualEN() { return !isAnnual && !isFR; }
	//public Boolean getHasRemarque() { return this.RemarqueEmail != null; }
	public List<WrapperContact> WpContacts { get; set; }
	public String subject {
		get {
			if (this.subject == null) { this.subject = 'Licence'; }
			return this.subject;
		}
		set;
	}

	public String keyId { get; set; }
	public Boolean IsUpdate { get; set; }

	public void InstanciatePart1() {

		String[] keysIds = this.keyId.split('-');
		Flexera_Key__c[] keys = [
				SELECT Software__c, SoftwareCode__c, Order__r.AccountId, Is_Network__c, Expiration_Label_FR__c, Expiration_Label_EN__c, Has_Student_Ext__c, Name, Campaign__c, Order__c, Contact__c, Date_limite__c, Domaine_utilisateur__c, Expiration__c, Modules__c, Nb_activations__c, Nb_activations_allowed__c, Quantity__c, Type_client__c, Type_licence__c, XLSTAT_Options__c, XLSTAT_Solution__c, Version__c, Entitlement_Id__c
				FROM Flexera_Key__c WHERE Id IN :keysIds
		];
		this.key = keys[0];

		this.OrderId = this.key.Order__c;

		Order[] ordersNotPaid = [SELECT Id FROM Order WHERE AccountId = :this.key.Order__r.AccountId AND Status != 'Payée'];
		if (ordersNotPaid.size() > 0) { ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Attention ! Le compte rattaché à la commande a passé d\'autres commandes qui n\'ont pas été validées. Vérifiez que la clef comporte tous les modules achetés avant de continuer.'));}

		this.order = [SELECT Client_final__c, AccountId, R_f_Bon_de_commande__c, Provenance__c, Remarque_Email__c, Type_licence__c, TotalAmountAfterDiscountShowed__c, Frais_ShareIt__c, Amount_Statcon__c FROM Order WHERE Id = :this.OrderId LIMIT 1];
		this.RemarqueEmail = order.Remarque_Email__c;

		List<String> contactsIds = new List<String> ();
		for (Flexera_Key__c k : keys) {
			contactsIds.add(k.Contact__c);
		}
		this.contact = [SELECT Name, FirstName, LastName, Email, Second_mail__c, Langue__c, AccountId, Code_MyAccount__c, Compte_MyAccount_cree__c FROM Contact WHERE Id IN :contactsIds];
		this.ContactName = this.contact[0].Name;

		Contact[] contactsAccount = [SELECT Name, FirstName, LastName, Email, Second_mail__c, Langue__c, Code_MyAccount__c, Compte_MyAccount_cree__c FROM Contact WHERE AccountId = :order.AccountId];

		List<Id> accountsIds = new List<Id> ();
		for (Contact contact : this.contact) {
			accountsIds.add(contact.AccountId);
		}
		Account[] accounts = [SELECT Id, IsPersonAccount, Name FROM Account WHERE Id IN :accountsIds];
		Map<Id, Account> mapAccounts = new Map<Id, Account> (accounts);

		for (Contact contact : this.contact) {
			WrapperContact wpContact = new WrapperContact();
			wpContact.contact = contact;
			wpContact.contactsAccount = contactsAccount;
			wpContact.account = mapAccounts.get(contact.AccountId);
			wpContact.clientFinal = this.order.Client_final__c;
			wpContact.ShowAccountContacts = this.order.AccountId != STATCON_SH_ACCOUNT_ID && this.order.AccountId != MINDWARE_SH_ACCOUNT_ID;
			WpContacts.add(wpContact);
		}

		if (this.contact[0].Langue__c == COUNTRY_FRANCE) { this.subject = 'Licence '+key.XLSTAT_Solution__c+'.'; }
		else { this.subject = key.XLSTAT_Solution__c+' License.'; }

		if (order.R_f_Bon_de_commande__c != null) { // && order.Provenance__c == 'Bon de commande'){
			if (this.contact[0].Langue__c == COUNTRY_FRANCE) { this.subject += ' Commande: ' + order.R_f_Bon_de_commande__c; }
			else { this.subject += ' Order: ' + order.R_f_Bon_de_commande__c; }
		}

		textesEmailByCode = new Map<String, Texte_Email__c> ();
		List<Texte_Email__c> texts = [SELECT Code__c, Texte__c FROM Texte_Email__c];
		for (Texte_Email__c text : texts) textesEmailByCode.put(text.Code__c, text);
	}

	public void InstanciatePart2() {
		this.isAnnual = this.key.Expiration__c == EXPIRING_TYPE;
		this.isFR = this.contact[0].Langue__c == COUNTRY_FRANCE;

		this.LicenceKey = key.Name;
		this.LicenceModules = key.Modules__c;
		if (this.key.Type_licence__c == 'Large Campus') {
			if (this.isFR) {
				if (this.key.Has_Student_Ext__c) { this.LicenceNbUsers = 'Campus, extension étudiante'; }
				else { this.LicenceNbUsers = 'Campus, illimitée'; }
			} else {
				if (this.key.Has_Student_Ext__c) { this.LicenceNbUsers = 'Campus, student extension'; }
				else { this.LicenceNbUsers = 'Campus, unlimited'; }
			}
		} else if (this.key.Type_licence__c == 'Small Campus') {
			if (this.isFR) {
				if (this.key.Has_Student_Ext__c) { this.LicenceNbUsers = 'Campus, extension étudiante'; }
				else { this.LicenceNbUsers = 'Campus, jusqu\'à 500 utilisateurs'; }
			} else {
				if (this.key.Has_Student_Ext__c) { this.LicenceNbUsers = 'Campus, student extension'; }
				else { this.LicenceNbUsers = 'Campus, up to 500'; }
			}
		} else if (this.key.Type_licence__c == 'Classroom') {
			if (this.isFR) {
				if (this.key.Has_Student_Ext__c) { this.LicenceNbUsers = 'Campus, extension étudiante'; }
				else { this.LicenceNbUsers = 'Campus, jusqu\'à 60 utilisateurs'; }
			} else {
				if (this.key.Has_Student_Ext__c) { this.LicenceNbUsers = 'Campus, student extension'; }
				else { this.LicenceNbUsers = 'Campus, up to 60'; }
			}
		} else {
			this.LicenceNbUsers = String.valueOf(key.Quantity__c);
		}
		if (this.isFR) { this.LicenceType = key.Expiration_Label_FR__c; }
		else { this.LicenceType = key.Expiration_Label_EN__c; }

		this.HasPreview = false;

		this.HTAmount = String.valueOf(order.TotalAmountAfterDiscountShowed__c);
		this.ShareItFee = String.valueOf(order.Frais_ShareIt__c);
		this.AmountStatcon = String.valueOf(order.Amount_Statcon__c);
	}

	public FlexeraSendKeyByEmailController() {
		listEmailMessageWrapper = new List<EmailMessageWrapper> ();
		WpContacts = new List<WrapperContact> ();
		Boolean hasNalpeironKeyId = true;

		this.keyId = ApexPages.currentPage().getParameters().get('keys_id');
		String isUpdateStr = ApexPages.currentPage().getParameters().get('is_update');

		System.debug('[FlexeraSendKeyByEmailController] keys:'+keyId+' update:'+String.valueOf(isUpdateStr));

		if (isUpdateStr != null) { this.IsUpdate = Boolean.valueOf(isUpdateStr); }
		else { this.IsUpdate = false; }

		if (keyId != null) { this.InstanciatePart1(); }
		else {
			hasNalpeironKeyId = false;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Aucune clé sélectionnée.'));
		}

		if (hasNalpeironKeyId) { this.InstanciatePart2(); }
	}

	private void previewXLStat() {
		this.mapSubjectParams = new Map<String, String> {};
		this.mapBodyParams = new Map<String, String> {
				'{!LicenceKey}' => this.LicenceKey,
				'{!LicenceModules}' => this.LicenceModules,
				'{!LicenceNbUsers}' => this.LicenceNbUsers,
				'{!LicenceType}' => this.LicenceType,
				'{!RemarqueEmail}' => this.RemarqueEmail
		};
		for (WrapperContact wpContact : this.WpContacts) {
			mapBodyParams.put('{!ContactName}', wpContact.contact.Name);
			if (wpContact.contact.Compte_MyAccount_cree__c == false) {
				mapBodyParams.put('{!CodeMyAccount}', wpContact.contact.Code_MyAccount__c);
				if (this.isFR) {
					mapBodyParams.put('{!MyAccountDescription}', textesEmailByCode.get('FRNCD').Texte__c);
					mapBodyParams.put('{!MyAccountButton}', textesEmailByCode.get('FRNCB').Texte__c);
					mapBodyParams.put('{!MyAccountButtonLink}', textesEmailByCode.get('FRNCL').Texte__c);
				} else {
					System.debug(textesEmailByCode);
					mapBodyParams.put('{!MyAccountDescription}', textesEmailByCode.get('ENNCD').Texte__c);
					mapBodyParams.put('{!MyAccountButton}', textesEmailByCode.get('ENNCB').Texte__c);
					mapBodyParams.put('{!MyAccountButtonLink}', textesEmailByCode.get('ENNCL').Texte__c);
				}
			} else {
				mapBodyParams.put('{!CodeMyAccount}', '');
				if (this.isFR) {
					mapBodyParams.put('{!MyAccountDescription}', textesEmailByCode.get('FRCD').Texte__c);
					mapBodyParams.put('{!MyAccountButton}', textesEmailByCode.get('FRCB').Texte__c);
					mapBodyParams.put('{!MyAccountButtonLink}', textesEmailByCode.get('FRCL').Texte__c);
				} else {
					mapBodyParams.put('{!MyAccountDescription}', textesEmailByCode.get('ENCD').Texte__c);
					mapBodyParams.put('{!MyAccountButton}', textesEmailByCode.get('ENCB').Texte__c);
					mapBodyParams.put('{!MyAccountButtonLink}', textesEmailByCode.get('ENCL').Texte__c);
				}
			}
			listEmailMessageWrapper.add(new EmailMessageWrapper('sales@xlstat.com', wpContact.ContactEmail, null, 'sales@xlstat.com', this.subject, mapSubjectParams, null, mapBodyParams));
		}
		if (listEmailMessageWrapper.size() > 0) {
			String templateName = TEMPLATE_NAME_START + ' ';
			if (this.IsUpdate == true) { templateName += 'Update' + ' '; }
			else {
				if (key.Is_Network__c == true) { templateName += 'Network' + ' '; }
				else { templateName += key.Expiration_Label_EN__c + ' '; }
			}
			if (this.isFR) { templateName += LANGUAGE_FRANCE; }
			else { templateName += LANGUAGE_OTHER; }
			if (this.RemarqueEmail != null) { templateName += ' Remarque'; }

			this.utilityClass = new UtilityClassV2(listEmailMessageWrapper, templateName, key.Order__c);
			if (!Test.isRunningTest()) {this.HtmlBody = utilityClass.HtmlBody.remove(utilityClass.HtmlBody.left(utilityClass.HtmlBody.indexOf('leftpadding="0">') + 'leftpadding="0">'.length())).left(utilityClass.HtmlBody.indexOf('</body>'));}

			this.HasPreview = true;
		}
	}

	private void previewGeneric() {
		String countryCode = this.contact[0].Langue__c == COUNTRY_FRANCE ? LANGUAGE_FRANCE : LANGUAGE_OTHER;
       	String solution = this.key.XLSTAT_Solution__c.toUpperCase();
        System.debug('>>>> Preview - this.key.XLSTAT_Solution__c = '+solution);
		String templateName = GENERIC_TEMPLATE_PREFIX+countryCode+GENERIC_TEMPLATE_SUFFIX+'_'+solution;
		EmailTemplate emailTemplate = [SELECT Id, Subject, Body, HtmlValue FROM EmailTemplate WHERE DeveloperName = :templateName LIMIT 1];
		String previewedHtmlBody = emailTemplate.HtmlValue;
		Map<String, String> templateFieldsForPreview = new Map<String, String>{
				'{!Contact.FirstName}' => this.contact[0].FirstName,
				'{!Contact.LastName}' => this.contact[0].LastName,
				'{!Flexera_Key__c.Name}' => this.key.Name,
				'{!Flexera_Key__c.Modules__c}' => this.key.Modules__c == null ? '' : this.key.Modules__c,
                '{!LicenceNbUsers}' => this.LicenceNbUsers
				
		};
		if (previewedHtmlBody != null && String.isNotBlank(previewedHtmlBody)) {
			for (String key : templateFieldsForPreview.keySet()) {
				System.debug('>>>> previewedHtmlBody = '+previewedHtmlBody);
				System.debug('>>>> key = '+key);
				System.debug('>>>> templateFieldsForPreview.get(key) = '+templateFieldsForPreview.get(key));
				previewedHtmlBody = previewedHtmlBody.replace(key, templateFieldsForPreview.get(key));
			}
		}
		this.HtmlBody = previewedHtmlBody;
		this.HasPreview = true;
	}

	public void Preview() {
		String solution = this.key.XLSTAT_Solution__c;
		if (solution == null) { solution = this.key.Software__c; }
		System.debug('>>>> Preview - this.key = '+this.key);
		System.debug('>>>> Preview - this.key.XLSTAT_Solution__c = '+this.key.XLSTAT_Solution__c);
		if (solution.toLowerCase().contains('xlstat')) { previewXLStat(); }
		else { previewGeneric(); }
	}

	private PageReference sendXLStat() {
		if (listEmailMessageWrapper.size() > 0) {
			List<Email__c> emailsToInsert = new List<Email__c> ();
			this.listEmailMessageWrapper.clear();
			for (WrapperContact wpContact : this.WpContacts) {
				mapBodyParams.put('{!ContactName}', wpContact.contact.Name);
				if (wpContact.contact.Compte_MyAccount_cree__c == false) {
					mapBodyParams.put('{!CodeMyAccount}', wpContact.contact.Code_MyAccount__c);
					if (this.isFR) {
						mapBodyParams.put('{!MyAccountDescription}', textesEmailByCode.get('FRNCD').Texte__c);
						mapBodyParams.put('{!MyAccountButton}', textesEmailByCode.get('FRNCB').Texte__c);
						mapBodyParams.put('{!MyAccountButtonLink}', textesEmailByCode.get('FRNCL').Texte__c);
					} else {
						mapBodyParams.put('{!MyAccountDescription}', textesEmailByCode.get('ENNCD').Texte__c);
						mapBodyParams.put('{!MyAccountButton}', textesEmailByCode.get('ENNCB').Texte__c);
						mapBodyParams.put('{!MyAccountButtonLink}', textesEmailByCode.get('ENNCL').Texte__c);
					}
				} else {
					mapBodyParams.put('{!CodeMyAccount}', '');
					if (this.isFR) {
						mapBodyParams.put('{!MyAccountDescription}', textesEmailByCode.get('FRCD').Texte__c);
						mapBodyParams.put('{!MyAccountButton}', textesEmailByCode.get('FRCB').Texte__c);
						mapBodyParams.put('{!MyAccountButtonLink}', textesEmailByCode.get('FRCL').Texte__c);
					} else {
						mapBodyParams.put('{!MyAccountDescription}', textesEmailByCode.get('ENCD').Texte__c);
						mapBodyParams.put('{!MyAccountButton}', textesEmailByCode.get('ENCB').Texte__c);
						mapBodyParams.put('{!MyAccountButtonLink}', textesEmailByCode.get('ENCL').Texte__c);
					}
				}
				listEmailMessageWrapper.add(new EmailMessageWrapper('sales@xlstat.com', wpContact.ContactEmail, null, 'sales@xlstat.com', this.subject, mapSubjectParams, null, mapBodyParams));
			}
			List<Messaging.SendEmailResult> results = this.utilityClass.sendEmail(listEmailMessageWrapper);
			for (Integer i = 0; i<results.size(); i++) {
				Messaging.SendEmailResult result = results[i];
				if (!result.isSuccess()) { this.EmailSent = false; }
				else {
					Email__c email = new Email__c();
					email.Address__c = this.WpContacts[i].ContactEmail;
					email.Contact__c = this.WpContacts[i].contact.Id;
					email.Nalpeiron_Key__c = this.LicenceKey;
					email.Order__c = this.OrderId;
					email.Type__c = 'Creation';
					email.Subject__c = this.subject;
					emailsToInsert.add(email);
				}
			}
			insert emailsToInsert;
		} else { this.EmailSent = false; }
		if (this.EmailSent) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Email envoyé.'));
			this.HasPreview = false;
			// Recuperation du nom du compte pour comparer avec Mindware ou StatCon
			Account orderAccount = null;
			List<Account> accs = [SELECT Name FROM Account WHERE Id = :this.order.AccountId];
			if (!accs.isEmpty()) { orderAccount = accs[0]; }
			if (orderAccount != null
					&& (orderAccount.Name == STATCON_ACCOUNT_NAME || this.order.AccountId == STATCON_ACCOUNT_ID || this.order.AccountId == STATCON_SH_ACCOUNT_ID || this.order.AccountId == MINDWARE_SH_ACCOUNT_ID || this.order.AccountId == MINDWARE_SH_ACCOUNT_ID)
					&& this.order.Provenance__c == 'ShareIt') {
				Contact contactStatcon = [SELECT Id, Email FROM Contact WHERE AccountId = :this.order.AccountId LIMIT 1];
				List<EmailMessageWrapper> listEmailMessageStatconWrapper = new List<EmailMessageWrapper> ();
				for (WrapperContact wpContact : this.WpContacts) {
					Map<String, String> mapSubjectParams = new Map<String, String> {};
					Map<String, String> mapBodyParams = new Map<String, String> {
							'{!LicenceKey}' => this.LicenceKey,
							'{!LicenceModules}' => this.LicenceModules,
							'{!LicenceNbUsers}' => this.LicenceNbUsers,
							'{!LicenceType}' => this.LicenceType,
							'{!ContactName}' => wpContact.contact.Name,
							'{!AccountName}' => wpContact.account.Name,
							'{!ContactEmail}' => wpContact.ContactEmail,
							'{!HTAmount}' => this.HTAmount,
							'{!ShareItFee}' => this.ShareItFee,
							'{!AmountStatcon}' => this.AmountStatcon,
							'{!ResellerName}' => this.order.AccountId == STATCON_ACCOUNT_ID || this.order.AccountId == STATCON_SH_ACCOUNT_ID ? 'Statcon' : 'Mindware'
					};
					listEmailMessageStatconWrapper.add(new EmailMessageWrapper('sales@xlstat.com', contactStatcon.Email, null, 'sales@xlstat.com', this.subject, mapSubjectParams, null, mapBodyParams));
					String templateName = wpContact.account.IsPersonAccount ? STATCON_EMAIL_TEMPLATE_PERSON_ACCOUNT : STATCON_EMAIL_TEMPLATE;
					this.utilityClass = new UtilityClassV2(listEmailMessageStatconWrapper, templateName, order.Id);
				}
				List<Email__c> emailsToInsert = new List<Email__c> ();
				List<Messaging.SendEmailResult> results = this.utilityClass.sendEmail(null);
				for (Integer i = 0; i<results.size(); i++) {
					Messaging.SendEmailResult result = results[i];
					if (!result.isSuccess()) { this.EmailSent = false; }
					else {
						Email__c email = new Email__c();
						email.Address__c = contactStatcon.Email;
						email.Contact__c = contactStatcon.Id;
						email.Nalpeiron_Key__c = this.LicenceKey;
						email.Order__c = this.OrderId;
						email.Type__c = this.order.AccountId == STATCON_ACCOUNT_ID || this.order.AccountId == STATCON_SH_ACCOUNT_ID ? 'Statcon Creation' : 'Mindware Creation';
						email.Subject__c = this.subject;
						emailsToInsert.add(email);
					}
				}
				insert emailsToInsert;
			}
			PageReference pr = new PageReference('/' + this.OrderId);
			pr.setRedirect(true);
			return pr;
		} else { ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The email could not be sent. Please, contact your awesome collaborator Martin LEZER.')); }
		return null;
	}

	private PageReference sendGeneric() {
		Boolean sendStatus = new SendFlexeraKeyEmailGenericProduct(false, this.key, this.order).Send();
		if (sendStatus) {
			PageReference pr = new PageReference('/' + this.OrderId);
			pr.setRedirect(true);
			return pr;
		}
		return null;
	}

	public PageReference Send() {
		this.EmailSent = true;
		String solution = this.key.XLSTAT_Solution__c;
		if (solution == null) { solution = this.key.Software__c; }
		return solution.toLowerCase().contains('xlstat') ? sendXLStat() : sendGeneric();
	}

	public class WrapperContact {
		public Contact contact { get; set; }
		public String ContactEmail { get; set; }
		public Account account { get; set; }
		public String clientFinal { get; set; }
		public Boolean ShowAccountContacts { get; set; }
		public List<SelectOption> ContactsAccountEmails {
			get {
				List<SelectOption> options = new List<SelectOption> ();
				if (this.clientFinal == null) {
					options.add(new SelectOption(this.contact.Email, this.contact.Email));
					if (this.contact.Second_mail__c != null) { options.add(new SelectOption(this.contact.Second_mail__c, this.contact.Second_mail__c)); }
				}
				if (this.ShowAccountContacts) {
					for (Contact c : this.contactsAccount) {
						if (c.Id != this.contact.Id && c.Email != null) { options.add(new SelectOption(c.Email, c.Email)); }
					}
				}
				if (this.clientFinal != null) {
					options.add(new SelectOption(this.contact.Email, this.contact.Email));
					if (this.contact.Second_mail__c != null) { options.add(new SelectOption(this.contact.Second_mail__c, this.contact.Second_mail__c)); }
				}
				return options;
			}
		}
		public List<Contact> contactsAccount { get; set; }
	}
}