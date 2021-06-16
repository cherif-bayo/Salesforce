global class InsertPayoutsSchedulableClass implements Schedulable {

	global void execute(SchedulableContext sc) {
		managePayouts();
	}

	@future(callout = true)
	public static void managePayouts() {
		PayoutsListResponse payoutsResponse = StripeReportFacade.getPayoutSince(Date.today().addYears(- 1)); // Valeur arbitraire :-(

		List<stripe_payouts__c> existingPayouts = [select id__c from stripe_payouts__c];
		List<String> ids = new List<String> ();
		for (stripe_payouts__c p : existingPayouts) ids.add(p.id__c);

		List<stripe_payouts__c> payouts = new List<stripe_payouts__c> ();
		for (PayoutsListResponse.cls_data p : payoutsResponse.data) if (!ids.contains(p.id)) {
			stripe_payouts__c payout = new stripe_payouts__c();
			payout.Amount__c = p.amount/100;
			payout.Created_UTC__c = DateTime.newInstance(p.created*1000);
			payout.Currency__c = p.currency_x;
			payout.Description__c = p.description;
			payout.Destination__c = p.destination;
			payout.id__c = p.id;
			payout.Livemode__c = p.livemode;
			payout.Method__c = p.method;
			payout.Type__c = p.type;
			payout.Status__c = p.status;
			payout.Source_Type__c = p.source_type;
			payout.Arrival_Date_UTC__c = DateTime.newInstance(p.arrival_date*1000);
			payout.Balance_Transaction__c = p.balance_transaction;

			payouts.add(payout);
		}

		insert payouts;
	}
}