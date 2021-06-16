public class CL001_SendKeyByEmail {
	private static String COUNTRY_FRANCE = 'FR';
	private static String LANGUAGE_FRANCE = 'FR';
	private static String LANGUAGE_OTHER = 'EN';
	private static String TEMPLATE_NAME_START = 'Licence key';

	private Order order;
	private List<Flexera_Key__c> keys;

	public CL001_SendKeyByEmail(String OrderId) {

		order = [select Client_Final__c, AccountId, R_f_Bon_de_commande__c, Provenance__c, Type_Licence__c, TotalAmountAfterDiscountShowed__c, Frais_ShareIt__c, Amount_Statcon__c from Order where Id = :OrderId limit 1];
		keys = [SELECT Name, Type_Licence__c, Quantity__c, Has_Student_Ext__c, Contact__c, Order__c, Modules__c FROM Flexera_Key__c WHERE Order__c = :OrderId];
	}

	public void SendEmails() {

		System.debug('[CL001_SendKeyByEmail] keys :' + keys);
		for (Flexera_Key__c key : keys) {
			sendEmail(key);
		}
	}

	private void sendEmail(Flexera_Key__c key) {

		// Recuperation du contact de la cle
		Contact contact = [select Name, Email, Langue__c, Compte_MyAccount_cree__c, Code_MyAccount__c from Contact where Id = :key.Contact__c];

		// Choix de la langue
		boolean isFR = contact.Langue__c == COUNTRY_FRANCE;

		// Calcul du nom du template
		String templateName = TEMPLATE_NAME_START + ' ' + 'Update' + ' ';
		templateName += isFR ? LANGUAGE_FRANCE : LANGUAGE_OTHER;

		// Chargement des textes d'email
		Map<String, Texte_Email__c> textesEmailByCode = new Map<String, Texte_Email__c> ();
		List<Texte_Email__c> texts = [SELECT Code__c, Texte__c FROM Texte_Email__c];
		for (Texte_Email__c text : texts) textesEmailByCode.put(text.Code__c, text);

		// Contenu dynamique de l'email
		Map<String, String> mapBodyParams = new Map<String, String> ();
		mapBodyParams = new Map<String, String> {
			'{!ContactName}' => contact.Name,
			'{!LicenceKey}' => key.Name,
			'{!LicenceModules}' => key.Modules__c,
			'{!LicenceNbUsers}' => getNbUsersForKey(key, isFR),
			'{!LicenceType}' => key.Type_Licence__c
		};
		if (contact.Compte_MyAccount_cree__c == false) {
			mapBodyParams.put('{!CodeMyAccount}', contact.Code_MyAccount__c);
			if (IsFr) {
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
			if (IsFr) {
				mapBodyParams.put('{!MyAccountDescription}', textesEmailByCode.get('FRCD').Texte__c);
				mapBodyParams.put('{!MyAccountButton}', textesEmailByCode.get('FRCB').Texte__c);
				mapBodyParams.put('{!MyAccountButtonLink}', textesEmailByCode.get('FRCL').Texte__c);
			} else {
				mapBodyParams.put('{!MyAccountDescription}', textesEmailByCode.get('ENCD').Texte__c);
				mapBodyParams.put('{!MyAccountButton}', textesEmailByCode.get('ENCB').Texte__c);
				mapBodyParams.put('{!MyAccountButtonLink}', textesEmailByCode.get('ENCL').Texte__c);
			}
		}

		// Envoi des emails et creation des objets emails dans SF
		List<EmailMessageWrapper> listEmailMessageWrapper = new List<EmailMessageWrapper> ();
		listEmailMessageWrapper.add(new EmailMessageWrapper('sales@xlstat.com', null, contact.Id,'sales@xlstat.com', isFR ? 'Licence XLSTAT' : 'XLSTAT License', new Map<String, String> (), null, mapBodyParams));
		UtilityClass utilityClass = new UtilityClass(listEmailMessageWrapper, templateName);
		List<Messaging.SendEmailResult> results = utilityClass.sendEmail(listEmailMessageWrapper);
		System.debug('[CL001_SendKeyByEmail] results :' + results);
	}

	/**
	 * @description retourne une chaine de caracteres avec le nombre de licences associé à une clé en fonction de son type
	 * @param key clé concernée
	 * @param isFr langue du contact principal de la clé
	 * @return 
	 */
	private String getNbUsersForKey(Flexera_key__c key, boolean isFr) {
		String LicenceNbUsers;

		if (key.Type_Licence__c == 'Large Campus') {
			if (isFr) {
				if (key.Has_Student_Ext__c) LicenceNbUsers = 'Campus, extension étudiante';
				else LicenceNbUsers = 'Campus, illimitée';
			} else {
				if (key.Has_Student_Ext__c) LicenceNbUsers = 'Campus, student extension';
				else LicenceNbUsers = 'Campus, unlimited';
			}
		} else if (Key.Type_Licence__c == 'Small Campus') {
			if (isFr) {
				if (key.Has_Student_Ext__c) LicenceNbUsers = 'Campus, extension étudiante';
				else LicenceNbUsers = 'Campus, jusqu\'à 500 utilisateurs';

			} else {
				if (key.Has_Student_Ext__c) LicenceNbUsers = 'Campus, student extension';
				else LicenceNbUsers = 'Campus, up to 500';

			}
		} else if (Key.Type_Licence__c == 'Classroom') {
			if (isFr) {
				if (key.Has_Student_Ext__c) LicenceNbUsers = 'Campus, extension étudiante';
				else LicenceNbUsers = 'Campus, jusqu\'à 60 utilisateurs';
			} else {
				if (key.Has_Student_Ext__c) LicenceNbUsers = 'Campus, student extension';
				else LicenceNbUsers = 'Campus, up to 60';
			}
		} else {
			LicenceNbUsers = String.valueof(key.Quantity__c);
		}

		return LicenceNbUsers;
	}
}