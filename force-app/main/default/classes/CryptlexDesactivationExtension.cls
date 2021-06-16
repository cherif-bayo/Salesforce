public class CryptlexDesactivationExtension  {
	public Flexera_Key__c Key { get; set; }

	public CryptlexDesactivationExtension(ApexPages.StandardController stdController) {
		key = [SELECT Entitlement_Id__c  FROM Flexera_Key__c WHERE Id = :stdController.getId()];
	}

	public PageReference desactivate() {
		try {
			CryptlexFacade.setSuspendStateKey(key.Entitlement_Id__c,true);
			key.Is_Inactive__c = true;
			update Key;
			PageReference pageRef = new PageReference('/' + key.Id);
			pageRef.setRedirect(true);

			return pageRef;
		} catch(CryptlexException ce) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'La clé n\'a pas été suspendue dans cryptlex'));
		}

		return null;
	}
}