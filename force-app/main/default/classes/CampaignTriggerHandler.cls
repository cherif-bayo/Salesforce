/**
 * Campaign Trigger Handler
 */
public with sharing class CampaignTriggerHandler {
	
	private final sObject mysObject;

	// The extension constructor initializes the private member
	// variable mysObject by using the getRecord method from the standard
	// controller.
	//public OrderTriggerHandler(ApexPages.StandardController stdController) {
	public CampaignTriggerHandler() {
		//this.mysObject = (sObject)stdController.getRecord();
	}

	/**
	 * [OnAfterUpdate description]
	 * @param [description]
	 * @param [description]
	 */
	public void OnBeforeUpdate(Campaign oldCampaign, Campaign newCampaign){
		UpdateProfitEUR(newCampaign);
	}

	/**
	 * [OnBeforeInsert description]
	 * @param [description]
	 * @param [description]
	 */
	public void OnBeforeInsert(Campaign newCampaign){
		UpdateProfitEUR(newCampaign);
	}

	/**
	 * [UpdateProfitEUR description]
	 * @param newCampaign [description]
	 */
	private void UpdateProfitEUR(Campaign newCampaign){
		//Update Benefice EUR
		if(newCampaign.CurrencyIsoCode == 'EUR'){
			newCampaign.Profit_EUR__c = newCampaign.Profit__c;
		}else{
			System.System.debug(newCampaign);
			Decimal rate = [SELECT Rate__c FROM Currencies_Exchange_Rates__c WHERE Day__c = today AND CurrencyIsoCode = :newCampaign.CurrencyIsoCode LIMIT 1].Rate__c;
			if(rate != null){
				newCampaign.Profit_EUR__c = newCampaign.Profit__c / rate;
			}
		}
	}
}