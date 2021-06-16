/**
 * Send Welcome Package Test
 */
@isTest
public class SendWelcomePackageTest{
	/* Variable Declaration */
	private static String SOLUTION_NAME_TEST = 'XLSTAT-Base';

	/**
	 * TEST SETUP
	 */
	@testSetup static void testSetup(){   
		//Create common test Currencies_Exchanges_Rates__c
		Currencies_Exchange_Rates__c rate = new Currencies_Exchange_Rates__c();
			rate.Day__c = Date.today();
			rate.CurrencyIsoCode = 'USD';
			rate.Rate__c = 1;
		insert rate;
	
		//Create common test PriceBook
		Pricebook2 pricebook = new Pricebook2();
			pricebook.Name = 'Test';
		insert pricebook;
		
		//Create common test Product2
		Product2 product = new Product2();
			product.Name = SOLUTION_NAME_TEST ;
			product.Family = 'Solution';
		insert product;
		
		//Create common test PriceBookEntry standard
		PricebookEntry pes = new PricebookEntry();
			pes.Product2Id = product.Id;
			pes.Pricebook2Id = Test.getStandardPricebookId();
			pes.UnitPrice = 10;
		insert pes;
		
		//Create common test PriceBookEntry
		PricebookEntry pe = new PricebookEntry();
			pe.Product2Id = product.Id;
			pe.Pricebook2Id = pricebook.Id;
			pe.UnitPrice = 10;
		insert pe;
		
		//Create common test Account
		Account account = new Account();
			account.Name = 'Jean Bonblanc';
		insert account;
	
		//Create common test Contact
		Contact contact = new Contact();
			contact.Email = 'jean.aimarre@email.com';
			contact.FirstName = 'Jean';
			contact.LastName = 'Aimarre';
			contact.Domaine_Utilisateur__c = 'Company';
			contact.Langue__c = 'FR';
			contact.AccountId = account.Id;
		insert contact;
		
		//Create common test Lead
		Lead lead = new Lead();
			lead.Email = 'jacques.ailaire@email.com';
			lead.FirstName = 'Jeacques';
			lead.LastName = 'Ailaire';
			lead.Domain__c = 'Professionnel';
			lead.Langue__c = 'FR';
		insert lead;
		
		//Create common test Order
		Order order = new Order();
			order.AccountId = account.Id;
			order.Contact_Lie__c = contact.Id;
			order.EffectiveDate = Date.today();
			order.Pricebook2Id = pricebook.Id;
			order.CurrencyIsoCode = 'USD';
			order.Status = 'Version préliminaire';
		insert order;
		
		//Create common test OrderItem
		OrderItem orderItem = new OrderItem();
			orderItem.PricebookEntryId = pe.Id;
			orderItem.OrderId = order.Id;
			orderItem.Quantity = 1;
			orderItem.UnitPrice = 10;
		insert orderItem;
		
		//Create common test Document
		Document document = new Document();
			document.ContentType = 'application/pdf';
			document.Name = 'Doc02';
			document.DeveloperName = 'Doc02';      
			document.Body = Blob.valueOf('Some Text');  
			document.FolderId = SendWelcomePackageController.PLAQUETTES_FOLDER_ID;
		insert document;
		
		//Create common test Plaquette__c
		Plaquette__c plaquette = new Plaquette__c();
			plaquette.Solution__c = product.Name;
			plaquette.Langue__c = contact.Langue__c;
			plaquette.Domaine__c = contact.Domaine_Utilisateur__c;
			plaquette.Texte_Email__c = 'test';
			plaquette.Texte_Email_Demo__c = 'test';
			plaquette.Sujet_Email__c = 'test';
			plaquette.Html_Email_Demo__c = 'test';        
			plaquette.Nom_Fichier__c = document.Name;
			plaquette.isDemo__c = false;
			plaquette.CurrencyIsoCode = 'USD';
		insert plaquette;
	}

	/**
	 * [testMethod_Contact description]
	 */
	 @isTest public static void testMethod_Contact(){   
		Contact contact = [SELECT Id FROM Contact LIMIT 1];
	
		PageReference tpageRef = Page.SendWelcomePackage;
		Test.setCurrentPage(tpageRef);
		
		ApexPages.currentPage().getParameters().put('contact_id', contact.Id);
		
		Test.startTest();
			SendWelcomePackageController controller = new SendWelcomePackageController();
			controller.UpdatePlaquette();
			controller.Cancel();
			controller.Send();
		Test.stopTest();
		
		System.assertEquals(1, [SELECT COUNT(Id) FROM Email__c WHERE Contact__c = :contact.Id].size());
	}
	
	/**
	 * [testMethod_Lead description]
	 */
	@isTest public static void testMethod_Lead(){   
		Lead lead = [SELECT Id FROM Lead LIMIT 1];
	
		PageReference tpageRef = Page.SendWelcomePackage;
		Test.setCurrentPage(tpageRef);
		
		ApexPages.currentPage().getParameters().put('lead_id', lead.Id);
		
		Test.startTest();
			SendWelcomePackageController controller = new SendWelcomePackageController();
			controller.Plaquette.Solution__c = SOLUTION_NAME_TEST ;
			controller.UpdatePlaquette();
			controller.Cancel();
			controller.Send();
		Test.stopTest();
		
		System.assertEquals(1, [SELECT COUNT(Id) FROM Email__c WHERE Lead__c = :lead.Id].size());
	}
}