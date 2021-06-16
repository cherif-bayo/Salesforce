@IsTest
public class FlexeraSendKeyByEmailTest {

	@TestSetup
	public static void SetUp() {
		Account acc = new Account(Name = 'test');
		insert acc;

		Contact ct = new Contact(FirstName='azerty',LastName = 'test', AccountId = acc.Id, Email = 'test@test.fr');
		insert ct;
		Contact ctfr = new Contact(FirstName='azertyfr',LastName = 'testfr', AccountId = acc.Id, Email = 'testfr@test.fr', Langue__c='FR');
		insert ctfr;

		Order order = new Order(Name = 'test', AccountId = acc.Id, EffectiveDate = Date.today(), Status = 'Version préliminaire', R_f_Bon_de_commande__c='ref123');
		insert order;

		List<Software__c> softwares = new List<Software__c>{
				new Software__c(AccessType__c='Multiple', Code__c='00', Name='XLSTAT', DevelopmentDone__c=true, ProductId__c='44affc53-2fc9-4942-a8bb-5f87214c8f0a'),
				new Software__c(AccessType__c='Simple', Code__c='01', Name='XLRISK', ProductId__c='abb8ac81-f3a1-402a-a5e5-e90b444aa933')
		};
		insert softwares;

		insert new Flexera_Key__c(Name = 'test', Contact__c = ct.Id, Date_limite__c = Date.today(), Quantity__c = 3,
		                          Order__c = order.Id, Entitlement_Id__c = 'test', SoftwareCode__c='00');

		insert new Flexera_Key__c(Name = 'testNetwork', Contact__c = ct.Id, Date_limite__c = Date.today(), Quantity__c = 3,
		                          Order__c = order.Id, Entitlement_Id__c = 'testNetwork', SoftwareCode__c='01');

		insert new Flexera_Key__c(Name = 'testfr', Contact__c = ctfr.Id, Date_limite__c = Date.today(), Quantity__c = 3,
				Order__c = order.Id, Entitlement_Id__c = 'test', SoftwareCode__c='00');

		insert new Flexera_Key__c(Name = 'testNetworkfr', Contact__c = ctfr.Id, Date_limite__c = Date.today(), Quantity__c = 2,
				Order__c = order.Id, Entitlement_Id__c = 'testNetwork', SoftwareCode__c='01');

		insert new Texte_Email__c(Code__c = 'FRCD', Name = 'FR MyXLSTAT créé Description', Texte__c = 'Pour renouveler votre licence, pour commander de nouvelles licences ou simplement pour télécharger la dernière version de XLSTAT à laquelle vous avez accès, veuillez vous connecter sur votre compte Mon XLSTAT.');
		insert new Texte_Email__c(Code__c = 'ENCL', Name = 'EN MyXLSTAT créé lien bouton', Texte__c = 'https://www.xlstat.com/en/login');
		insert new Texte_Email__c(Code__c = 'FRCL', Name = 'FR MyXLSTAT créé lien bouton', Texte__c = 'https://www.xlstat.com/fr/connexion');
		insert new Texte_Email__c(Code__c = 'ENCB', Name = 'EN MyXLSTAT créé bouton', Texte__c = 'Connect to your My XLSTAT account');
		insert new Texte_Email__c(Code__c = 'ENNCD', Name = 'EN MyXLSTAT Non créé Description', Texte__c = 'Create your My XLSTAT account and get easy access to all your information. You can renew or order a new license and download the latest XLSTAT Version your license gives you access to. Use the email address you gave us at time of order and the following ...');
		insert new Texte_Email__c(Code__c = 'ENNCL', Name = 'EN MyXLSTAT non créé lien bouton', Texte__c = 'https://www.xlstat.com/en/register');
		insert new Texte_Email__c(Code__c = 'ENNCB', Name = 'EN MyXLSTAT non créé bouton', Texte__c = 'Create a My XLSTAT account');
		insert new Texte_Email__c(Code__c = 'FRCB', Name = 'FR MyXLSTAT créé bouton', Texte__c = 'Se connecter sur mon compte XLSTAT');
		insert new Texte_Email__c(Code__c = 'FRNCD', Name = 'FR MyXLSTAT Non créé Description', Texte__c = 'Pour renouveler votre licence, pour commander de nouvelles licences ou simplement pour télécharger la dernière version de XLSTAT à laquelle vous avez accès, veuillez créer un compte Mon XLSTAT avec l’adresse mail utilisée lors de votre commande et le cod...');
		insert new Texte_Email__c(Code__c = 'FRNCL', Name = 'FR MyXLSTAT non créé lien bouton', Texte__c = 'https://www.xlstat.com/fr/inscription');
		insert new Texte_Email__c(Code__c = 'FRNCB', Name = 'FR MyXLSTAT non créé bouton', Texte__c = 'Créer mon compte XLSTAT');
	}

	@IsTest
	public static void testMain() {
		Order order = [SELECT Id, Status FROM Order WHERE Name = 'test'];

		Flexera_Key__c key = [SELECT Id FROM Flexera_Key__c WHERE Order__c = :order.Id AND Contact__c != NULL AND Name = 'test' LIMIT 1];

		PageReference pg = Page.FlexeraSendKeyByEmail;
		pg.getParameters().put('keys_id', key.Id);
		pg.getParameters().put('is_update', 'false');
		Test.setCurrentPage(pg);

		FlexeraSendKeyByEmailController controller = new FlexeraSendKeyByEmailController();
		controller.InstanciatePart1();
		controller.InstanciatePart2();
		controller.Preview();

		System.debug('FlexeraSendKeyByEmailTest#controller.WpContacts' + controller.WpContacts);
		for (FlexeraSendKeyByEmailController.WrapperContact wpContact : controller.WpContacts) {
			wpContact.ContactEmail = wpContact.ContactsAccountEmails[0].getValue();
		}
		controller.Send();
		controller.getIsAnnualFR();
		controller.getIsPerpetualFR();
		controller.getIsAnnualEN();
		controller.getIsPerpetualEN();
	}

	@IsTest
	public static void testMainfr() {
		Order order = [SELECT Id, Status FROM Order WHERE Name = 'test'];

		Flexera_Key__c key = [SELECT Id FROM Flexera_Key__c WHERE Order__c = :order.Id AND Contact__c != NULL AND Name = 'testfr' LIMIT 1];

		PageReference pg = Page.FlexeraSendKeyByEmail;
		pg.getParameters().put('keys_id', key.Id);
		pg.getParameters().put('is_update', 'false');
		Test.setCurrentPage(pg);

		FlexeraSendKeyByEmailController controller = new FlexeraSendKeyByEmailController();
		controller.InstanciatePart1();
		controller.InstanciatePart2();
		controller.Preview();

		//System.debug('FlexeraSendKeyByEmailTest#controller.WpContacts' + controller.WpContacts);
		for (FlexeraSendKeyByEmailController.WrapperContact wpContact : controller.WpContacts) {
			wpContact.ContactEmail = wpContact.ContactsAccountEmails[0].getValue();
		}
		controller.Send();
		controller.getIsAnnualFR();
		controller.getIsPerpetualFR();
		controller.getIsAnnualEN();
		controller.getIsPerpetualEN();
	}

	@IsTest
	public static void testUpdate() {
		Order order = [SELECT Id, Status FROM Order WHERE Name = 'test'];

		Flexera_Key__c key = [SELECT Id FROM Flexera_Key__c WHERE Order__c = :order.Id AND Contact__c != NULL AND Name = 'test' LIMIT 1];

		PageReference pg = Page.FlexeraSendKeyByEmail;
		pg.getParameters().put('keys_id', key.Id);
		pg.getParameters().put('is_update', 'true');
		Test.setCurrentPage(pg);

		FlexeraSendKeyByEmailController controller = new FlexeraSendKeyByEmailController();
		controller.InstanciatePart1();
		controller.InstanciatePart2();
		controller.Preview();
		for (FlexeraSendKeyByEmailController.WrapperContact wpContact : controller.WpContacts) {
			wpContact.ContactEmail = wpContact.ContactsAccountEmails[0].getValue();
		}
		controller.Send();
		controller.getIsAnnualFR();
		controller.getIsPerpetualFR();
		controller.getIsAnnualEN();
		controller.getIsPerpetualEN();
	}

	@IsTest
	public static void testNetwork() {
		Order order = [SELECT Id, Status FROM Order WHERE Name = 'test'];
		Flexera_Key__c key = [SELECT Id, Is_Network__c FROM Flexera_Key__c WHERE Order__c = :order.Id AND Contact__c != NULL AND Entitlement_Id__c != NULL AND Name = 'testNetwork' LIMIT 1];

		PageReference pg = Page.FlexeraSendKeyByEmail;
		pg.getParameters().put('keys_id', key.Id);
		pg.getParameters().put('is_update', 'false');
		Test.setCurrentPage(pg);

		FlexeraSendKeyByEmailController controller = new FlexeraSendKeyByEmailController();
		controller.InstanciatePart1();
		controller.InstanciatePart2();
		controller.Preview();
		for (FlexeraSendKeyByEmailController.WrapperContact wpContact : controller.WpContacts) {
			wpContact.ContactEmail = wpContact.ContactsAccountEmails[0].getValue();
		}
		controller.Send();
		controller.getIsAnnualFR();
		controller.getIsPerpetualFR();
		controller.getIsAnnualEN();
		controller.getIsPerpetualEN();
	}

	@IsTest
	public static void testCampus() {
		Order order = [SELECT Id, Status FROM Order WHERE Name = 'test'];

		Flexera_Key__c key = [SELECT Id, Has_Student_Ext__c, Type_licence__c FROM Flexera_Key__c WHERE Order__c = :order.Id AND Contact__c != NULL AND Entitlement_Id__c != NULL AND Has_Student_Ext__c = FALSE AND Name = 'test' LIMIT 1];

		key.Type_licence__c = 'Small Campus';

		update key;

		PageReference pg = Page.FlexeraSendKeyByEmail;
		pg.getParameters().put('keys_id', key.Id);
		pg.getParameters().put('is_update', 'false');
		Test.setCurrentPage(pg);

		FlexeraSendKeyByEmailController controller = new FlexeraSendKeyByEmailController();
		controller.InstanciatePart1();
		controller.InstanciatePart2();
		controller.Preview();

		System.debug(controller.WpContacts);
		for (FlexeraSendKeyByEmailController.WrapperContact wpContact : controller.WpContacts) {
			wpContact.ContactEmail = wpContact.ContactsAccountEmails[0].getValue();
		}
		controller.Send();
		controller.getIsAnnualFR();
		controller.getIsPerpetualFR();
		controller.getIsAnnualEN();
		controller.getIsPerpetualEN();

		key.Has_Student_Ext__c = true;

		update key;

		controller = new FlexeraSendKeyByEmailController();
		controller.InstanciatePart1();
		controller.InstanciatePart2();
		controller.Preview();
		for (FlexeraSendKeyByEmailController.WrapperContact wpContact : controller.WpContacts) {
			wpContact.ContactEmail = wpContact.ContactsAccountEmails[0].getValue();
		}
		controller.Send();
		controller.getIsAnnualFR();
		controller.getIsPerpetualFR();
		controller.getIsAnnualEN();
		controller.getIsPerpetualEN();

		key.Type_licence__c = 'Large Campus';

		update key;

		controller = new FlexeraSendKeyByEmailController();
		controller.InstanciatePart1();
		controller.InstanciatePart2();
		controller.Preview();
		for (FlexeraSendKeyByEmailController.WrapperContact wpContact : controller.WpContacts) {
			wpContact.ContactEmail = wpContact.ContactsAccountEmails[0].getValue();
		}
		controller.Send();
		controller.getIsAnnualFR();
		controller.getIsPerpetualFR();
		controller.getIsAnnualEN();
		controller.getIsPerpetualEN();

		key.Has_Student_Ext__c = false;

		update key;

		controller = new FlexeraSendKeyByEmailController();
		controller.InstanciatePart1();
		controller.InstanciatePart2();
		controller.Preview();
		for (FlexeraSendKeyByEmailController.WrapperContact wpContact : controller.WpContacts) {
			wpContact.ContactEmail = wpContact.ContactsAccountEmails[0].getValue();
		}
		controller.Send();
		controller.getIsAnnualFR();
		controller.getIsPerpetualFR();
		controller.getIsAnnualEN();
		controller.getIsPerpetualEN();
	}

	@IsTest
	public static void testStatcon() {

		Account acc = new Account(Name = 'StatCon GmbH');
		insert acc;

		Contact ct = new Contact(FirstName='azerty', LastName = 'test2', AccountId = acc.Id, Email = 'test2@test.fr');
		insert ct;

		Order order = new Order(Name = 'test', AccountId = acc.Id, EffectiveDate = Date.today(),
		                        Provenance__c = 'ShareIt', Status = 'Version préliminaire', Contact_lie__c = ct.Id);
		insert order;

		Flexera_Key__c key = new Flexera_Key__c(Name = 'test', Contact__c = ct.Id, Date_limite__c = Date.today(), Quantity__c = 3,
		                                        Order__c = order.Id, Entitlement_Id__c = 'test');
		insert key;

		PageReference pg = Page.FlexeraSendKeyByEmail;
		pg.getParameters().put('keys_id', key.Id);
		pg.getParameters().put('is_update', 'false');
		Test.setCurrentPage(pg);

		FlexeraSendKeyByEmailController controller = new FlexeraSendKeyByEmailController();
		controller.InstanciatePart1();
		controller.InstanciatePart2();
		controller.Preview();
		for (FlexeraSendKeyByEmailController.WrapperContact wpContact : controller.WpContacts) {
			wpContact.ContactEmail = wpContact.ContactsAccountEmails[0].getValue();
		}
		controller.Send();
		controller.getIsAnnualFR();
		controller.getIsPerpetualFR();
		controller.getIsAnnualEN();
		controller.getIsPerpetualEN();
	}
}