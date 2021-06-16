@IsTest
private class TestStripePaymentFailedWebhook {
    @testSetup
    public static void setup() {
        Account account = new Account(Name = 'test');
        insert account;

        Contact contact = new Contact(LastName = 'test', AccountId = account.id, email = 'test@addissoft.com');
        insert contact;

        Id orderId = HelperTestData.createOrderWithProductWithContact(contact);
    }

    @IsTest
    public static void testFailedPayment() {
        Order order = [Select OrderNumber from Order limit 1];
        System.debug('[testFailedPayment] order.OrderNumber : '+ order.OrderNumber);

        StaticResource resource = [SELECT Body FROM StaticResource WHERE Name = 'jsonStripePaymentFailedWebHook'];
        String body = resource.body.toString();
        body = body.replace('XXXXX', order.OrderNumber);

        RestRequest request = new RestRequest();
        request.requestUri = Url.getSalesforceBaseUrl() + '/services/apexrest/webhooks/paymentfailed/v1/';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(body);

        RestContext.request = request;

        User uStripe = [Select Id from User where name = 'stripe Site Guest User' limit 1];
        Test.startTest();
        StripePaymentFailedWebhook.doPost();
        Test.stopTest();

        Order updatedOrder = [Select PaymentAttempt__c,CustomerToken__c,PaymentToken__c,Paymentmethod__c,
                LastErrorCode__c, LastErrorMessage__c from Order where OrderNumber= :order.OrderNumber limit 1];
        System.assertEquals(1,updatedOrder.PaymentAttempt__c);
        System.assertEquals('cus_xxx',updatedOrder.CustomerToken__c);
        System.assertEquals('card_declined (lost_card)',updatedOrder.LastErrorCode__c);
        System.assertEquals('Your card has insufficient funds.',updatedOrder.LastErrorMessage__c);
        System.assertEquals('pi_1I0oSTDlc4BISCKmBf6QxkTZ',updatedOrder.PaymentToken__c);
        System.assertEquals('pm_1I0oUhDlc4BISCKmd0Gqfrv6',updatedOrder.Paymentmethod__c);
    }
}