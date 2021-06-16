@isTest 
private class Test_ManageCheckoutItemizedStripeReport {

	@isTest
	private static void testConciliation() {
        Stripe_Payouts__c p = new Stripe_Payouts__c();
        insert p;
        
		String reconciliations = '"customer_id","customer_email","charge_created_utc","balance_transaction_id","created_utc","currency","gross","fee","net","reporting_category","source_id","description","customer_facing_amount","customer_facing_currency","charge_id"\n';
		reconciliations += '"cus_GoEa87cNpBpx92","kfakhruddin@sharjah.ac.ae","2020-02-27 02:29:43","txn_1GGc8DDlc4BISCKmDKyWOeAT","2020-02-27 02:29:43","eur","444.75","11.37","433.38","charge","ch_1GGc8BDlc4BISCKm5QfeZdjO",,"495.00","usd","ch_1GGc8BDlc4BISCKm5QfeZdjO"';
		ManageCheckoutItemizedStripeReport.createConciliations(p.id,reconciliations);
	}
}