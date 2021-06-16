public class PayoutConciliationExtension {

	public stripe_payouts__c payout;

	public PayoutConciliationExtension(ApexPages.StandardController stdController) {
		payout = (stripe_payouts__c) stdController.getRecord();
	}

	public void conciliate() {		
		ManageReconciliation.completeWithQuotesAndOrders(payout);
	}
}