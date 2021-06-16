/**
 * Order Controller TEST
 */
@isTest
private class OrderController_TEST
{	
	/**
	 * Data Setup for the test
	 */
	@testSetup static void setup(){
		Test.startTest();
        
        insert new Currencies_Exchange_Rates__c (Day__c = Date.today(),CurrencyIsoCode='USD',Rate__c=1.0);        

		//Create common test Account
		Account acc = new Account();
			acc.Type = 'Client';
			acc.Domaine_utilisateur__c = 'Academic';
			acc.FirstName = 'Camille';
			acc.LastName = 'Honnet';
			acc.PersonEmail = 'camille.honnet@email.com';
		insert acc;
		
		Account acc02 = new Account();
			acc02.Name = 'Test';
			acc02.Domaine_Utilisateur__c = 'Student';
		insert acc02;

		//Create common test Contact
		Contact con = new Contact();
			con.FirstName = 'Axel';
			con.LastName = 'Air';
			con.Email = 'axel.air@email.com';
			con.AccountId = acc02.Id;
		insert con;

		//Create common test Campaign
		Campaign campaign = new Campaign();
			campaign.Name = 'Formation Apex';
			campaign.Type = 'Formation';
			Campaign.CurrencyIsoCode = 'USD';
		insert campaign;

		//Create common test 
		Currencies_Exchange_Rates__c rate = new Currencies_Exchange_Rates__c();
			rate.Day__c = Date.today();
			rate.CurrencyIsoCode = 'USD';
			rate.Rate__c = 1;
		insert rate;
		
		//Create common test PriceBook
		Pricebook2 pricebook = new Pricebook2();
			pricebook.Name = 'PriceBookTEST';
			pricebook.CurrencyIsoCode = 'USD';
			pricebook.CurrencyIsoCode__c = 'USD';
		insert pricebook;
		
		//Create common test Product
		Product2 product = new Product2();
			product.Name = 'F_Product';
			product.Type_Licence__c = 'N.A.';
			product.Domaine_Utilisateur__c = 'N.A.';
			product.ProductCode = 'F_XLSTAT_FR';
			product.Family = 'Formation';
		insert product;
		
		//Create common test PriceBookEntry
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
			pe.UseStandardPrice = true;
		insert pe;

		Test.stopTest();
	}

	/**
	 * [itShould description]
	 */
	@isTest static void testMethod_AddOrderFormation(){
		Order order = new Order();
		order.Contact_Lie__c = [SELECT Id FROM Contact WHERE Email = 'axel.air@email.com' LIMIT 1].Id;

		Campaign campaign = [SELECT Id FROM Campaign WHERE Name = 'Formation Apex' LIMIT 1];

		PageReference pageRef = Page.Order_NewOrderForFormation;
		pageRef.getParameters().put('Campaign', campaign.Id);
		System.debug(pageRef);

		Test.setCurrentPage(pageRef);

		ApexPages.StandardController sc = new ApexPages.StandardController(order);
		OrderController oc = new OrderController(sc);

		//System.

		oc.save();

		delete [SELECT Id FROM Order WHERE Contact_Lie__r.Email = 'axel.air@email.com' LIMIT 1];
	}
}