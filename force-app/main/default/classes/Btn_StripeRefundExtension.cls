public class Btn_StripeRefundExtension {
private static Order order;
	private static String REASON = 'requested_by_customer';
	private static final String JPYCurrencyIsoCode = 'JPY';

	public Btn_StripeRefundExtension(ApexPages.StandardController stdController) {
		order = [SELECT TotalAmountAfterDiscount__c,PaymentToken__c,CurrencyIsoCode FROM Order WHERE Id = :stdController.getId()];
	}

	public PageReference refund() {

		System.debug('[Btn_StripeRefundExtension] refund, order = ' + order);
		try {
			StripeFacade.Refund params = new StripeFacade.Refund();
			params.payment_intent = order.PaymentToken__c;
			params.reason = REASON;
			System.debug('[Btn_StripeRefundExtension] params = ' + params);

			StripeFacade.refundCommand(params);

			PageReference pageRef = new PageReference('/' + order.Id);
			pageRef.setRedirect(true);

			return pageRef;
		} catch(StripeException ce) { ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Remboursement non effectué :' + ce.getMessage())); }

		return null;
	}
}