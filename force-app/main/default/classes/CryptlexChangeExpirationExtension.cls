public class CryptlexChangeExpirationExtension {
	public Flexera_Key__c key { get; set; }
	public Date dateLimitCryptlex;

	public CryptlexChangeExpirationExtension(ApexPages.StandardController stdController) {
		key = [SELECT Entitlement_Id__c, Date_limite__c, Type_licence__c FROM Flexera_Key__c WHERE Id = :stdController.getId()];
		dateLimitCryptlex = Key.Date_limite__c;
	}

	public PageReference save() {
		Integer nbDays = 0;
		if (dateLimitCryptlex == null) { // gestion du cas des trial qui n'ont pas de date limite à la création :-(
			LicenseKey keyCryptlex = CryptlexFacade.GetInformations(key.Entitlement_Id__c);
			nbDays = keyCryptlex.ExpirationDate.daysBetween(Key.Date_limite__c);
		} else {
			nbDays = dateLimitCryptlex.daysBetween(Key.Date_limite__c);
		}

		System.debug('[CryptlexChangeExpirationExtension] save, nbDays = ' + nbDays);
		try {
			if (FlexeraController.LICENSETYPE_PERPETUAL.equalsIgnoreCase(Key.Type_licence__c)) CryptlexFacade.extendingPerpetualKey(Key.Entitlement_Id__c, nbDays);
			else CryptlexFacade.extendingKey(Key.Entitlement_Id__c, nbDays);
			update Key;
			PageReference pageRef = new PageReference('/' + key.Id);
			pageRef.setRedirect(true);

			return pageRef;
		} catch(CryptlexException ce) { ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'La date d\'expiration de la clé n\'a pas été modifiée dans cryptlex')); }

		return null;
	}
}