public class ListFlexeraSendKeyByEmail {
	public ApexPages.StandardSetController controller;

	public ListFlexeraSendKeyByEmail(ApexPages.StandardSetController controller) {
		this.controller = controller;
	}

	public pageReference callFlexeraSendKeyByEmail() {
		PageReference pg = null;

		if (controller.getSelected().size() > 0) {
			String selectedKeys = '';
			List<sObject> selectedObjects = controller.getSelected();
			for (SObject so : selectedObjects) {
				Flexera_Key__c key = (Flexera_Key__c) so;
				selectedKeys += key.Id + '-';
			}
			selectedKeys = selectedKeys.removeEnd('-');
			return new PageReference('/apex/FlexeraSendKeyByEmail?keys_id=' + selectedKeys + '&is_update=false');
		} else {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'vous devez cocher au moins une clé'));
		}

		return pg;
	}

	public pageReference cancel() {
		PageReference pg = new PageReference(controller.cancel().getUrl());
		pg.setRedirect(true);

		return pg;
	}
}