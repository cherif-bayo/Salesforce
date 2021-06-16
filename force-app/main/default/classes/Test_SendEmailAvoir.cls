@isTest
public class Test_SendEmailAvoir {

	@TestSetup
	public static void setup() {
		Account acc = new Account (Name='test');
		insert acc;

		Contact ct = new Contact (lastName='test', accountId = acc.Id);
		insert ct;
        
        Order order = new Order();
        order.AccountId = acc.Id;
        order.Client_Final__c = ct.Id;
        order.EffectiveDate = Date.today();
        order.Domaine_Utilisateur__c = 'Company';
        order.CurrencyIsoCode='USD';
        order.Status = 'Version préliminaire';
        order.HasPersonAccountAndCompanyDomain__c = true;
        insert order;

		//HelperTestData.createOrderWithProductWithContact(ct);

		Avoir__c avoir = new Avoir__c(Montant__c = 100, Libelle__c = 'Remboursement Stripe');
		Order commande = [select Id  from Order LIMIT 1];
		avoir.Commande_lie__c = commande.Id;
		
		insert avoir;
	}

	@IsTest
	public static void test() {
		Avoir__c avoir = [select Id from Avoir__c LIMIT 1];
		SCH001_SendEmailAvoir emailAvoir = new SCH001_SendEmailAvoir(avoir.Id);
		emailAvoir.execute(null);
	}

}