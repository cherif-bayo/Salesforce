public class PaymentStripeFacadeQueuable implements queueable,Database.AllowsCallouts {
        public static string STRIPE_ENDPOINT_PI = 'https://api.stripe.com/v1/payment_intents';
    
    private Order order;
    
    public PaymentStripeFacadeQueuable(Order order) {
        this.order = [SELECT Montant_Hors_Frais__c, CurrencyIsoCode, TotalAmountAfterTva__c, customerToken__c, Paymentmethod__c, PaymentToken__c, Is_Failed_Payment__c, OrderNumber FROM Order WHERE Id = :Order.Id ];
    }
    
    public void execute(QueueableContext ctx) {
        // Création du payload pour le paiement STRIPE (utilisation du customer.default_source)
        Decimal total = order.TotalAmountAfterTva__c;
        if (order.CurrencyIsoCode != 'JPY'){
            total *= 100;
        }
        String payload = 'amount=' + Math.Floor(total);
        payload += '&currency='+order.CurrencyIsoCode;
        payload += '&customer='+order.customerToken__c;
        payload += '&off_session=true'; // indicate that the customer is not in your checkout flow during this payment attempt
        payload += '&confirm=true'; // causes confirmation to occur immediately when the PaymentIntent is created
        payload += '&metadata[salesforce_order_id]='+order.OrderNumber;
        payload += '&payment_method='+order.Paymentmethod__c;
        System.debug('Payload ' + payload );
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(STRIPE_ENDPOINT_PI);
        request.setMethod('POST');
        request.setHeader('Content-Type','application/x-www-form-urlencoded');
        request.setHeader('Authorization', 'Bearer ' + StripeFacade.API_PRIVATE_KEY);
        request.setBody(payload);
        HttpResponse response = http.send(request);
        if (response.getStatusCode() != 200) {
            System.debug('Le paiement Stripe pour la commande ' + order.orderNumber + ' n\'a pu être prélevé');
            insert new WS_Error__c(WebserviceName__c = 'Stripe', Request__c = 'Le paiement Stripe pour la commande ' + order.orderNumber + ' n\'a pu être prélevé');
            order.Is_Failed_Payment__c = true;
            update order;
        }
    }
}