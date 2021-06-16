@isTest(seeAllData=false)
public class Test_StripeWebhookListener {
	static Order order;
	@testSetup
	public static void setup() {
		Account account = new Account(Name = 'test');
		insert account;

		Contact contact = new Contact(LastName = 'test', AccountId = account.id, email = 'test@addissoft.com');
		insert contact;

		Id orderId = HelperTestData.createOrderWithProductWithContact(contact);

		Facture__c facture = new Facture__c();
		facture.Commande_lie__c = orderId;
		insert facture;
	
		Opportunity opp = new Opportunity(AccountId = account.id, Amount = 700, CurrencyIsoCode = 'EUR', Name = 'opportunityTest', StageName = 'Proposition de valeur	', CloseDate = Date.today());
		insert opp;
            
		Quote quote = new Quote(Name = 'QuoteTest', OpportunityId = opp.Id, Status = 'Version préliminaire', CurrencyIsoCode = 'EUR', Pricebook2Id = Test.getStandardPricebookId());
		insert quote;

	}

	@IsTest
	public static void testRefund() {
		Order order = [Select OrderNumber from Order limit 1];
       
		StaticResource resource = [SELECT Body FROM StaticResource WHERE Name = 'jsonStripeWebHook'];
		String body = resource.body.toString();
		body = body.replace('XXXXX', order.OrderNumber);
        
		RestRequest request = new RestRequest();
		request.requestUri = Url.getSalesforceBaseUrl() + '/services/apexrest//webhooks/v1/';
		request.httpMethod = 'POST';
		request.requestBody = Blob.valueOf(body);

		RestContext.request = request;

		User uStripe = [Select Id from User where name = 'stripe Site Guest User' limit 1];
		Test.startTest();
		System.runAs(uStripe) {
			StripeWebhookListener.doPost();
		}
    
		Test.stopTest();
        
        Order o = [select customerToken__c, paymentToken__c, chargeToken__c from Order limit 1];
		System.debug('[Test_StripeWebhookListener] payment test order = ' + o);
	}

	@IsTest
	public static void testPaymentIntent() {
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('jsonCryptlexMockLicenceCreation');
		mock.setStatusCode(201);
		mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
		Test.setMock(HttpCalloutMock.class, mock);

		Order order = [Select OrderNumber from Order limit 1];
		StaticResource resource = [SELECT Body FROM StaticResource WHERE Name = 'jsonStripeWebHookPaymentIntent'];
		String body = resource.body.toString();
		body = body.replace('XXXXX', order.OrderNumber);

		RestRequest request = new RestRequest();
		request.requestUri = Url.getSalesforceBaseUrl() + '/services/apexrest/webhooks/v1/';
		request.httpMethod = 'POST';
		request.requestBody = Blob.valueOf(body);

		RestContext.request = request;

		User uStripe = [Select Id from User where name = 'stripe Site Guest User' limit 1];
		Test.startTest();
		System.runAs(uStripe) {
			StripeWebhookListener.doPost();
		}
		Test.stopTest();

		Order o = [select customerToken__c, paymentToken__c, chargeToken__c from Order limit 1];
		System.debug('[Test_StripeWebhookListener] payment test order = ' + o);
	}

	@IsTest
	public static void testQuotePayed() {
		Quote quote = [Select QuoteNumber, QuotePaymentIntentToken__c, QuoteCustomerToken__c, QuotePaymentMethod__c, QuoteChargeToken__c from Quote limit 1];
		StripeWebhookListener.setQuotePayed(quote.QuoteNumber, quote.QuotePaymentIntentToken__c, quote.QuoteCustomerToken__c, quote.QuotePaymentMethod__c, quote.QuoteChargeToken__c);
	}
    
}