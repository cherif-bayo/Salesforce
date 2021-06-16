trigger currencyUpdate on Opportunity (before insert) {
	  for(Opportunity opp : Trigger.new) {
          
       List<String> AddinsoftIncCurrencyIsoCode = System.Label.addinsoftIncCurrency.split(';');
	   boolean isUs = AddinsoftIncCurrencyIsoCode.contains(opp.OpportunityCountryCode__c);
          if (isUs){
              opp.CurrencyIsoCode = 'USD';
          }
       
    }
}