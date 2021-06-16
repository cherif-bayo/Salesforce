/**
 * Opportunity Trigger Handler
 */
public with sharing class OpportunityTriggerHandler {

	private final sObject mysObject;

	// The extension constructor initializes the private member
	// variable mysObject by using the getRecord method from the standard
	// controller.
	//public OpportunityTriggerHandler(ApexPages.StandardController stdController) {
	public OpportunityTriggerHandler() {
	}

	/**
	 * [OnAfterInsert description]
	 * @param newOpportunity [description]
	 */
	public void OnAfterInsert(Opportunity newOpportunity){
		//Opportunity of Campaign		
		if(newOpportunity.Campaign_FK__c != null){
			Campaign currentCampaign = [SELECT Id, Name, Opportunity_Total__c, Opportunity_CloseWon__c, Opportunity_ProposalEstimate__c FROM Campaign WHERE Id = :newOpportunity.Campaign_FK__c LIMIT 1];

			if(newOpportunity.StageName == 'Close gagnée'){
				currentCampaign.Opportunity_CloseWon__c += 1;
			}else if(newOpportunity.StageName == 'Proposition/Devis'){
				currentCampaign.Opportunity_ProposalEstimate__c += 1;
			}

			currentCampaign.Opportunity_Total__c += 1;

			try {
				update currentCampaign;
			} catch(Exception e) {
				System.debug(e.getMessage());
			}
		}
	}

	/**
	 * [OnAfterUpdate description]
	 * @param oldOpportunity [description]
	 * @param newOpportunity [description]
	 */
	public void OnAfterUpdate(Opportunity oldOpportunity, Opportunity newOpportunity){
		//Opportunity of Campaign		
		if(oldOpportunity.Campaign_FK__c != null){
			Campaign oldCampaign = [SELECT Id, Name, Opportunity_Total__c, Opportunity_CloseWon__c, Opportunity_ProposalEstimate__c FROM Campaign WHERE Id = :oldOpportunity.Campaign_FK__c LIMIT 1];

			if(oldOpportunity.StageName == 'Close gagnée'){
				oldCampaign.Opportunity_CloseWon__c -= 1;
			}else if(oldOpportunity.StageName == 'Proposition/Devis'){
				oldCampaign.Opportunity_ProposalEstimate__c -= 1;
			}

			try {
				update oldCampaign;
			} catch(Exception e) {
				System.debug(e.getMessage());
			}

        } if(newOpportunity.Campaign_FK__c != null) {
			Campaign currentCampaign = [SELECT Id, Name, Opportunity_Total__c, Opportunity_CloseWon__c, Opportunity_ProposalEstimate__c FROM Campaign WHERE Id = :newOpportunity.Campaign_FK__c LIMIT 1];
			if(newOpportunity.StageName == 'Close gagnée'){
				currentCampaign.Opportunity_CloseWon__c += 1;
			}else if(newOpportunity.StageName == 'Proposition/Devis'){
				currentCampaign.Opportunity_ProposalEstimate__c += 1;
			}

			try {
				update currentCampaign;
			} catch(Exception e) {
				System.debug(e.getMessage());
			}
		}
	}

	/**
	 * [OnAfterDelete description]
	 * @param oldOpportunity [description]
	 */
	public void OnAfterDelete(Opportunity oldOpportunity){
		//Opportunity of Campaign		
		if(oldOpportunity.Campaign_FK__c != null){
			Campaign currentCampaign = [SELECT Id, Name, Opportunity_Total__c, Opportunity_CloseWon__c, Opportunity_ProposalEstimate__c FROM Campaign WHERE Id = :oldOpportunity.Campaign_FK__c LIMIT 1];

			currentCampaign.Opportunity_Total__c -= 1;

			try {
				update currentCampaign;
			} catch(Exception e) {
				System.debug(e.getMessage());
			}
		}
	}
}