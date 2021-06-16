public  without sharing class CL001_OrderProcessingFromCustomPayment {
    
    private static Order order;
    
    public static void updateOrderFromCustomPayment(String orderNumber, String customerToken, String PaymentIntentToken, String chargeToken, String paymentMethod){
        List<String> StatusOrder = System.Label.StatusCustomPayment.split(';');
        List<Order> orders = [
				SELECT Type, CustomOriginalOrder__c, Account.Type, Account.BillingCountryCode, Account.PersonContactId, Domaine_utilisateur__c,
						Status, Type_licence__c, Contact_lie__r.Email, Client_final__r.Email, AccountId, Contact_lie__c,
						Client_final__c, MyAccount_Auto__c, CurrencyIsoCode
				FROM Order WHERE OrderNumber = :orderNumber AND Status IN :StatusOrder
		];
        
        order = orders[0];
        
        // Ajout des infos fournies par Stripe sur le paiement
		order.customerToken__c = customerToken;
		order.PaymentToken__c = PaymentIntentToken;
		order.chargeToken__c = chargeToken;
		order.Paymentmethod__c = paymentMethod;
        order.Paid__c = true;
        order.IsFromStripe__c = true;
        order.PayementDateInStripe__c = Date.today();
		update order;
    }

}