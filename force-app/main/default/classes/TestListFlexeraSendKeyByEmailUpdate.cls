@isTest
public class TestListFlexeraSendKeyByEmailUpdate  {
	@TestSetup
	public static void setup() {
		Account acc = new Account(Name = 'test');
		insert acc;

		Contact ct = new Contact(LastName = 'test', AccountId = acc.Id, email = 'test@test.fr');
		insert ct;

		Order order = new Order(Name = 'test', AccountId = acc.Id, EffectiveDate = date.today(), Status = 'Version préliminaire');
		insert order;

		insert new Flexera_Key__c(Name = 'test', Contact__c = ct.Id, Date_limite__c = date.today(), Quantity__c = 3,
		                          Order__c = order.Id, Entitlement_Id__c = 'test');
	}

	@isTest
	public static void main() {
		Order order = [SELECT Id, Status FROM Order WHERE Name = 'test'];
		Flexera_Key__c key = [select Id from Flexera_Key__c where Order__c = :order.Id and Contact__c != null limit 1];

		PageReference pg = Page.ListFlexeraSendKeyByEmailUpdate;
		Test.setCurrentPage(pg);
		ApexPages.StandardSetController sc = new ApexPages.StandardSetController(new List<Flexera_Key__c> { key });
		sc.setSelected(new List<Flexera_Key__c> { key });
		ListFlexeraSendKeyByEmailUpdate controller = new ListFlexeraSendKeyByEmailUpdate(sc);
		controller.callFlexeraSendKeyByEmailUpdate();
	}

	@isTest
	public static void listeVide() {
		Order order = [SELECT Id, Status FROM Order WHERE Name = 'test'];
		Flexera_Key__c key = [select Id from Flexera_Key__c where Order__c = :order.Id and Contact__c != null limit 1];

		PageReference pg = Page.ListFlexeraSendKeyByEmailUpdate;
		Test.setCurrentPage(pg);
		ApexPages.StandardSetController sc = new ApexPages.StandardSetController(new List<Flexera_Key__c> { key });
		ListFlexeraSendKeyByEmailUpdate controller = new ListFlexeraSendKeyByEmailUpdate(sc);
		controller.callFlexeraSendKeyByEmailUpdate();
	}

	@isTest
	public static void cancel() {
		Order order = [SELECT Id, Status FROM Order WHERE Name = 'test'];
		Flexera_Key__c key = [select Id from Flexera_Key__c where Order__c = :order.Id and Contact__c != null limit 1];

		PageReference pg = Page.ListFlexeraSendKeyByEmailUpdate;
		Test.setCurrentPage(pg);
		ApexPages.StandardSetController sc = new ApexPages.StandardSetController(new List<Flexera_Key__c> { key });
		ListFlexeraSendKeyByEmailUpdate controller = new ListFlexeraSendKeyByEmailUpdate(sc);
		controller.cancel();
	}
}