@isTest
public class Test_StripeWebhookListenerDup {
    
    private static String SOLUTION_NAME_TEST = 'XLSTAT-Base';
    
	@testSetup
    public static void setup(){
        Account acc = new Account(Name='TestOrderProcessing');
        insert acc;
        
        Contact  ct = new Contact(LastName = 'testCherif', AccountId = acc.Id, email ='baymed2007@gmail.com');
        insert ct;
        
       	Pricebook2 pricebook = new Pricebook2();
		pricebook.Name = 'Test';

		insert pricebook;

		Product2 product = new Product2(IsActive = true, Name = 'XLSTAT-Base', ProductCode = 'S_BAS_CMP_AN', Family = 'Solution',
		                                CurrencyIsoCode = 'USD', Domaine_utilisateur__c = 'Campus', Type_licence__c = 'Annuelle');
		insert product;
        
        PricebookEntry pes2 = new PricebookEntry();
		pes2.Product2Id = product.Id;
		pes2.Pricebook2Id = Test.getStandardPricebookId();
		pes2.UnitPrice = 10;
		pes2.CurrencyIsoCode = 'USD';
		insert pes2;
        
        PricebookEntry pe = new PricebookEntry();
		pe.Product2Id = product.Id;
		pe.Pricebook2Id = pricebook.Id;
		pe.UnitPrice = 10;
		pe.CurrencyIsoCode = 'USD';
		insert pe;
        
        Order order = new Order();
		order.AccountId = acc.Id;
		order.EffectiveDate = Date.today();
		order.Pricebook2Id = pricebook.Id;
		order.CurrencyIsoCode = 'USD';
		order.BillingCountry = 'France';
		order.Status = 'Version préliminaire';
		insert order;
        
        OrderItem orderItem = new OrderItem();
		orderItem.PricebookEntryId = pe.Id;
		orderItem.OrderId = order.Id;
		orderItem.Quantity = 1;
		orderItem.UnitPrice = 10;
		insert orderItem;
        
        Facture__c fct = new Facture__c();
        fct.Commande_lie__c = order.Id;
        insert fct;
        
        Opportunity opp = new Opportunity(AccountId = acc.id, Amount = 700, CurrencyIsoCode = 'EUR', Name = 'opportunityTest', StageName = 'Proposition de valeur	', CloseDate = Date.today());
		insert opp;
        
		Quote quote = new Quote(Name = 'QuoteCherif', OpportunityId = opp.Id, Status = 'Validée', CurrencyIsoCode = 'USD', Pricebook2Id = Test.getStandardPricebookId());
		insert quote;
    }
    
    @IsTest
	public static void testRefund() {
        
        StaticResource resource = [SELECT Body FROM StaticResource WHERE Name = 'jsonStripeWebHook'];
        String body = resource.body.toString();
		body = body.replace('XXXXX', 'XXXXX');
        
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
	}
    
    @IsTest
	public static void testPaymentIntent() {
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('jsonCryptlexMockLicenceCreation');
		mock.setStatusCode(201);
		mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
		Test.setMock(HttpCalloutMock.class, mock);

		//Order order = [Select Id, OrderNumber from Order limit 1];
		StaticResource resource = [SELECT Body FROM StaticResource WHERE Name = 'jsonStripeWebHookPaymentIntent'];
		String body = resource.body.toString();
		body = body.replace('XXXXX', 'XXXXX');

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