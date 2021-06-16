public class Btn_CreateTaxamoTransationExtension  {

	public Order order { get; set; }

	public Btn_CreateTaxamoTransationExtension (ApexPages.StandardController stdController) {
		order = [SELECT AddinSoftCompany__c FROM Order WHERE Id = :stdController.getId()];
	}

	public PageReference createTransactionTaxamo() {

		System.debug('[Btn_CreateTaxamoTransationExtension] createTransactionTaxamo, order = ' + order);
		try {
			if (ParametersForOrders.US_COMPANY.equals(order.AddinSoftCompany__c)) System.enqueueJob(new OrderLineItemTaxes(order.Id,true));

			PageReference pageRef = new PageReference('/' + order.Id);
			pageRef.setRedirect(true);

			return pageRef;
		} catch(CryptlexException ce) { ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'La date d\'expiration de la clé n\'a pas été modifiée dans cryptlex')); }

		return null;
	}
}