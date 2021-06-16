@isTest (SeeAllData=true)

public class testChangeCurrencyIsoCodeOpportunity{
    public static testMethod void testMain(){
        Opportunity opportunity = [select Id, CurrencyIsoCode from Opportunity where CurrencyIsoCode = 'EUR' and SyncedQuoteId = null limit 1];
        
        Test.setCurrentPage(Page.ChangeOpportunityCurrencyExtension);

        // call the constructor
        ChangeOpportunityCurrencyExtension controller = new ChangeOpportunityCurrencyExtension(new ApexPages.StandardController(opportunity));
        controller.CurrencyIsoCode = 'USD';
        controller.changeOrderCurrencyIsoCode();
    }
}