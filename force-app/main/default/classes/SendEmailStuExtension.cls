public class SendEmailStuExtension {
	private final Order order;
	private static String PREFIX_CLE_3J_TEMPLATE_NAME = 'CLE3J_';
	private static String USER_DOMAIN_STUDENT = 'Student';
	private static String USER_DOMAIN_ACADEMIC = 'Academic';
	private static String START_TEMPLATE_NAME = 'Mail Preuve STU ';
	private static String START_TEMPLATE_NAME_ACADEMIC = 'Mail Preuve EDU ';
	private static String IS_EU_TEMPLATE_NAME = 'Europe ';
	private static String IS_NOT_EU_TEMPLATE_NAME = 'Hors Europe ';
	private static String EMAIL_TEMPLATE_FR_SUBJECT = 'XLSTAT - Preuve de statut étudiant';
	private static String EMAIL_TEMPLATE_US_SUBJECT = 'XLSTAT - Proof of studentship';
	private static String EMAIL_TEMPLATE_FR_SUBJECT_ACADEMIC = 'XLSTAT - Preuve de statut éducation';
	private static String EMAIL_TEMPLATE_US_SUBJECT_ACADEMIC = 'XLSTAT - Proof of academic status';
	private Set<String> UECountryCodes = new Set<String> {
		'AL', 'AD', 'AM', 'AT', 'BY', 'BE', 'BA', 'BG', 'CH', 'CY', 'CZ', 'DE',
		'DK', 'EE', 'ES', 'FO', 'FI', 'FR', 'GB', 'GE', 'GI', 'GR', 'HU', 'HR',
		'IE', 'IS', 'IT', 'LT', 'LU', 'LV', 'MC', 'MK', 'MT', 'NO', 'NL', 'PL',
		'PT', 'RO', 'RU', 'SE', 'SI', 'SK', 'SM', 'TR', 'UA', 'VA', 'MQ', 'GP',
		'RE'
	};

	public Boolean EmailSent { get; set; }
	public Boolean Status { get; set; }
	public String  Free3DaysKey { get; set; }

	// The extension constructor initializes the private member
	// variable acct by using the getRecord method from the standard
	// controller.
	public SendEmailStuExtension(ApexPages.StandardController stdController) {
		this.order = (Order) stdController.getRecord();
		this.EmailSent = false;
		this.Status = true;
	}

	public PageReference SendEmail() {
		System.debug('>>>> SendEmailStuExtendion - SendEmail - ENTER ');
		Order o = [SELECT Id, Domaine_utilisateur__c, Status FROM Order WHERE Id = :this.order.Id LIMIT 1];
		System.debug('>>>> SendEmailStuExtendion - SendEmail - Order o =  '+o);

		if (o.Domaine_utilisateur__c == USER_DOMAIN_STUDENT || o.Domaine_utilisateur__c == USER_DOMAIN_ACADEMIC) {

			Flexera_Key__c[] flexeraKeys = [SELECT Software__c, SoftwareCode__c, XLSTAT_Solution__c, Domaine_utilisateur__c, Name, Contact__c, Contact__r.Name, Contact__r.Email, Contact__r.Langue__c, Contact__r.MailingCountryCode, Order__c FROM Flexera_Key__c WHERE Order__c = :o.Id];
			Map<String, Flexera_Key__c> flexeraKeyByContactEmail = new Map<String, Flexera_Key__c> ();
			List<String> contactsIds = new List<String> ();
			for (Flexera_Key__c flexeraKey : flexeraKeys) {
				contactsIds.add(flexeraKey.Contact__c);
				flexeraKeyByContactEmail.put(flexeraKey.Contact__r.Email, flexeraKey);
			}
			System.debug('>>>> SendEmailStuExtendion - SendEmail - flexeraKeys =  '+flexeraKeys);
			Account[] accounts = [SELECT PersonContactId, Domaine_utilisateur__c, BillingCountryCode FROM Account WHERE PersonContactId IN :contactsIds];
			Map<String, Account> accountByContactId = new Map<String, Account> ();
			for (Account account : accounts) {
				accountByContactId.put(account.PersonContactId, account);
			}

			if (flexeraKeys.size() > 0) {
				List<Email__c> emailsToInsert = new List<Email__c> ();
				for (Flexera_Key__c flexeraKey : flexeraKeyByContactEmail.values()) {
					List<EmailMessageWrapper> listEmailMessageWrapper = new List<EmailMessageWrapper> ();
					Boolean isStudentDomain = flexeraKey.Domaine_utilisateur__c == USER_DOMAIN_STUDENT;
					Boolean isAcademicDomain = flexeraKey.Domaine_utilisateur__c == USER_DOMAIN_ACADEMIC;

					if (isStudentDomain || isAcademicDomain) {
						String subject = flexeraKey.Contact__r.Langue__c == 'FR' ? EMAIL_TEMPLATE_FR_SUBJECT : EMAIL_TEMPLATE_US_SUBJECT;
						if (isAcademicDomain) {
							subject = flexeraKey.Contact__r.Langue__c == 'FR' ? EMAIL_TEMPLATE_FR_SUBJECT_ACADEMIC : EMAIL_TEMPLATE_US_SUBJECT_ACADEMIC;
						}
						if (!flexeraKey.XLSTAT_Solution__c.toLowerCase().contains('xlstat')) {
							subject = subject.replace('XLSTAT', flexeraKey.XLSTAT_Solution__c);
						}
						System.debug('>>>> SendEmailtStuExtension - SendEmail - subject = '+subject);
						Map<String, String> mapSubjectParams = new Map<String, String> { };

						Map<String, String> mapBodyParams = new Map<String, String> {
							'{!ContactName}' => flexeraKey.Contact__r.Name
						};

						if (Free3DaysKey != null) mapBodyParams.put('{!Free3DaysKey}',Free3DaysKey);

						listEmailMessageWrapper.add(new EmailMessageWrapper('sales@xlstat.com', flexeraKey.Contact__r.Email, null, null, subject, mapSubjectParams, null, mapBodyParams));

						String templateName = '';
						if ('1'.equals(Parameters.getString('Cle_Temporaire_Etudiant'))) templateName += PREFIX_CLE_3J_TEMPLATE_NAME;
						templateName += isStudentDomain ? START_TEMPLATE_NAME : START_TEMPLATE_NAME_ACADEMIC;
						String countryCode = accountByContactId.get(flexeraKey.Contact__c) != null ? accountByContactId.get(flexeraKey.Contact__c).BillingCountryCode : flexeraKey.Contact__r.MailingCountryCode;
						templateName += UECountryCodes.contains(countryCode) ? IS_EU_TEMPLATE_NAME : IS_NOT_EU_TEMPLATE_NAME;
						templateName += flexeraKey.Contact__r.Langue__c == 'FR' ? 'FR' : 'US';
						// gestion multiproduits
						/*System.debug('>>>> SendEmailtStuExtension - SendEmail - flexeraKey = '+flexeraKey);
						System.debug('>>>> SendEmailtStuExtension - SendEmail - flexeraKey.Contact__r.Name = '+flexeraKey.Contact__r.Name);
						System.debug('>>>> SendEmailtStuExtension - SendEmail - flexeraKey.Contact__r.Langue__c = '+flexeraKey.Contact__r.Langue__c);
						if (!flexeraKey.XLSTAT_Solution__c.toLowerCase().contains('xlstat')) {
							String solution = flexeraKey.XLSTAT_Solution__c.toUpperCase();
							String domain = isStudentDomain ? 'STU' : 'EDU';
							templateName = flexeraKey.Contact__r.Langue__c == 'FR' ? 'Mail Preuve '+domain+' '+solution+' Europe FR' : 'Mail Preuve '+domain+' '+solution+' Europe US';
						} */
						System.debug('>>>> SendEmailtStuExtension - SendEmail - templateName = '+templateName);
						UtilityClassV2 utilityClass = new UtilityClassV2(listEmailMessageWrapper, templateName, flexeraKey.Order__c);
						List<Messaging.SendEmailResult> results = utilityClass.sendEmail(listEmailMessageWrapper);
						this.EmailSent = true;
						for (Integer i = 0; i<results.size(); i++) {
							Messaging.SendEmailResult result = results[i];
							if (!result.isSuccess()) {
								this.EmailSent = false;
								this.Status = false;
							} else {
								Email__c email = new Email__c();
								email.Address__c = flexeraKey.Contact__r.Email;
								email.Contact__c = flexeraKey.Contact__c;
								email.Nalpeiron_Key__c = flexeraKey.Name;
								email.Order__c = o.Id;
								email.Type__c = isStudentDomain ? 'Preuve STU' : 'Preuve EDU';
								email.Subject__c = subject;
								emailsToInsert.add(email);
							}
						}
					}
				}
				System.debug('>>>> SendEmailtStuExtension - SendEmail - emailsToInsert = '+emailsToInsert);
				insert emailsToInsert;

				if (ApexPages.currentPage() != null) {
					if (this.EmailSent == true) {
						PageReference pageRef = new PageReference('/' + o.Id);
						pageRef.setRedirect(true);
						return pageRef;
					}
				} else {
					if (ApexPages.currentPage() != null) {
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Problème d\'envoie du mail de vérification STU/EDU.'));
					}
				}
			} else {
				if (ApexPages.currentPage() != null) {
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Aucun étudiant ou académie lié à la clef.'));
				}
			}
		} else {
			if (ApexPages.currentPage() != null) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Attention ! La commande n\'est pas une commande étudiante ou académique.'));
			}
		}

		return null;
	}
}