global class InitSandbox implements SandboxPostCopy {

	global void runApexClass(SandboxContext context) {

		System.debug('Org ID: ' + context.organizationId());
		System.debug('Sandbox ID: ' + context.sandboxId());
		System.debug('Sandbox Name: ' + context.sandboxName());

		insert new Currencies_Exchange_Rates__c(Rate__c = 1, CurrencyIsoCode = 'EUR', Day__c = date.today().addDays(- 1));
		insert new Currencies_Exchange_Rates__c(Rate__c = 0.8, CurrencyIsoCode = 'USD', Day__c = date.today().addDays(- 1));
		insert new Currencies_Exchange_Rates__c(Rate__c = 1, CurrencyIsoCode = 'EUR', Day__c = date.today());
		insert new Currencies_Exchange_Rates__c(Rate__c = 0.8, CurrencyIsoCode = 'USD', Day__c = date.today());

		insert new Texte_Email__c(Code__c = 'ENCL', Name = 'EN MyXLSTAT créé lien bouton', Texte__c = 'https://www.xlstat.com/en/login');
		insert new Texte_Email__c(Code__c = 'ENCD', Name = 'EN MyXLSTAT créé lien bouton', Texte__c = 'https://www.xlstat.com/en/login');
		insert new Texte_Email__c(Code__c = 'ENCB', Name = 'EN MyXLSTAT créé bouton', Texte__c = 'Connect to your My XLSTAT account');
		insert new Texte_Email__c(Code__c = 'ENNCL', Name = 'EN MyXLSTAT non créé lien bouton', Texte__c = 'https://www.xlstat.com/en/register');
		insert new Texte_Email__c(Code__c = 'ENNCD', Name = 'EN MyXLSTAT Non créé Description', Texte__c = 'Create your My XLSTAT account and get easy access to all your information. You can renew or order a new license and download the latest XLSTAT Version your license gives you access to. Use the email address you gave us at time of order and the following ...');
		insert new Texte_Email__c(Code__c = 'ENNCB', Name = 'EN MyXLSTAT non créé bouton', Texte__c = 'Create a My XLSTAT account');
		insert new Texte_Email__c(Code__c = 'FRCL', Name = 'FR MyXLSTAT créé lien bouton', Texte__c = 'https://www.xlstat.com/en/login');
		insert new Texte_Email__c(Code__c = 'FRCD', Name = 'FR MyXLSTAT créé Description', Texte__c = 'Pour renouveler votre licence, pour commander de nouvelles licences ou simplement pour télécharger la dernière version de XLSTAT à laquelle vous avez accès, veuillez vous connecter sur votre compte Mon XLSTAT.');
		insert new Texte_Email__c(Code__c = 'FRCB', Name = 'FR MyXLSTAT créé bouton', Texte__c = 'Se connecter sur mon compte XLSTAT');
		insert new Texte_Email__c(Code__c = 'FRNCL', Name = 'FR MyXLSTAT non créé lien bouton', Texte__c = 'https://www.xlstat.com/fr/inscription');
		insert new Texte_Email__c(Code__c = 'FRNCD', Name = 'FR MyXLSTAT Non créé Description', Texte__c = 'Pour renouveler votre licence, pour commander de nouvelles licences ou simplement pour télécharger la dernière version de XLSTAT à laquelle vous avez accès, veuillez créer un compte Mon XLSTAT avec l’adresse mail utilisée lors de votre commande et le cod...');
		insert new Texte_Email__c(Code__c = 'FRNCB', Name = 'FR MyXLSTAT non créé bouton', Texte__c = 'Créer mon compte XLSTAT');

	}
}