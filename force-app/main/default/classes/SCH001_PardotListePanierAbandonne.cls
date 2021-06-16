global class SCH001_PardotListePanierAbandonne implements Schedulable {

	global void execute(System.SchedulableContext ctx) {
		try {
			manageAbandonnedCart();
		} catch(Exception e) {
			System.debug('erreur generation de list Paniers abandonnés dans Pardot : ' + e.getMessage());
			insert new WS_Error__c(Request__c = 'GET', WebserviceName__c = 'Pardot', ErrorMessage__c = 'erreur dans la liste Paniers Abandonnés :' + e.getMessage() + ' ' + e.getStackTraceString());
		}
	}

	@future(callout = true)
	public static void manageAbandonnedCart() {
		HelperAbandonnedCarts helperAbandonnedCart = new HelperAbandonnedCarts();

		// Création ou mise à jour du prospect (contact ou personnal account) dans Pardot avec ajout dans la liste des paniers abandonnés
		PardotFacade.upsertProspectsWithListAssociated(helperAbandonnedCart.getProspects(), Pardot.LIST_ABANDONNED_CARTS_ID);

		// Mise à jour du flag d'envoi d'email sur les paniers abandonnés traités
		helperAbandonnedCart.markAbonnedCartsAsCovered();
	}
}