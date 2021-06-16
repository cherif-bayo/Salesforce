public class HelperCustomer {

	// Les paniers abandonnés doivent contenir Contact_Id__c (+ EffectiveDate) qui permet de chercher les commandes associées
	public static List<Order> checkPayedOrderFromAbandonnedCarts(List<Order> abandonnedCarts) {
		List<Order> abandonnedCartsWithoutPayedOrder = new List<Order> ();

		// Dedoublonnage des paniers abandonnés appartenants à un même contact (on conserve le dernier en date)
		Map<String, Order> lastOrdersByContactIds = new Map<String, Order> ();
		For (Order o : abandonnedCarts) {
			// Creation de la MAP des commandes par contact
			if (lastOrdersByContactIds.get(o.Contact_Id__c) != null) {
				if (o.EffectiveDate > lastOrdersByContactIds.get(o.Contact_Id__c).EffectiveDate) lastOrdersByContactIds.put(o.Contact_Id__c, o);
			} else {
				lastOrdersByContactIds.put(o.Contact_Id__c, o);
			}
		}
		System.debug('[HelperCustomer] lastOrdersByContactIds=:' + lastOrdersByContactIds);

		// Pour chacun des contacts comptes personnels, vérifier qu'il n'y a pas eu de commande posterieure à la date de celles des paniers
		List<Order> lastOrders = [select CurrencyIsoCode, Montant_Hors_Frais__c, EffectiveDate, Contact_Email__c, Contact_lie__r.LastName,
		                          Contact_lie__r.firstName, Contact_Id__c, Account.FirstName, Account.LastName from Order where Contact_Id__c in :lastOrdersByContactIds.keySet() order by EffectiveDate desc];
		System.debug('[HelperCustomer] lastOrders=:' + lastOrders);
		for (Order o : lastOrders) {
			System.debug('[HelperCustomer] o=:' + o);
			System.debug('[HelperCustomer] lastOrdersByContactIds.get(o.Contact_Id__c)=:' + lastOrdersByContactIds.get(o.Contact_Id__c));
			if (lastOrdersByContactIds.get(o.Contact_Id__c) != null && o.Id == lastOrdersByContactIds.get(o.Contact_Id__c).Id) abandonnedCartsWithoutPayedOrder.add(o);
		}

		return abandonnedCartsWithoutPayedOrder;
	}
    
    // Les Quotes abandonnés doivent contenir ContactId qui permet de chercher les commandes associées
	public static List<Quote> checkNonPayedQuotes(List<Quote> abandonnedQuotes) {
		List<Quote> nonPayedQuotes = new List<Quote> ();
        nonPayedQuotes.addAll(abandonnedQuotes);

		// Dedoublonnage des Quotes abandonnés appartenants à un même contact (on conserve le dernier en date)
		Map<String, Quote> lastQuotesByContactIds = new Map<String, Quote> ();
		For (Quote q : abandonnedQuotes) {
			// Creation de la MAP des quotes par contact
			if (lastQuotesByContactIds.get(q.ContactId) != null) {
				if (q.CreatedDate > lastQuotesByContactIds.get(q.ContactId).CreatedDate) lastQuotesByContactIds.put(q.ContactId, q);
			} else {
				lastQuotesByContactIds.put(q.ContactId, q);
			}
		}
		System.debug('[HelperCustomer] lastQuotesByContactIds=:' + lastQuotesByContactIds);

		// Pour chacun des contacts comptes personnels, vérifier qu'il n'y a pas eu de commande posterieure à la date de celles des Quotes
		List<Order> lastOrders = [select Contact_Id__c, createdDate  from Order where Contact_Id__c in :lastQuotesByContactIds.keySet() order by EffectiveDate desc];
		System.debug('[HelperCustomer] lastOrders=:' + lastOrders);
		for (Order o : lastOrders) {
			System.debug('[HelperCustomer] o=:' + o);
			System.debug('[HelperCustomer] lastQuotesByContactIds.get(o.ContactId)=:' + lastQuotesByContactIds.get(o.Contact_Id__c));
			if (lastQuotesByContactIds.get(o.Contact_Id__c) != null && o.createdDate > lastQuotesByContactIds.get(o.Contact_Id__c).createdDate)
                if(nonPayedQuotes.indexOf(lastQuotesByContactIds.get(o.Contact_Id__c)) > -1)  nonPayedQuotes.remove(nonPayedQuotes.indexOf(lastQuotesByContactIds.get(o.Contact_Id__c)));
		}

		return nonPayedQuotes;
	}
}