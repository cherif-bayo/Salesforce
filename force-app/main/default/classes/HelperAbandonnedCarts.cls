public class HelperAbandonnedCarts {

	List<Order> abandonnedCarts = new List<Order> ();

	public HelperAbandonnedCarts() {

		// Recuperation de la fourchette de date de relance de panier abandonnés
		Integer nbDaysMin = Integer.valueOf(Parameters.getString('Abandonned_Carts_Day_Min'));
		if (Test.isRunningTest()) nbDaysMin = 1; // Pour être independant du parametre custom metadata

		Integer nbDaysMax = Integer.valueOf(Parameters.getString('Abandonned_Carts_Day_Max'));
		if (Test.isRunningTest()) nbDaysMax = 7; // Pour être independant du parametre custom metadata

		// Recuperation des paniers abandonnés
		Date dateMin = DateTime.now().addDays(- nbDaysMin).date();
		Date dateMax = DateTime.now().addDays(- nbDaysMax).date();

		// Recuperation des paniers abandonnés
		List<Order> orders = [SELECT Contact_Id__c, EffectiveDate FROM Order WHERE Status = :ParametersForOrders.ORDER_STATUS_ABANDONNE
		                               and EffectiveDate <= :dateMin
		                               and EffectiveDate >= :dateMax
		                               and PanierAbandonneRelance__c = false];

		System.debug('[HelperAbandonnedCarts] commandes avec panier abandonné:' + orders);

		// Calcul des paniers abandonnés à relancer (pas de commande postérieure)
		abandonnedCarts = HelperCustomer.checkPayedOrderFromAbandonnedCarts(orders);
	}

	public void markAbonnedCartsAsCovered() {
		for (Order o : abandonnedCarts) o.PanierAbandonneRelance__c = true;
		update abandonnedCarts;
	}

	public List<Pardot.Prospect> getProspects() {
		List<Pardot.Prospect> prospects = new List<Pardot.Prospect> ();

		List<String> orderIds = new List<String>();
		for (Order o :abandonnedCarts) orderIds.add(o.Id);

		List<Order> carts = [SELECT Contact_Email__c, Montant_Hors_Frais__c, CurrencyIsoCode, Contact_Id__c, EffectiveDate,
		                               Contact_lie__r.FirstName, Contact_lie__r.LastName, Account.FirstName, Account.LastName,
									   (select Product2.Libelle_Devis__c from OrderItems)
		                               FROM Order WHERE Id in :orderIds];
		System.debug('[HelperAbandonnedCarts] commandes avec panier abandonnedCarts:' + carts);

		for (Order cart : carts) {
			Pardot.Prospect prospect = new Pardot.Prospect();
			
			// Concatenation de la liste des produits
			String products = '';
			for (OrderItem  oi :cart.OrderItems) {
				products += oi.Product2.Libelle_Devis__c +','; 
				System.debug('[HelperAbandonnedCarts] orderItem: ' + oi + 'Products list: '+ products); 
			}
			prospect.Produit_Panier = products.substringBeforeLast(',');

			prospect.email = cart.Contact_Email__c; // Formule qui renvoie l'email du contact ou du compte personnel associé à la commande
			prospect.Devise_Panier = cart.CurrencyIsoCode;
			prospect.Montant_Panier = cart.Montant_Hors_Frais__c;
			prospect.first_name = cart.Contact_lie__r.FirstName != null ? cart.Contact_lie__r.FirstName : cart.Account.FirstName;
			prospect.last_name = cart.Contact_lie__r.LastName != null ? cart.Contact_lie__r.LastName : cart.Account.LastName;
			prospect.fid = cart.Contact_Id__c; // Formule qui renvoie l'id du contact ou du compte personnel associé à la commande
			prospects.add(prospect);

			System.debug('[HelperAbandonnedCarts] prospect:' + prospect);
		}

		return prospects;
	}
}