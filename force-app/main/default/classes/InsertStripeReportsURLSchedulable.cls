public class InsertStripeReportsURLSchedulable implements Schedulable  {
	public void execute(SchedulableContext sc) {
		manageReports();
	}

	@future(callout = true)
	public static void manageReports() {
		List<stripe_payouts__c> payouts = [select report_run__c from stripe_payouts__c where URLReport__c=null limit 1];
		for (stripe_payouts__c p :payouts) {
			p.URLReport__c = StripeReportFacade.manageReportPayout(p.report_run__c);
			String CSV = StripeReportFacade.getReport(p.URLReport__c);
			ManageCheckoutItemizedStripeReport.createConciliations(p.Id,CSV);
		}
		update payouts;
	}
}