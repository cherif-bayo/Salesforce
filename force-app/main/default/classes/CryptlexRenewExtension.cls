public class CryptlexRenewExtension {
	public Flexera_Key__c Key { get; set; }

	public CryptlexRenewExtension(ApexPages.StandardController stdController) {
		key = [SELECT Entitlement_Id__c, Date_limite__c, Type_licence__c FROM Flexera_Key__c WHERE Id = :stdController.getId()];
	}

	public PageReference renew() {
		PageReference pageRef;

		try {
			if (FlexeraController.LICENSETYPE_PERPETUAL.equals(key.Type_licence__c)) {
				CryptlexFacade.renewingPerpetualKey(key.Entitlement_Id__c);
			} else {
				CryptlexFacade.renewingAnnualKey(key.Entitlement_Id__c);
			}
			key.Date_limite__c = key.Date_limite__c.addYears(1);
			update Key;
			pageRef = new PageReference('/' + key.Id);
			pageRef.setRedirect(true);
		} catch(CryptlexException ce) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'La clé n\'a pas été renouvelée dans cryptlex'));
		}

		return pageRef;
	}
}