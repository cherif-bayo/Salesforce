public class SCH001_PardotListeQuoteAbandonne implements Schedulable {
	public void execute(System.SchedulableContext ctx) {
		try {
			manageAbandonnedQuote();
		} catch(Exception e) {
			System.debug('erreur generation de list Quotes abandonnés dans Pardot : ' + e.getMessage());
			insert new WS_Error__c(Request__c = 'GET', WebserviceName__c = 'Pardot', ErrorMessage__c = 'erreur dans la liste Quotes Abandonnés :' + e.getMessage() + ' ' + e.getStackTraceString());
		}
	}

	@future(callout = true)
	public static void manageAbandonnedQuote() {
		HelperAbandonnedQuotes helperAbandonnedQuote = new HelperAbandonnedQuotes();

		// Création ou mise à jour du prospect (contact ou personnal account) dans Pardot avec ajout dans la liste des quotes abandonnés
		PardotFacade.upsertProspectsWithListAssociated(helperAbandonnedQuote.getProspects(), Pardot.LIST_ABANDONNED_QUOTES_ID);

		// Mise à jour du flag d'envoi d'email sur les quotes abandonnés traités
		helperAbandonnedQuote.markAbonnedQuotesAsCovered();
    }
}