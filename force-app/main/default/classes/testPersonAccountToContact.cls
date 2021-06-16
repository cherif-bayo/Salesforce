@isTest
public class testPersonAccountToContact {

	@TestSetup
	public static void setup() {
		Account acc = new Account(FirstName = 'test', LastName = 'test');
		insert acc;

		HelperTestData.createOrderWithProductWithPersonalAccount(acc);

		Account acc2 = new Account(Name = 'test');
		insert acc2;

		Contact ct = new Contact(lastName = 'test', accountId = acc2.Id);
		insert ct;

		Order order = new Order(Contact_lie__c = ct.Id, AccountId = ct.AccountId, EffectiveDate = Date.today(), Status = 'Version préliminaire', Domaine_utilisateur__c = 'Company',
		                        Type_licence__c = 'Annuelle', CurrencyIsoCode = 'EUR', Pricebook2Id = Test.getStandardPricebookId());
		insert order;
	}

	@isTest
	public static void testConvert() {
		Account personAccount = [SELECT Id FROM Account WHERE IsPersonAccount = true limit 1];
		ApexPages.StandardController sc = new ApexPages.standardController(personAccount);
		PersonAccountToContactExtension ext = new PersonAccountToContactExtension(sc);
		ext.Order = [SELECT AccountId FROM Order where Account.IsPersonAccount = false limit 1];

		ext.Convert();
	}
}