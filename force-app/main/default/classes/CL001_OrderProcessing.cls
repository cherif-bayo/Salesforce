public without sharing class CL001_OrderProcessing {

	public static Integer CODE_OK = 0;
	public static Integer CODE_ERREUR_ORDER_SENDING_KEY = 1;
	public static Integer CODE_ERREUR_ORDER_GENERATING_KEY = 2;

	private static Order order;
	private static Contact contactLie;
	private static Boolean isCommandeDistributeur;
	private static List<WS_Error__c> errors = new List<WS_Error__c> ();


	public static void generateLicenceAndSendEmailToCustomerWithKey(String orderNumber, String customerToken, String PaymentToken, String chargeToken, String paymentMethod) {
		List<String> StatusOrder = System.Label.StatusCustomPayment.split(';');
        List<Order> orders = [
				SELECT Type, CustomOriginalOrder__c, Account.Type, Account.BillingCountryCode, Account.PersonContactId, Domaine_utilisateur__c,
						Status, Type_licence__c, Contact_lie__r.Email, Client_final__r.Email, AccountId, Contact_lie__c,
						Client_final__c, MyAccount_Auto__c, CurrencyIsoCode
				FROM Order WHERE OrderNumber = :orderNumber AND Status IN :StatusOrder
		];

		// Return if the list of orders is empty (or multiple orders)
		if (orders.size() != 1) { return; }

		order = orders[0];
		isCommandeDistributeur = order.Type != null && order.Type.equals('Distributeur');
		boolean isRenewalStripeOrder = order.CustomOriginalOrder__c != null;

		Account account = [
				SELECT IsPersonAccount, Type, FirstName, LastName, PersonEmail, PersonMailingCountryCode, PersonContactId
				FROM Account WHERE Id = :order.AccountId
		];
		if (order.Contact_lie__c != null) {
			contactLie = [
					SELECT FirstName, LastName, Email, MailingCountryCode
					FROM Contact WHERE Id = :order.Contact_lie__c
			];
		}

		// La commande donne-t-elle lieu à la création d'une clé annuelle (sinon clé gratuite 3 jours)
		Boolean hasAnnualKey = hasAnnualKey(account);

		// Generation des licences pour les domaines étudiants, ACAD, company et les licences hors réseau et campus
		List<FlexeraController.ResultGenerateKey> resultsFlexeraGeneratedKey;
		if (isRenewalStripeOrder) {
			CL001_UTL_ExtendingKey.extend(order);
		} else if (isGeneratedKey()) {
			resultsFlexeraGeneratedKey = CL001_UTL_OrderProcessingKeyGeneration.generateKey(order, account, contactLie, hasAnnualKey);
		}

		// Ajout des infos fournies par Stripe sur le paiement
		order.customerToken__c = customerToken;
		order.PaymentToken__c = PaymentToken;
		order.chargeToken__c = chargeToken;
		order.Paymentmethod__c = paymentMethod;
        order.IsFromStripe__c = true;
        order.PayementDateInStripe__c = Date.today();
		update order;

		// Créee le paiement dans salesforce
		createPayment(order);

		// Delai pour les envois d'email avec la clé 3J
		Integer delayForEmailCle3J = Integer.valueOf(Parameters.getString('Delai_pour_envoi_cle_Temporaire_Etudiant'));

		// Pour les clients company et les acad ou student déjà connus on envoie un email avec la clé
		if (hasAnnualKey && !isRenewalStripeOrder) {
			for (FlexeraController.ResultGenerateKey resultFlexeraGeneratedKey : resultsFlexeraGeneratedKey) {
				if (resultFlexeraGeneratedKey.Status) {
					for (Flexera_Key__c flexeraKey : resultFlexeraGeneratedKey.GeneratedKeys) {
						// Préparation de l'envoi de la clé
						System.debug('>>>> #### flexeraKey.SoftwareCode__c = '+flexeraKey.SoftwareCode__c);
						if (new SoftwareService().isSimpleAccess(flexeraKey.SoftwareCode__c)) {
							System.debug('>>>> PROCESSING ORDER OTHER PRODUCT');
							SendFlexeraKeyEmailGenericProduct keySenderForGenericProductFromWS = new SendFlexeraKeyEmailGenericProduct(false, flexeraKey, order);
							Boolean status = keySenderForGenericProductFromWS.Send();
							if (!status) {
								insert new WS_Error__c(WebserviceName__c = 'Email', Request__c = 'Le mail contenant la clé pas été envoyé correctement pour la commande : '+order.OrderNumber);
							}
						} else {
							System.debug('>>>> PROCESSING ORDER XLSTAT');
							FlexeraSendKeyByEmailFromWSController flexeraSendKeyByEmailFromWSController = new FlexeraSendKeyByEmailFromWSController(false); // false = pas de support de perpet
							flexeraSendKeyByEmailFromWSController.FlexeraKeyId = flexeraKey.Id;
							// Cas général d'un distributeur (Mindware et statCon compris) ou d'un revendeur
							if (order.Client_final__c != null) {
								flexeraSendKeyByEmailFromWSController.OtherContactEmail = order.Client_final__r.Email;
							}
							// Cas particulier (de Mindware et Statcon)
							if (isCommandeDistributeur) {
								flexeraSendKeyByEmailFromWSController.ResellerAccountId = order.AccountId;
							}
							Boolean status = flexeraSendKeyByEmailFromWSController.Send();
							if (!status) {
								insert new WS_Error__c(WebserviceName__c = 'Email', Request__c = 'mail avec la clé pas envoyé correctement pour la commande : '+order.OrderNumber);
							}
						}
					}
					// Commande livrée donc validée / payée
					order.Status = 'Payée';
					update order;
				} else {
					errors.add(new WS_Error__c(WebserviceName__c = 'Flexera', Request__c = 'generation de cle Ko pour la commande : ' + order.OrderNumber));
				}
			}
		} else if (isEmailToSendWithConfirmationStatus() && !isRenewalStripeOrder ) { // Dans les autres cas on envoie un email pour demander une confirmation de statut étudiant ou ACAD
			// Envoi de l'email avec la demande de confirmation student
			SCH001_SendEmailConfirmationStudent sendingEmailStudent = new SCH001_SendEmailConfirmationStudent(order, resultsFlexeraGeneratedKey);
			System.schedule('Email confirmation Student for ' + order.Id, SchedulerHelper.getSchedulerForNSecondesFromNow(delayForEmailCle3J), sendingEmailStudent);
			// Commande Stu ou ACAD à valider
			order.Status = 'ShareIt - Envoyer clé Nalpeiron';
			update order;
		}
		// Creation de la facture (envoi différé dans un batch horaire)
		Facture__c facture = HelperFacture.createFactureFromOrder(order);
		insert facture;
	}

	private static void createPayment(Order order) {
		Paiement__c paiement = new Paiement__c();
		paiement.Commande_lie__c = order.Id;
		paiement.CurrencyIsoCode = order.CurrencyIsoCode;
		paiement.Date_de_paiement_effectif__c = Date.today();
		paiement.Modalites_de_paiement__c = '+0j';
		paiement.Type_de_paiement__c = ParametersForOrders.STRIPE_PAYMENT;
		insert paiement;
	}

	private static Boolean isGeneratedKey() {
		System.debug('[CL001_OrderProcessing#isGeneratedKey] order : ' + order);
		return order.Type_licence__c != ParametersForOrders.GENERATE_LICENSE_NO_TYPE_LICENSE_3; // Voir Pourquoi?
	}

	private static Boolean hasAnnualKey(Account account) {
		System.debug('[CL001_OrderProcessing#isEmailToSendWithKey] order : ' + order);
		String email;
		if (account.IsPersonAccount) {
			email = account.PersonEmail;
		} else {
			email = contactLie.Email;
		}
		// Domaine email interdit
		String emailDomain = email.substringAfter('@');
		Domaines_non_autorises__c[] domainsNotAllowed = [SELECT Id FROM Domaines_non_autorises__c WHERE Name = :emailDomain];
		System.debug('[CL001_OrderProcessing#isEmailToSendWithKey] domainsNotAllowed : ' + domainsNotAllowed);
		// Client Academique validé en tant que tel
		Boolean sendKeyAcademic = shouldSendAcademicKey(email);
		System.debug('[CL001_OrderProcessing#isEmailToSendWithKey] sendKeyAcademic : '+sendKeyAcademic);
		Boolean licenseIsType1or2or3 = isLicenseOfType1or2or3();
		Boolean domainsNotAllowedIsEmpty = domainsNotAllowed.size() == 0;
		Boolean domainIsCompanyOrAcademic = isDomainEitherCompanyOrAcademic(sendKeyAcademic);
		return (licenseIsType1or2or3 && domainsNotAllowedIsEmpty && domainIsCompanyOrAcademic);
	}


	private static Boolean shouldSendAcademicKey(String email) {
		return (
				order.Domaine_utilisateur__c == ParametersForOrders.SEND_KEY_USER_DOMAIN_ACADEMIC
						&& CL001_UTL_OrderProcessingAcad.isSendingKeyAuthorized(email, order.AccountId, order.MyAccount_Auto__c)
		);
	}

	private static Boolean isLicenseOfType1or2or3() {
		return (
				order.Type_licence__c == ParametersForOrders.SEND_KEY_LICENSE_TYPE_1
						|| order.Type_licence__c == ParametersForOrders.SEND_KEY_LICENSE_TYPE_2
						|| order.Type_licence__c == ParametersForOrders.SEND_KEY_LICENSE_TYPE_3
		);
	}

	private static Boolean isDomainEitherCompanyOrAcademic(Boolean sendKeyAcademic) {
		return (
				order.Domaine_utilisateur__c == ParametersForOrders.SEND_KEY_USER_DOMAIN_COMPANY
						|| sendKeyAcademic
		);
	}

	private static Boolean isEmailToSendWithConfirmationStatus() {
		System.debug('[CL001_OrderProcessing#isEmailToSendWithConfirmationStatus] order : '+order);
		return (
				order.Type_licence__c == ParametersForOrders.SEND_KEY_LICENSE_TYPE_1 && (
						order.Domaine_utilisateur__c == ParametersForOrders.SEND_KEY_USER_DOMAIN_STUDENT
								|| order.Domaine_utilisateur__c == ParametersForOrders.SEND_KEY_USER_DOMAIN_ACADEMIC)
		);
	}
}