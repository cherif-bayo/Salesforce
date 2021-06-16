public class CryptlexRevokeExtension {
	public Flexera_Key__c Key { get; set; }

	public CryptlexRevokeExtension (ApexPages.StandardController stdController) {
		key = [SELECT Entitlement_Id__c FROM Flexera_Key__c WHERE Id = :stdController.getId()];
	}

	public PageReference revoke() {
		PageReference pageRef;

		try {
			CryptlexFacade.revokeKey(key.Entitlement_Id__c);
			key.Is_Inactive__c = true;
			update Key;
			pageRef = new PageReference('/' + key.Id);
			pageRef.setRedirect(true);
		} catch(CryptlexException ce) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'La clé n\'a pas été annulée dans cryptlex'));
		}

		return pageRef;
	}
}