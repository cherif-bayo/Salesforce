@RestResource(urlMapping = '/webhooks/paymentfailed/v1/*')
global without sharing class StripePaymentFailedWebhook {

    @HttpPost
    global static void doPost() {
        RestRequest req = RestContext.request;
        System.debug('[StripePaymentFailedWebhook] request =' + req);

        Map<String, Object> o = (Map<String, Object>) SYSTEM.JSON.deserializeUntyped(req.requestBody.toString());
        Map<String, Object> data = (Map<String, Object>) o.get('data');
        Map<String, Object> obj = (Map<String, Object>) data.get('object');

        updateOrderWithPaymentFailed(obj);
    }

    private static void updateOrderWithPaymentFailed(Map<String, Object> obj) {

        // Récupération du payment token
        String paymentToken = String.valueOf(obj.get('id'));
        System.debug('[StripePaymentFailedWebhook] updateOrderWithPaymentFailed paymentToken=' + paymentToken);

        // Récupération des infos sur le dernier paiement
        Map<String, Object> payment = (Map<String, Object>) obj.get('last_payment_error');

        // Récupération du code et du message d'erreur
        String errorDeclineCode = String.valueOf(payment.get('decline_code'));
        System.debug('[StripePaymentFailedWebhook] updateOrderWithPaymentFailed errorDeclineCode=' + errorDeclineCode);
        String errorCode = String.valueOf(payment.get('code'));
        System.debug('[StripePaymentFailedWebhook] updateOrderWithPaymentFailed errorCode=' + errorCode);
        String errorMessage = String.valueOf(payment.get('message'));
        System.debug('[StripePaymentFailedWebhook] updateOrderWithPaymentFailed errorMessage=' + errorMessage);
        String lastErrorCode = errorCode;
        if (!String.isBlank(errorDeclineCode)) {
            lastErrorCode += ' (' + errorDeclineCode + ')';
        }

        // Recuperation du customer Token
        Map<String, Object> paymentMethod = (Map<String, Object>) payment.get('payment_method');
        String customerToken = String.valueOf(paymentMethod.get('customer'));
        System.debug('[StripePaymentFailedWebhook] updateOrderWithPaymentFailed customerToken=' + customerToken);
        String paymentMethodId = String.valueOf(paymentMethod.get('id'));
        System.debug('[StripePaymentFailedWebhook] updateOrderWithPaymentFailed paymentMethodId=' + paymentMethodId);

        // Recuperation du numero de commande
        Map<String, Object> metadata = (Map<String, Object>) obj.get('metadata');
        String salesforce_order_id = (String) metadata.get('salesforce_order_id');
        System.debug('[StripePaymentFailedWebhook] updateOrderWithPaymentFailed salesforce_order_id=' + salesforce_order_id);

        // Recuperation du charge Id

        // MAJ de la commande dans salesforce
        if (salesforce_order_id != null) {
            Order order = [select PaymentAttempt__c from Order where OrderNumber= :salesforce_order_id limit 1];
            if (order != null) {
                order.PaymentAttempt__c += 1;
                order.LastErrorCode__c = lastErrorCode;
                order.LastErrorMessage__c = errorMessage;
                order.customerToken__c = customerToken;
                order.PaymentToken__c = paymentToken;
                order.Paymentmethod__c = paymentMethodId;
            }

            update order;
        }
    }
}