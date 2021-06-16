@IsTest
private class TestStripeSetupIntentWebhook {
	@testSetup
    public static void setup() {
        Account account = new Account(Name = 'test');
        insert account;
        
        Contact contact = new Contact(LastName = 'test', AccountId = account.Id, email = 'test@addinsoft.com');
        insert contact;
        
        Id orderId = HelperTestData.createOrderWithProductWithContact(contact);
    }
    
    @Istest
    public static void testSetupItent() {
        Order order = [Select OrderNumber, CustomerToken__c, Paymentmethod__c from Order limit 1];
        System.debug('[testFailedPayment] order.OrderNumber : '+ order.OrderNumber);

        StaticResource resource = [SELECT Body FROM StaticResource WHERE Name = 'jsonStripeSetupIntent'];
        String body = resource.body.toString();

        RestRequest request = new RestRequest();
        request.requestUri = Url.getSalesforceBaseUrl() + '/services/apexrest/webhooks/setupintent/v1/';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(body);

        RestContext.request = request;

        User uStripe = [Select Id from User where name = 'stripe Site Guest User' limit 1];
        Test.startTest();
        StripeSetupIntentWebhook.doPost();
        Test.stopTest();

        Order updatedOrder = [Select CustomerToken__c,PaymentToken__c,Paymentmethod__c
                 from Order where CustomerToken__c= :order.CustomerToken__c];
        System.assertEquals( null ,updatedOrder.Paymentmethod__c);
        System.assertEquals(null ,updatedOrder.CustomerToken__c);
       
    }
}