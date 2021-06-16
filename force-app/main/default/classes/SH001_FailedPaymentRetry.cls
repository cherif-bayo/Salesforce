public with sharing class SH001_FailedPaymentRetry implements Schedulable {
    public SH001_FailedPaymentRetry () {
    }

    public void execute(SchedulableContext ctx) {
        Datetime min = Datetime.now().addMonths(-1);
        Datetime max = Datetime.now();
        List<Order> failedPaymentOrders = [Select Id, PaymentAttempt__c from Order Where
        Status = :ParametersForOrders.ORDER_STATUS_ABANDONNE
        and Provenance__c = 'Stripe Renewal'
        and Type_licence__c = :ParametersForOrders.SEND_KEY_LICENSE_TYPE_1
        and CustomOriginalOrder__c  != NULL
        and customerToken__c != NULL
        and Paymentmethod__c != NULL
        and HasUpdatePaymentMethod__c = true                                  
        and ActivatedDate >=  :min  and ActivatedDate <= :max
        and PaymentAttempt__c < :Integer.valueOf(Parameters.getString('MaxPaymentAttempt'))];
			
        System.debug('[SH001_FailedPaymentRetry] failedPaymentOrders : '+ failedPaymentOrders );

        for (Order o :failedPaymentOrders) {
            o.PaymentAttempt__c += 1;
            System.enqueueJob(new PaymentStripeFacadeQueuable(o));
        }
        
        update failedPaymentOrders;
    }
}