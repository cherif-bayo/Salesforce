public class CryptlexActivationExtension  {
		public Flexera_Key__c Key { get; set; }

	public CryptlexActivationExtension(ApexPages.StandardController stdController) {
		key = [SELECT Entitlement_Id__c  FROM Flexera_Key__c WHERE Id = :stdController.getId()];
	}

	public PageReference activate() {
		try {
			CryptlexFacade.setSuspendStateKey(key.Entitlement_Id__c,false);
			key.Is_Inactive__c = false;
			update Key;
			PageReference pageRef = new PageReference('/' + key.Id);
			pageRef.setRedirect(true);

			return pageRef;
		} catch(CryptlexException ce) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'La clé n\'a pas été activée dans cryptlex'));
		}

		return null;
	}
}