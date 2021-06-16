@isTest
public class Test_OrderLineItemTaxes {
	
	@testSetup
	static void setup() {
		Account acc = new Account (name='company');
		insert acc;

		Contact ct = new Contact (AccountId=acc.Id, LastName='testName');
		insert ct;

		HelperTestData.createOrderWithProductWithContact(ct);
        
        Order o = [select Id from Order limit 1];
		o.BillingCity = 'Paris';
		o.Billingcountry = 'FRANCE';
		o.BillingPostalCode = '33800';
		o.BillingStreet = 'Rue Des Chais';
		o.us_tax_exemption_certificate_id__c = 'A250-05';
		update o;  
	}

	@isTest
	static void testJob() {
		Order o = [select Id from Order limit 1];
		
		OrderItem oi = [Select OrderItemNumber from OrderItem limit 1];
		TaxamoCalloutMock mock = new TaxamoCalloutMock(oi);

		// startTest/stopTest block to force async processes 
		//   to run in the test.
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, mock);
        OrderLineItemTaxes olt = new OrderLineItemTaxes(o.Id,true);
		System.enqueueJob(olt);
		Test.stopTest();		
	}
}