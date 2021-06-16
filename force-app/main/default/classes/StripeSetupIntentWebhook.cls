@RestResource(urlMapping = '/webhooks/setupintent/v1/*')
global without sharing class StripeSetupIntentWebhook {
	@HttpPost
	global static void doPost() {
		RestRequest req = RestContext.request;
		System.debug('[StripeWebhookListener] req=' + req);

		Map<String, Object> o = (Map<String, Object>) SYSTEM.JSON.deserializeUntyped(req.requestBody.toString());
		Map<String, Object> data = (Map<String, Object>) o.get('data');
        Map<String, Object> obj = (Map<String, Object>) data.get('object');
		
        getCustomerPaymentMethod(obj);

	}
    
    private static void getCustomerPaymentMethod(Map<String, Object> obj) {

        // Récupération du payment Method token
        String paymentMethodToken = String.valueOf(obj.get('payment_method'));
        System.debug('[StripeSetupIntentWebhook] updateOrderWithPaymentFailed paymentMethodToken=' + paymentMethodToken);
        
         // Récupération du customer token
        String CustomerToken = String.valueOf(obj.get('customer'));
        System.debug('[StripeSetupIntentWebhook] updateOrderWithPaymentFailed CustomerToken=' + CustomerToken);


        // MAJ de la commande dans salesforce
        if (CustomerToken != null) {
            List<Order> orders = [select Id, Paymentmethod__c from Order where customerToken__c= :CustomerToken ];
            System.debug(orders);
            if (orders.size() > 0 ) {
                for (Order order : orders) {
       				order.Paymentmethod__c = paymentMethodToken;
                    order.HasUpdatePaymentMethod__c	 = true;
                    update orders;
    			}
            } 
        }
    }
}