@Istest
public class TestStripeFailedPaymentRetryBatch {
    
	@testSetup
    public static void setUp() {
        RecordType personAccountRecordType =  [SELECT Id FROM RecordType WHERE Name = 'Compte personnel' and SObjectType = 'Account'];
        Account newPersonAccount = new Account();
        newPersonAccount.FirstName = 'Cherif';
        newPersonAccount.LastName = 'Bayo';
        newPersonAccount.RecordType = personAccountRecordType;
        insert newPersonAccount;
        
        Pricebook2 pb = new Pricebook2(Name = 'Standard Price Book Addinsoft', Description = 'Price Book Addinsoft for new Products', IsActive = true );
    	insert pb;
        Product2 prod = new Product2(Name = 'OPT: XLOPTIM', IsActive = true);
    	insert prod;
        
        PricebookEntry pbe=new PricebookEntry(unitprice=0.01,Product2Id=prod.Id, Pricebook2Id=Test.getStandardPricebookId(), IsActive= true); 
     	insert pbe;
        
		Order order = new Order(AccountId = newPersonAccount.Id, EffectiveDate = Date.today(), Status = 'Version préliminaire', Domaine_utilisateur__c = 'Company',
		                        Type_licence__c = 'Annuelle', CurrencyIsoCode = 'EUR', BillingCountry='France', Pricebook2Id = Test.getStandardPricebookId());
		insert order;
        
        OrderItem oderLine = new OrderItem(OrderId = order.Id, Product2Id = prod.Id, PricebookEntryId = pbe.Id, UnitPrice = 11, Quantity = 5);
		insert oderLine; 
        
        List<Order> orders = new List<Order>();
        for (Integer i=0; i< 1 ; i++) {
            order.ActivatedDate = Datetime.now().addDays(-5).addHours(-1).addMinutes(5);
            order.Provenance__c = 'Stripe Renewal';
            order.Status =  'Payée';
            order.customerToken__c =  'cus_FZXd4JU2w571TO';
            order.Paymentmethod__c =  'pm_1F4OYrDlc4BISCKmgCTEsQTp';
            order.Autorenewalable__c = true;
            order.Type_licence__c = ParametersForOrders.SEND_KEY_LICENSE_TYPE_1;
            order.Renouvele__c = false;
            orders.add(order);
        }
        update orders;
    }
    
    @isTest
    public static void main() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStatusCode(200);
        mock.setStaticResource('jsonStripeWebHook'); // La réponse du WS n'a pas d'importance
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
        SH001_FailedPaymentRetry bt = new SH001_FailedPaymentRetry();
        Test.stopTest();

        bt.execute(null);
    }    
}