global class GenerateReportStripePayoutSchedulable implements Schedulable {

	global void execute(SchedulableContext sc) {
		generateReportStripePayout();
	}

	@future(callout = true)
	public static void generateReportStripePayout() {
		List<stripe_payouts__c> payouts = [select id__c from stripe_payouts__c where report_run__c =null];
		for (stripe_payouts__c payout :payouts) payout.report_run__c = StripeReportFacade.generateReportPayout(payout.id__c);
		update payouts;
	}
}