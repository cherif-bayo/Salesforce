/**
 * Opportunity Trigger Handler _ TEST
 */
@isTest
private class OpportunityTriggerHandler_TEST {

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

		//Create common test Campaign
		Campaign campaign = new Campaign();
			campaign.Name = 'Formation Apex';
			campaign.Type = 'Formation';
			campaign.CurrencyIsoCode = 'USD';
		insert campaign;

		Test.stopTest();
	}

	/**
	 * Field updated in Campaign's object
	 */
	@isTest static void testMethod_UpdateCampaign(){
		Opportunity opp = new Opportunity();
			opp.Name = 'MyOpportunity';
			opp.Account = [SELECT Id FROM Account WHERE PersonEmail = 'camille.honnet@email.com' LIMIT 1];
			opp.Type = 'Test';
			opp.CurrencyIsoCode = 'USD';
			opp.CloseDate = Date.today() + 90;
			opp.StageName = 'Proposition/Devis';
			opp.Campaign_FK__c = [SELECT Id FROM Campaign WHERE Name = 'Formation Apex' LIMIT 1].Id;
		insert opp;

		opp.StageName = 'Close gagnée';
		update opp;

		delete opp;

		System.debug(opp);
	}
}