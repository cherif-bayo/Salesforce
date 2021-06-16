@IsTest
public class OrderUnpaidEmailBatchableTest {

	@TestSetup
	public static void setup() {

		System.runAs(new User(Id = UserInfo.getUserId())) {
			EmailTemplate validEmailTemplate = new EmailTemplate();
			validEmailTemplate.isActive = true;
			validEmailTemplate.Name = 'test US';
			validEmailTemplate.DeveloperName = 'test';
			validEmailTemplate.TemplateType = 'text';
			validEmailTemplate.FolderId = UserInfo.getUserId();
			validEmailTemplate.HtmlValue = 'test';
			validEmailTemplate.Body = 'test';

			insert validEmailTemplate;
		}

		Currencies_Exchange_Rates__c rate = new Currencies_Exchange_Rates__c();
		rate.Day__c = Date.today();
		rate.CurrencyIsoCode = 'USD';
		rate.Rate__c = 1;

		insert rate;

		Pricebook2 pricebook = new Pricebook2();
		pricebook.Name = 'Test';
		pricebook.CurrencyIsoCode = 'USD';

		insert pricebook;

		Product2 product = new Product2();
		product.CurrencyIsoCode = 'USD';
		product.Name = 'Test';

		insert product;

		PricebookEntry pes = new PricebookEntry();
		pes.Product2Id = product.Id;
		pes.Pricebook2Id = Test.getStandardPricebookId();
		pes.CurrencyIsoCode = 'USD';
		pes.UnitPrice = 10;

		insert pes;

		PricebookEntry pe = new PricebookEntry();
		pe.Product2Id = product.Id;
		pe.CurrencyIsoCode = 'USD';
		pe.Pricebook2Id = pricebook.Id;
		pe.UnitPrice = 10;

		insert pe;

		Relance__c relance = new Relance__c();
		relance.Nb_Days__c = 0;
		relance.Template_Email__c = 'test';
		relance.Order_Status__c = '1ere Relance';

		insert relance;

		Account account = new Account();
		account.PersonEmail = 'test@test.com';
		account.FirstName = 'test';
		account.LastName = 'test';

		insert account;

		Order order = new Order();
		order.AccountId = account.Id;
		order.EffectiveDate = Date.today();
		order.Pricebook2Id = pricebook.Id;
		order.CurrencyIsoCode = 'USD';
		order.Status = 'Version préliminaire';

		insert order;

		OrderItem orderItem = new OrderItem();
		orderItem.PricebookEntryId = pe.Id;
		orderItem.OrderId = order.Id;
		orderItem.Quantity = 1;
		orderItem.UnitPrice = 10;

		insert orderItem;

		order.Status = 'Validée';
		update order;

		Facture__c facture = new Facture__c();
		facture.Date__c = Date.today();
		facture.Commande_Lie__c = order.Id;

		insert facture;

		Attachment att = new Attachment();
		att.Name = 'Test';
		att.ParentId = facture.Id;
		att.Body = Blob.valueof('Test');
		att.ContentType = 'text/plain';

		insert att;
	}

	@isTest
	public static void testSchedulable() {

		Test.StartTest();
		Database.executeBatch(new OrderUnpaidEmailBatchable(), 1);
		Test.StopTest();

		Order order = [SELECT Facturation_Date_1ere_relance__c, Facturation_Statut__c FROM Order Limit 1];

		Relance__c relance = [select Order_Status__c from Relance__c Limit 1];

		System.assertEquals(order.Facturation_Statut__c, relance.Order_Status__c);
		System.assertEquals(order.Facturation_Date_1ere_relance__c.day(), Date.today().day());
		System.assertEquals(order.Facturation_Date_1ere_relance__c.month(), Date.today().month());
		System.assertEquals(order.Facturation_Date_1ere_relance__c.year(), Date.today().year());

		String jobId = System.schedule('ScheduleApexClassTest', '0 0 0 15 3 ? 2022', new OrderUnpaidEmailSchedulable());
	}


	@isTest
	public static void testSchedulableWithEmailFacturation() {

		List<Order> orders = [select Id from Order];
		if (orders.size()>0) orders[0].Facturation_MailContact__c = 'test@test.fr';
		update orders;

		Test.StartTest();
		Database.executeBatch(new OrderUnpaidEmailBatchable(), 1);
		Test.StopTest();
	}
}