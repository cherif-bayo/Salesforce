/**
 * Order Trigger Handler _ TEST
 */
@isTest
private class OrderTriggerHandler_TEST
{
	/**
	 * Data Setup for the test
	 */
	@testSetup static void setup() {
		Test.startTest();

		//Create common test Contact
		Account acc = new Account();
			acc.Type = 'Client';
			acc.Domaine_utilisateur__c = 'Academic';
			acc.FirstName = 'Camille';
			acc.LastName = 'Honnet';
			acc.PersonEmail = 'camille.honnet@email.com';
		insert acc;

		//Create common test Campaign
		Currencies_Exchange_Rates__c currencyExchangeRate01 = new Currencies_Exchange_Rates__c();
			currencyExchangeRate01.Name = 'N001';
			currencyExchangeRate01.Rate__c = 1.179;
			currencyExchangeRate01.CurrencyIsoCode = 'USD';
			currencyExchangeRate01.Day__c = Date.today();
		insert currencyExchangeRate01;

		Currencies_Exchange_Rates__c currencyExchangeRate02 = new Currencies_Exchange_Rates__c();
			currencyExchangeRate02.Name = 'N003';
			currencyExchangeRate02.Rate__c = 130.179;
			currencyExchangeRate02.CurrencyIsoCode = 'JPY';
			currencyExchangeRate02.Day__c = Date.today();
		insert currencyExchangeRate02;

		//Create common test Campaign
		Campaign campaign = new Campaign();
			campaign.Name = 'Formation Apex';
			campaign.Type = 'Formation';
			campaign.CurrencyIsoCode = 'USD';
		insert campaign;

		Test.stopTest();
	}


	/**
	 * Field Update (Operating system, nb of download) testing
	 */
	@isTest static void testMethod_SumOrder() {
		Campaign c = [SELECT Id, Name FROM Campaign WHERE Name = 'Formation Apex' LIMIT 1];
		System.debug(c);

		Order order = new Order();
			order.AccountId = [SELECT Id FROM Account WHERE FirstName = 'Camille' LIMIT 1].Id;
			order.Formations__c = c.Id;
			order.Domaine_utilisateur__c = 'N.A.';
			order.EffectiveDate = Date.today();
			order.Status = 'Version préliminaire';
		insert order;

		order.EffectiveDate = Date.today()+10;
		update order;

		c.CurrencyIsoCode = 'EUR';
		update c;
		update order;

		c.CurrencyIsoCode = 'JPY';
		update c;
		update order;

		System.debug(order);

		delete order;
	}
}