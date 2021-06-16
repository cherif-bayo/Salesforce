public class HelperQuote {

	public static String getEnTranslationForState(String countryCode, String stateCode) {
		Translation_Addresses__c[] transState = [SELECT Label__c FROM Translation_Addresses__c WHERE IsState__c = true AND CountryCode__c = :countryCode AND Language__c = 'en' AND Value__c = :stateCode limit 1];
		if (transState.size() > 0) return transState[0].Label__c;
		else return '';
	}


	public static String getEnNameForCountryCode(String CountryCode) {
		Translation_Addresses__c[] transCountry = [SELECT Label__c FROM Translation_Addresses__c WHERE IsCountry__c = true AND Language__c = 'en' AND Value__c = :countryCode limit 1];

		if (transCountry.size() > 0) return transCountry[0].Label__c;
		else return '';
	}

	public static List<String> getFrBankAccountLines(String BillingCountry, String CurrencyIsoCode) {
		List<String> bankAccountLines = new List<String> ();
		if (CurrencyIsoCode == 'USD') {
			bankAccountLines.add('Titulaire : Addinsoft');
			bankAccountLines.add('Banque : HSBC FR BBC GUYENNE ET GASCOGNE');
			bankAccountLines.add('Adresse banque : 10 Allée d’Orléans, 33001 Bordeaux Cedex, France');
			bankAccountLines.add('Code Banque : 30056');
			bankAccountLines.add('Code Guichet : 00722');
			bankAccountLines.add('Compte : 07220177466');
			bankAccountLines.add('Cl&eacute; RIB : 47');
			bankAccountLines.add('SWIFT : CCFRFRPP');
			bankAccountLines.add('IBAN : FR76 3005 6007 2207 2201 7746 647');
		} else if (CurrencyIsoCode == 'EUR' && BillingCountry == 'France') {
			bankAccountLines.add('Banque : Crédit Mutuel du Sud-Ouest');
			bankAccountLines.add('Adresse banque : CM BORDEAUX INTENDANCE');
			bankAccountLines.add('Code Banque : 15589');
			bankAccountLines.add('Code Guichet : 33547');
			bankAccountLines.add('Compte : 07476325843');
			bankAccountLines.add('Cl&eacute; RIB : 53');
			bankAccountLines.add('SWIFT : CMBRFR2BARK');
			bankAccountLines.add('IBAN: FR76 1558 9335 4707 4763 2584 353');
		} else { // GBP et EUR hors France
			bankAccountLines.add('Titulaire : Addinsoft');
			bankAccountLines.add('Banque : HSBC FR BBC GUYENNE ET GASCOGNE');
			bankAccountLines.add('Adresse banque : 10 Allée d’Orléans, 33001 Bordeaux Cedex, France');
			bankAccountLines.add('Code Banque : 30056');
			bankAccountLines.add('Code Guichet : 00722');
			bankAccountLines.add('Compte : 07223636971');
			bankAccountLines.add('Cl&eacute; RIB : 47');
			bankAccountLines.add('SWIFT : CCFRFRPP');
			bankAccountLines.add('IBAN : FR76 3005 6007 2207 2236 3697 147');
		}
		return bankAccountLines;
	}

	public static List<String> getEnBankAccountLines(Boolean isUS, String BillingCountry, String CurrencyIsoCode) {
		List<String> bankAccountLines = new List<String> ();
		if (isUS) {
			bankAccountLines.add('Account owner: Addinsoft Inc.');
			bankAccountLines.add('Bank name: HSBC USA NA');
			bankAccountLines.add('Bank address: 452 Fifth Avenue, New York City');
			bankAccountLines.add('Account Number: 969000332');
			bankAccountLines.add('Routing Number: 022000020');
			bankAccountLines.add('ABA Number: 021001088');
			bankAccountLines.add('SWIFT CODE: MRMDUS33');
		} else if (CurrencyIsoCode == 'USD') {
			bankAccountLines.add('Bank name: HSBC FR BBC GUYENNE ET GASCOGNE');
			bankAccountLines.add('Bank address: 10 Allée d’Orléans, 33001 BORDEAUX CEDEX, FRANCE');
			bankAccountLines.add('Bank code: 30056');
			bankAccountLines.add('Branch code: 00722');
			bankAccountLines.add('Account owner: Addinsoft');
			bankAccountLines.add('Account: 07220177466');
			bankAccountLines.add('For international transfers:');
			bankAccountLines.add('SWIFT: CCFRFRPP');
			bankAccountLines.add('IBAN: FR76 3005 6007 2207 2201 7746 647');
		} else if (CurrencyIsoCode == 'EUR' && BillingCountry == 'France') {
			bankAccountLines.add('Bank name: Crédit Mutuel du Sud-Ouest');
			bankAccountLines.add('Bank address: CM BORDEAUX INTENDANCE');
			bankAccountLines.add('Bank code: 15589');
			bankAccountLines.add('Branch code: 33547');
			bankAccountLines.add('Account owner: Addinsoft');
			bankAccountLines.add('Account: 07476325843');
			bankAccountLines.add('For international transfers:');
			bankAccountLines.add('SWIFT: CMBRFR2BARK');
			bankAccountLines.add('IBAN: FR76 1558 9335 4707 4763 2584 353');
		} else { // GBP et EUR hors France
			bankAccountLines.add('Bank name: HSBC FR BBC GUYENNE ET GASCOGNE');
			bankAccountLines.add('Bank address: 10 Allée d’Orléans, 33001 BORDEAUX CEDEX, FRANCE');
			bankAccountLines.add('Bank code: 30056');
			bankAccountLines.add('Branch code: 00722');
			bankAccountLines.add('Account owner: Addinsoft');
			bankAccountLines.add('Account: 07223636971');
			bankAccountLines.add('For international transfers:');
			bankAccountLines.add('SWIFT: CCFRFRPP');
			bankAccountLines.add('IBAN: FR76 3005 6007 2207 2236 3697 147');
		}
		return bankAccountLines;
	}

	public static List<String> getEnAddinsoftCompanyLines(Boolean isUS) {
		List<String> addinsoftCompanyLines = new List<String> ();
		if (isUs) {
			// Addinsoft Inc.
			addinsoftCompanyLines.add('Addinsoft Inc.');
			addinsoftCompanyLines.add('244 Fifth Avenue');
			addinsoftCompanyLines.add('Suite E100');			
			addinsoftCompanyLines.add('New York NY 11101');
			addinsoftCompanyLines.add('USA');
			addinsoftCompanyLines.add('Tel: +1 (646) 412 3348');
			addinsoftCompanyLines.add('Email: <a href="mailto:sales@xlstat.com">sales@xlstat.com</a>');
			addinsoftCompanyLines.add('D-U-N-S: 056229019');
		} else { // Addinsoft
			addinsoftCompanyLines.add('Addinsoft');
			addinsoftCompanyLines.add('40 rue Damr&eacute;mont');
			addinsoftCompanyLines.add('75018 PARIS');
			addinsoftCompanyLines.add('FRANCE');
			addinsoftCompanyLines.add('Tel: +33 1 70 06 04 88');
			addinsoftCompanyLines.add('Email: <a href="mailto:sales@xlstat.com">sales@xlstat.com');
			addinsoftCompanyLines.add('European VAT number: FR 70 429102767');
		}
		return addinsoftCompanyLines;
	}
}