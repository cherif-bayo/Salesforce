@IsTest
public class testSendEmailStu {

	@TestSetup
	public static void setup() {
		/*User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
		System.runAs(thisUser)
		{
			HelperTestData.createTemplates();
		}*/

		Account acc = new Account(Name = 'test');
		insert acc;

		Contact ct = new Contact(LastName = 'test', AccountId = acc.Id, Email = 'lbeaubier@xlstat.com');
		insert ct;

		HelperTestData.createOrderWithProductWithContact(ct);

		Order o = [SELECT Id FROM Order LIMIT 1];
		o.Status = 'Payée';
		o.Domaine_utilisateur__c = 'Student';
		update o;
	}



	@IsTest
	public static void testContact() {
		Contact contact = [SELECT Id FROM Contact LIMIT 1];
		Order order = [SELECT Domaine_utilisateur__c FROM Order LIMIT 1];
		Account account = [SELECT Id FROM Account LIMIT 1];

		List<Flexera_Key__c> keys = new List<Flexera_Key__c>();
		Flexera_Key__c flexeraKeyXlStat = new Flexera_Key__c();
		flexeraKeyXlStat.Contact__c = contact.Id;
		flexeraKeyXlStat.XLSTAT_Solution__c = 'XLStat-Basic';
		flexeraKeyXlStat.Software__c = 'XLSTAT';
		flexeraKeyXlStat.SoftwareCode__c = '00';
		flexeraKeyXlStat.Order__c = order.Id;
		flexeraKeyXlStat.Quantity__c = 1;
		flexeraKeyXlStat.Date_limite__c = Date.today().addYears(1);
		flexeraKeyXlStat.Domaine_utilisateur__c = order.Domaine_utilisateur__c;

		Flexera_Key__c flexeraKeyXlRisk = new Flexera_Key__c();
		flexeraKeyXlRisk.Contact__c = contact.Id;
		flexeraKeyXlRisk.XLSTAT_Solution__c = 'XLRisk';
		flexeraKeyXlRisk.Software__c = 'XLRISK';
		flexeraKeyXlRisk.SoftwareCode__c = '01';
		flexeraKeyXlRisk.Order__c = order.Id;
		flexeraKeyXlRisk.Quantity__c = 1;
		flexeraKeyXlRisk.Date_limite__c = Date.today().addYears(1);
		flexeraKeyXlRisk.Domaine_utilisateur__c = order.Domaine_utilisateur__c;

		keys.add(flexeraKeyXlStat);
		keys.add(flexeraKeyXlRisk);
		insert keys;


		ApexPages.StandardController sc = new ApexPages.StandardController(order);
		SendEmailStuExtension ext = new SendEmailStuExtension(sc);

		PageReference pageRef = Page.sendEmailStuExtension;
		Test.setCurrentPage(pageRef);

		ext.SendEmail();
		System.assertEquals(true, ext.EmailSent);

		contact.Langue__c = 'FR';
		update account;

		ext.SendEmail();
		System.assertEquals(true, ext.EmailSent);

		contact.MailingCountryCode = 'FR';
		update account;

		ext.SendEmail();

		System.assertEquals(true, ext.EmailSent);

	}

	@IsTest
	public static void testEDU() {

		Contact contact = [SELECT Id FROM Contact LIMIT 1];
		Order order = [SELECT Domaine_utilisateur__c FROM Order LIMIT 1];
		Account account = [SELECT Id FROM Account LIMIT 1];

		contact.Domaine_utilisateur__c = 'Academic';
		contact.Langue__c = 'FR';
		update contact;

		List<Flexera_Key__c> keys = new List<Flexera_Key__c>();
		Flexera_Key__c flexeraKeyXlStat = new Flexera_Key__c();
		flexeraKeyXlStat.Contact__c = contact.Id;
		flexeraKeyXlStat.XLSTAT_Solution__c = 'XLStat-Basic';
		flexeraKeyXlStat.Software__c = 'XLSTAT';
		flexeraKeyXlStat.SoftwareCode__c = '00';
		flexeraKeyXlStat.Order__c = order.Id;
		flexeraKeyXlStat.Quantity__c = 1;
		flexeraKeyXlStat.Date_limite__c = Date.today().addYears(1);
		flexeraKeyXlStat.Domaine_utilisateur__c = order.Domaine_utilisateur__c;

		Flexera_Key__c flexeraKeyXlRisk = new Flexera_Key__c();
		flexeraKeyXlRisk.Contact__c = contact.Id;
		flexeraKeyXlRisk.XLSTAT_Solution__c = 'XLRisk';
		flexeraKeyXlRisk.Software__c = 'XLRISK';
		flexeraKeyXlRisk.SoftwareCode__c = '01';
		flexeraKeyXlRisk.Order__c = order.Id;
		flexeraKeyXlRisk.Quantity__c = 1;
		flexeraKeyXlRisk.Date_limite__c = Date.today().addYears(1);
		flexeraKeyXlRisk.Domaine_utilisateur__c = order.Domaine_utilisateur__c;

		keys.add(flexeraKeyXlStat);
		keys.add(flexeraKeyXlRisk);
		insert keys;


		ApexPages.StandardController sc = new ApexPages.StandardController(order);
		SendEmailStuExtension ext = new SendEmailStuExtension(sc);

		PageReference pageRef = Page.sendEmailStuExtension;
		Test.setCurrentPage(pageRef);

		ext.SendEmail();
		System.assertEquals(true, ext.EmailSent);

		contact.Langue__c = 'US';
		update account;

		contact.MailingCountryCode = 'US';
		update account;

		ext.SendEmail();

		System.assertEquals(true, ext.EmailSent);

	}
}