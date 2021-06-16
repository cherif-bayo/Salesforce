@isTest
public class Test_QuoteLineItemTaxes {
	
	@testSetup
	static void setup() {
		HelperTestData.createQuoteWithProductWithContact();

		Quote q = [select Id from Quote limit 1];
		q.BillingCity = 'Paris';
		q.Billingcountry = 'FRANCE';
		q.BillingPostalCode = '33800';
		q.BillingStreet = 'rue dickinson';
		q.us_tax_exemption_certificate_id__c = 'ZZZ';
		update q;  
	}

	@isTest
	static void testJob() {		
        Quote q = [select Id from Quote limit 1];
        QuoteLineItem qli = [Select Id from QuoteLineItem limit 1];
		TaxamoCalloutMock mock = new TaxamoCalloutMock(qli);	
        
        Test.startTest();
		Test.setMock(HttpCalloutMock.class, mock);
        QuoteLineItemTaxes qlt = new QuoteLineItemTaxes(new List<Quote> {q});
        qlt.makeCallout = false;
		System.enqueueJob(qlt);
		Test.stopTest();		
	}
    
    @isTest
	static void testCallOut() {
        Quote q = [select Id from Quote limit 1];
        QuoteLineItem qli = [Select LineNumber from QuoteLineItem limit 1];
		TaxamoCalloutMock mock = new TaxamoCalloutMock(qli);	
        
        Test.startTest();        
		Test.setMock(HttpCalloutMock.class, mock);
		QuoteLineItemTaxes qlt = new QuoteLineItemTaxes(new List<Quote> {q});
        qlt.performCallout();
		Test.stopTest();	
    }
    
}