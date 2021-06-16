public class ManageReconciliation {

	public static void completeWithQuotesAndOrders(stripe_payouts__c payout) {

		List<StripeReconciliation__c> conciliations = [select charge_Id__c,reporting_category__c,Order__c,customer_email__c from StripeReconciliation__c where Stripe_Payouts__r.Id = :payout.Id];

		// Mapping upon charge_id for payment intents associated to Orders
		Map<String, StripeReconciliation__c> reconciliationByChargeIds = new Map<String, StripeReconciliation__c> ();
		for (StripeReconciliation__c c : conciliations) if (c.reporting_category__c.equals('charge')) reconciliationByChargeIds.put(c.charge_Id__c, c);

		// Populate Order Lookup on Stripe Reconciliation			
		List<Order> orders = [Select chargeToken__c from Order where chargeToken__c in :reconciliationByChargeIds.keySet()];
		for (Order o : orders) {
			reconciliationByChargeIds.get(o.chargeToken__c).Order__c = o.Id;
		}
        
		// Mapping upon email for payment intents associated to Quotes (payment links) And Populate Quote Lookup
		Map<String, StripeReconciliation__c> reconciliationsByEmail = new Map<String, StripeReconciliation__c> ();
		for (StripeReconciliation__c c : conciliations) if (c.reporting_category__c.equals('charge') && c.Order__c == null) 
            reconciliationsByEmail.put(c.customer_email__c, c);		
		List<Quote> quotes = [Select Opportunity.Contact_Email__c from Quote where Opportunity.Contact_Email__c in :reconciliationsByEmail.keySet()];
		for (Quote q : quotes) {
			reconciliationsByEmail.get(q.Opportunity.Contact_Email__c).Quote__c = q.Id;
		}
 
		// Mapping upon email for credit notes and Populate Avoir field
		Map<String, StripeReconciliation__c> reconciliationByEmail = new Map<String, StripeReconciliation__c> ();
		for (StripeReconciliation__c c :conciliations) if (c.reporting_category__c.equals('refund')) reconciliationByEmail.put(c.customer_email__c, c);	
		List<Avoir__c> avoirs = [Select Name,Commande_lie__r.Contact_Email__c from Avoir__c where Commande_lie__r.Contact_Email__c in :reconciliationByEmail.keySet()];
		for (Avoir__c av : avoirs) {
			reconciliationByEmail.get(av.Commande_lie__r.Contact_Email__c).avoir__c = av.Name;
            reconciliationByEmail.get(av.Commande_lie__r.Contact_Email__c).Order__c = av.Commande_lie__c;
		}

		update conciliations;
	}
}