trigger quoteLanguage on Quote (before insert) {
    for(Quote quote : Trigger.New){
        Opportunity opportunity = [SELECT Account.BillingCountryCode from Opportunity WHERE Id = :quote.OpportunityId limit 1];
    
        if(opportunity.Account.BillingCountryCode != 'fr'){
            quote.GenerateFactureEN__c = true;
        }
    }
}