/**
 * Order Trigger Hanlder
 */
public with sharing class OrderTriggerHandler {
	
	private final sObject mysObject;

	// The extension constructor initializes the private member
	// variable mysObject by using the getRecord method from the standard
	// controller.
	//public OrderTriggerHandler(ApexPages.StandardController stdController) {
	public OrderTriggerHandler() {
		//this.mysObject = (sObject)stdController.getRecord();
	}

	/**
	 * [OnBeforeInsert description]
	 * @param newOrder [description]
	 */
	public void OnBeforeInsert(Order newOrder){
		if(neworder.Formations__c != null){
			newOrder.HasDiscount__c = false;
		}
	}
	
	/**
	 * [OnAfterInsert description]
	 * @param newOrder [description]
	 */
	public void OnAfterInsert(Order newOrder){
		if(neworder.Formations__c != null){
			Campaign c = [SELECT Id, Total_Turnover__c, CurrencyIsoCode FROM Campaign WHERE Id = :newOrder.Formations__c LIMIT 1];

			if(c.Total_Turnover__c == null){
				c.Total_Turnover__c = getMontantHorsFrais(c,newOrder);
			} else {
				c.Total_Turnover__c += getMontantHorsFrais(c,newOrder);
			}

			try {
				update c;
			} catch(Exception e) {
				System.debug(e.getMessage());
			}
		}
	}

	/**
	 * [OnBeforeUpdate description]
	 * @param oldOrder [description]
	 * @param newOrder [description]
	 */
	public void OnBeforeUpdate(Order oldOrder, Order newOrder){
		if(neworder.Formations__c != null){
			newOrder.HasDiscount__c = false;
		}
	}

	/**
	 * [OnAfterUpdate description]
	 * @param oldOrder [description]
	 * @param newOrder [description]
	 */
	public void OnAfterUpdate(Order oldOrder, Order newOrder){
		if(neworder.Formations__c != null){
			Campaign c = [SELECT Id, Total_Turnover__c, CurrencyIsoCode FROM Campaign WHERE Id = :newOrder.Formations__c LIMIT 1];
			
			if(c.Total_Turnover__c == null){
				c.Total_Turnover__c = getMontantHorsFrais(c,newOrder);
			} else {
				c.Total_Turnover__c -= getMontantHorsFrais(c,oldOrder);
				c.Total_Turnover__c += getMontantHorsFrais(c,newOrder);
			}

			try {
				update c;
			} catch(Exception e) {
				System.debug(e.getMessage());
			}
		}
	}

	/**
	 * [OnBeforeDelete description]
	 * @param oldOrder [description]
	 */
	public void OnBeforeDelete(Order oldOrder){
		if(oldOrder.Formations__c != null){
			Campaign c = [SELECT Id, Total_Turnover__c, CurrencyIsoCode FROM Campaign WHERE Id = :oldOrder.Formations__c LIMIT 1];
			
			if(c.Total_Turnover__c != null){
				c.Total_Turnover__c -= getMontantHorsFrais(c,oldOrder);
			}			

			try {
				update c;	
			} catch(Exception e) {
				System.debug(e.getMessage());
			}
		}
	}

	/**
	 * [getMontantHorsFrais description]
	 * @param  c [description]
	 * @param  o [description]
	 * @return   [description]
	 */
	private Decimal getMontantHorsFrais(Campaign c, Order o){
		if(c.CurrencyIsoCode == 'EUR'){
			return o.Montant_Hors_FraisEUR__c;
		}else if (c.CurrencyIsoCode == 'USD') {
			return o.Montant_Hors_FraisUSD__c;
		}else if (c.CurrencyIsoCode == 'GBP') {
			return o.Montant_Hors_FraisGBP__c;
		}else if (c.CurrencyIsoCode == 'JPY') {
			return o.Montant_Hors_FraisJPY__c;
		}else {
			return null;
		}
	}
}