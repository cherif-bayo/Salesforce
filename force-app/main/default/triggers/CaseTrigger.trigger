trigger CaseTrigger on Case(before insert) {

	List<Case> newCases = new List<Case> (Trigger.new);
	System.debug('CaseTrigger Before Insert Start :' + newCases);

	Set<String> emails = new Set<String> ();
	for (Case aCase : newCases) if (aCase.SuppliedEmail != null && aCase.SuppliedEmail.length() >0 ) emails.add(aCase.SuppliedEmail);

	// Rattachement des cases aux leads par l'adresse email
	Map<String, String> LeadIdByMail = new Map<String, String> ();
	List<Lead> leads = [select Email from Lead where Email in :emails];
	For (Lead lead : leads) LeadIdByMail.put(lead.Email, lead.Id);
	For (Case aCase : newCases) if (aCase.SuppliedEmail != null && LeadIdByMail.containsKey(aCase.SuppliedEmail)) aCase.lead__c = LeadIdByMail.get(aCase.SuppliedEmail);

	// Rattachement des cases aux accounts par l'adresse email de contact
	Map<String, String> ContactAccountIdByMail = new Map<String, String> ();
	List<Contact> contacts = [select Email,AccountId from Contact where Email in :emails];
	For (Contact contact : contacts) ContactAccountIdByMail.put(contact.Email, contact.AccountId);
	For (Case aCase : newCases) if (aCase.SuppliedEmail != null && ContactAccountIdByMail.containsKey(aCase.SuppliedEmail)) aCase.AccountId = ContactAccountIdByMail.get(aCase.SuppliedEmail);

	System.debug('CaseTrigger Before Insert End :' + newCases);
}