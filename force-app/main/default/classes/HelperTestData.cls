@IsTest
public class HelperTestData {

	private static Boolean standardPriceAlreadyCreated = false;
	private static String SOLUTION_NAME_TEST = 'XLSTAT-Base';
	private static String SOLUTION_NAME_TEST2 = 'XLRISK';
	private static List<Product2> products = new List<Product2> ();

	public static void insertTextEmail() {
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

	public static Id createOrderWithProductWithContact(Contact contact) {
		List<Software__c> softwares = new List<Software__c>{
				new Software__c(
						AccessType__c='Multiple', DevelopmentDone__c=true,
						Code__c='00',
						Name='XLSTAT',
						ProductId__c='44affc53-2fc9-4942-a8bb-5f87214c8f0a'
				),
				new Software__c(
						AccessType__c='Simple',
						Code__c='01',
						Name='XLRISK',
						ProductId__c='abb8ac81-f3a1-402a-a5e5-e90b444aa933'
				)
		};
		insert softwares;

		Order order = new Order(Contact_lie__c=contact.Id, AccountId=contact.AccountId, EffectiveDate=Date.today(), Status='Version préliminaire',
				Domaine_utilisateur__c='Company', Type_licence__c='Annuelle', CurrencyIsoCode='EUR', BillingCountry='France',
				Pricebook2Id=Test.getStandardPricebookId());
		insert order;

		createProducts();
		for (Product2 p : products) {
			PricebookEntry pbe = new PricebookEntry(IsActive = true, Product2Id = p.Id, Pricebook2Id = Test.getStandardPricebookId(),
			                                        UnitPrice = 10, CurrencyIsoCode = 'EUR');
			insert pbe;
			insert new OrderItem(OrderId = order.Id, Product2Id = p.Id, PricebookEntryId = pbe.Id, UnitPrice = 11, Quantity = 5);
		}

		return order.Id;
	}

	public static Id createOrderWithProductWithContactNotXLStat(Contact contact) {
		List<Software__c> softwares = new List<Software__c>{
				new Software__c(
						AccessType__c='Multiple', DevelopmentDone__c=true,
						Code__c='00',
						Name='XLSTAT',
						ProductId__c='44affc53-2fc9-4942-a8bb-5f87214c8f0a'
				),
				new Software__c(
						AccessType__c='Simple',
						Code__c='01',
						Name='XLRISK',
						ProductId__c='abb8ac81-f3a1-402a-a5e5-e90b444aa933'
				)
		};
		insert softwares;
		Order order = new Order(Contact_lie__c=contact.Id, AccountId=contact.AccountId, EffectiveDate=Date.today(),
				Status='Version préliminaire', Domaine_utilisateur__c='Company', Type_licence__c='Annuelle',
				CurrencyIsoCode='EUR', BillingCountry='France', Pricebook2Id=Test.getStandardPricebookId());
		insert order;
		createProductsNotXLStat();
		System.debug('>>>> TEST - products = '+products);
		Map<Id, PricebookEntry> pricebookEntriesByProductId = new Map<Id, PricebookEntry>();
		List<OrderItem> orderItems = new List<OrderItem>();
		for (Product2 p : products) {
			PricebookEntry pbe = new PricebookEntry(IsActive=true, Product2Id=p.Id, Pricebook2Id=Test.getStandardPricebookId(), UnitPrice=10, CurrencyIsoCode='EUR');
			pricebookEntriesByProductId.put(p.Id, pbe);
		}
		insert pricebookEntriesByProductId.values();
		for (Product2 p : products) {
			orderItems.add(new OrderItem(OrderId=order.Id, Product2Id=p.Id, PricebookEntryId=pricebookEntriesByProductId.get(p.Id).Id, UnitPrice=11, Quantity=5));
		}
		insert orderItems;
		System.debug('>>>> TEST - orderItems = '+orderItems);
		return order.Id;
	}

	public static Id createOrderWithProductWithPersonalAccount(Account paccount) {
		Order order = new Order(AccountId = paccount.Id, EffectiveDate = Date.today(), Status = 'Version préliminaire', Domaine_utilisateur__c = 'Company',
		                        Type_licence__c = 'Annuelle', CurrencyIsoCode = 'EUR', BillingCountry='France', Pricebook2Id = Test.getStandardPricebookId());
		insert order;

		createProducts();
		for (Product2 p : products) {
			PricebookEntry pbe = new PricebookEntry(IsActive = true, Product2Id = p.Id, Pricebook2Id = Test.getStandardPricebookId(),
			                                        UnitPrice = 10, CurrencyIsoCode = 'EUR');
			insert pbe;
			insert new OrderItem(OrderId = order.Id, Product2Id = p.Id, PricebookEntryId = pbe.Id, UnitPrice = 11, Quantity = 5);
		}

		return order.Id;
	}

	public static Id createNewOrderWithProductWithPersonalAccount(Account paccount) {
		Order order = new Order(AccountId = paccount.Id, EffectiveDate = Date.today(), Status = 'Version préliminaire', Domaine_utilisateur__c = 'Company',
				Type_licence__c = 'Annuelle', CurrencyIsoCode = 'EUR', BillingCountry='France', Pricebook2Id = Test.getStandardPricebookId());
		insert order;

		System.debug('>>>> products = '+products);
		for (Product2 p : products) {
			//PricebookEntry pbe = [SELECT Id FROM PricebookEntry WHERE Product2Id = :p.Id AND CurrencyIsoCode = 'EUR' AND Pricebook2Id = :Test.getStandardPricebookId()];
			PricebookEntry pbe = new PricebookEntry(IsActive = true, Product2Id = p.Id, Pricebook2Id = Test.getStandardPricebookId(),
					UnitPrice = 10, CurrencyIsoCode = 'EUR');
			insert pbe;
			insert new OrderItem(OrderId = order.Id, Product2Id = p.Id, PricebookEntryId = pbe.Id, UnitPrice = 11, Quantity = 5);
		}

		return order.Id;
	}

	public static Id createQuoteWithProductWithContact() {
		Account acc = new Account(Name = 'test', BillingCountry = 'France');
		insert acc;

		Contact ct = new Contact(LastName = 'testContact', FirstName = 'gerard', AccountId = acc.Id);
		insert ct;

		Opportunity opp = new Opportunity(AccountId = acc.Id, Amount = 700, CurrencyIsoCode = 'EUR', Name = 'opportunityTest', StageName = 'Proposition de valeur	', CloseDate = Date.today());
		insert opp;

		Quote quote = new Quote(Name = 'QuoteTest', ContactId=ct.Id, OpportunityId = opp.Id, Status = 'Version préliminaire', CurrencyIsoCode = 'EUR', Pricebook2Id = Test.getStandardPricebookId());
		insert quote;

		createProducts();
		for (Product2 p : products) {
			PricebookEntry pbe = new PricebookEntry(IsActive = true, Product2Id = p.Id, Pricebook2Id = Test.getStandardPricebookId(),
			                                        UnitPrice = 10, CurrencyIsoCode = 'EUR');
			insert pbe;
			insert new QuoteLineItem(QuoteId = quote.Id, Product2Id = p.Id, PricebookEntryId = pbe.Id, UnitPrice = 11, Quantity = 5);
		}

		return quote.Id;
	}

	public static void createContactAndAccountByAccountNameAndContactEmail(String accountName, String contactEmail) {
		Account acc = new Account(Name = accountName,BillingCountry = 'France');
		insert acc;

		insert new Contact(LastName = contactEmail.substringBefore('@'), Email = contactEmail, AccountId = acc.Id);
	}

	public static void createStandardPriceBook() {
		createProducts();
		for (Product2 p : products) {
			insert new PricebookEntry(IsActive = true, Product2Id = p.Id, Pricebook2Id = Test.getStandardPricebookId(), UnitPrice = 10);
		}
		standardPriceAlreadyCreated = true;
	}

	public static Id createPriceBookForCurrency(String currencyCode) {
		if (!standardPriceAlreadyCreated) createStandardPriceBook();

		insert new Currencies_Exchange_Rates__c(Day__c = Date.today(), CurrencyIsoCode = currencyCode, Rate__c = 1);

		Pricebook2 pricebook = new Pricebook2(Name = 'Test', IsActive = true, CurrencyIsoCode__c = currencyCode);
		insert pricebook;

		for (Product2 p : products) {
			insert new PricebookEntry(IsActive = true, Product2Id = p.Id, Pricebook2Id = pricebook.Id, UnitPrice = 10);
		}

		return pricebook.Id;
	}

	public static void insertCoupon(String couponName) {
		insert new Coupon__c(Name = couponName);
	}

	private static void createProducts() {
		products.add(new Product2(IsActive = true, Name = SOLUTION_NAME_TEST, Libelle_Devis__c = 'Laurent',
				ProductCode = 'S_BAS_EDU_AN', Family = 'Solution', Domaine_utilisateur__c = 'Entreprise/Privé',
				Type_licence__c = 'Annuelle',isSoldOnline__c = true));
		products.add(new Product2(IsActive = true, Name = SOLUTION_NAME_TEST, Libelle_Devis__c = 'Cherif',
				ProductCode = 'S_BAS_CMP_AN', Family = 'Solution', Domaine_utilisateur__c = 'Campus',
				Type_licence__c = 'Support et maintenance ( 1 an )',isSoldOnline__c = true));
		products.add(new Product2(IsActive = true, Name = 'CD', Libelle_Devis__c = 'Bayo', ProductCode = 'M_CD_CMP_AN', Family = 'Shipping',
		                          Domaine_utilisateur__c = 'Campus', Type_licence__c = 'Annuelle',isSoldOnline__c = true));
		products.add(new Product2(IsActive = true, Name = 'XLSTAT-3DPlot', Libelle_Devis__c = 'xlstat', ProductCode = 'M_3DPLOT_CMP_AN', Family = 'Module',
		                          Domaine_utilisateur__c = 'Campus', Type_licence__c = 'Annuelle',isSoldOnline__c = true));
		/*products.add(new Product2(IsActive = true, Name = SOLUTION_NAME_TEST, Libelle_Devis__c = 'Cherif',
				ProductCode = 'S_BASICPLUS_CAM_SC', Family = 'Solution', Domaine_utilisateur__c = 'Campus',
				Type_licence__c = 'Small Campus',isSoldOnline__c = true));
		products.add(new Product2(IsActive = true, Name = SOLUTION_NAME_TEST, Libelle_Devis__c = 'Cherif',
				ProductCode = 'S_BASIC_STU_AN', Family = 'Solution', Domaine_utilisateur__c = 'Etudiant',
				Type_licence__c = 'Annuelle',isSoldOnline__c = true));
		products.add(new Product2(IsActive = true, Name = SOLUTION_NAME_TEST, Libelle_Devis__c = 'Cherif',
				ProductCode = 'S_PRE_EDU_AN', Family = 'Solution', Domaine_utilisateur__c = 'Education',
				Type_licence__c = 'Annuelle',isSoldOnline__c = true));*/
		insert products;
	}

	private static void createProductsNotXLStat() {
		products.add(new Product2(IsActive = true, Name = SOLUTION_NAME_TEST2, Libelle_Devis__c = 'Laurent',
				ProductCode = 'RSK_PRE_EDU_AN', Family = 'Solution', Domaine_utilisateur__c = 'Education',
				Type_licence__c = 'Annuelle', isSoldOnline__c = true)
		);
		products.add(new Product2(IsActive = true, Name = SOLUTION_NAME_TEST2, Libelle_Devis__c = 'Cherif',
				ProductCode = 'RSK_PRE_STU_AN', Family = 'Solution', Domaine_utilisateur__c = 'Etudiant',
				Type_licence__c = 'Annuelle', isSoldOnline__c = true)
		);
		products.add(new Product2(IsActive = true, Name = SOLUTION_NAME_TEST2, Libelle_Devis__c = 'Cherif',
				ProductCode = 'RSK_PRE_CMP_AN', Family = 'Solution', Domaine_utilisateur__c = 'Entreprise/Privé',
				Type_licence__c = 'Annuelle', isSoldOnline__c = true)
		);
		products.add(new Product2(IsActive = true, Name = SOLUTION_NAME_TEST2, Libelle_Devis__c = 'Cherif',
				ProductCode = 'RSK_PRE_EDU_NT', Family = 'Solution', Domaine_utilisateur__c = 'Entreprise/Privé',
				Type_licence__c = 'Réseau', isSoldOnline__c = true)
		);
		products.add(new Product2(IsActive = true, Name = SOLUTION_NAME_TEST2, Libelle_Devis__c = 'Cherif',
				ProductCode = 'RSK_CAM_LC', Family = 'Solution', Domaine_utilisateur__c = 'Campus',
				Type_licence__c = 'Large Campus', isSoldOnline__c = true)
		);
		products.add(new Product2(IsActive = true, Name = SOLUTION_NAME_TEST2, Libelle_Devis__c = 'Cherif',
				ProductCode = 'RSK_CAM_SC', Family = 'Solution', Domaine_utilisateur__c = 'Campus',
				Type_licence__c = 'Small Campus', isSoldOnline__c = true)
		);
		products.add(new Product2(IsActive = true, Name = SOLUTION_NAME_TEST2, Libelle_Devis__c = 'Cherif',
				ProductCode = 'RSK_CAM_CL', Family = 'Solution', Domaine_utilisateur__c = 'Campus',
				Type_licence__c = 'Classroom', isSoldOnline__c = true)
		);

		insert products;
	}

	public static void createExchangeRate() {
		insert new Currencies_Exchange_Rates__c(Rate__c = 1, CurrencyIsoCode = 'EUR', Day__c = Date.today().addDays(-1));
		insert new Currencies_Exchange_Rates__c(Rate__c = 1, CurrencyIsoCode = 'USD', Day__c = Date.today().addDays(-1));
		insert new Currencies_Exchange_Rates__c(Rate__c = 1, CurrencyIsoCode = 'EUR', Day__c = Date.today());
		insert new Currencies_Exchange_Rates__c(Rate__c = 1, CurrencyIsoCode = 'USD', Day__c = Date.today());
	}

}