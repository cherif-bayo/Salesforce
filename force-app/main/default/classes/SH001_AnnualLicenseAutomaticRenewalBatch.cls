public class SH001_AnnualLicenseAutomaticRenewalBatch implements Schedulable {

    public static boolean isRenewal = false;
    
    public SH001_AnnualLicenseAutomaticRenewalBatch() {}
    
    public void execute(System.SchedulableContext ctx) {
        isRenewal = true;
        Datetime min = Datetime.now().addYears(-1).addHours(-1);
        Datetime max = Datetime.now().addYears(-1);
        //Datetime min = Datetime.now().addDays(-5).addHours(-2).addMinutes(-30);
        //Datetime max = Datetime.now().addDays(-5);
        //Datetime min = Datetime.now().addHours(-4);
        //Datetime max = Datetime.now();
        //Datetime min = Datetime.now().addMinutes(-45);
        //Datetime max = Datetime.now();

        List<Order> originalOrders = [Select customerToken__c, Paymentmethod__c, Domaine_utilisateur__c, paymentType__c, Status, Provenance__c, AccountId, Type, BillingCity, 
                                      BillingStateCode, BillingStreet, BillingPostalCode, ShippingStateCode, ShippingStreet, Type_licence__c, 
                                      ShippingCity, ShippingPostalCode, ShippingCountryCode, BillingCountryCode, Discount_Client_Activated__c, 
                                      Client_final__c, Contact_lie__c,CurrencyIsoCode 
                                      from Order Where
                                      Status = 'Payée'
                                      and Provenance__c = 'Stripe'
                                      and ActivatedDate >=  :min  and ActivatedDate <= :max
                                      and Autorenewalable__c = true
                                      and Type_licence__c = :ParametersForOrders.SEND_KEY_LICENSE_TYPE_1
                                      and Renouvele__c = false];
        System.debug('Number of renewals : '+ originalOrders.size());
        System.debug('Original Orders : '+ originalOrders );
        
        List<Order> newOrders = new List<Order>();
        for (Order originalOrder : originalOrders) {
            Order newOrder = createNewOrderFrom(originalOrder);
            newOrder.Status = ParametersForOrders.ORDER_STATUS_ABANDONNE;
            newOrders.add(newOrder);
            originalOrder.Renouvele__c = true; 
            System.debug('NewOrder '+ newOrder);
            System.enqueueJob(new PaymentStripeFacadeQueuable(newOrder));
            

        }
        update originalOrders;
        update newOrders;
    }
    
    public Order createNewOrderFrom(Order originalOrder) {
        
        /***************************** creation nouvelle commande ****************************************************************/
        Order order = new Order(Pricebook2Id = UtilsCQP.getStdPricebookId());
        order.Status = 'Version préliminaire';
        order.EffectiveDate = Date.today();
        order.Provenance__c = 'Stripe Renewal';
        order.Renouvele__c = false;
        order.Renewal_Auto__c = true;
        order.CustomOriginalOrder__c = originalOrder.Id;
        
        // Clone existing account attribute
        order.AccountId = originalOrder.AccountId;
        order.type = originalOrder.type;
        order.Client_Final__c = originalOrder.Client_Final__c;
        order.Contact_Lie__c = originalOrder.Contact_Lie__c;
        order.Discount_Client_Activated__c = originalOrder.Discount_Client_Activated__c;
        order.BillingCountryCode = originalOrder.BillingCountryCode;
        order.BillingPostalCode = originalOrder.BillingPostalCode;
        order.BillingStreet = originalOrder.BillingStreet;
        order.BillingStateCode = originalOrder.BillingStateCode;
        order.BillingCity = originalOrder.BillingCity;
        order.ShippingCountryCode = originalOrder.ShippingCountryCode;
        order.ShippingPostalCode = originalOrder.ShippingPostalCode;
        order.ShippingStreet = originalOrder.ShippingStreet;
        order.ShippingStateCode = originalOrder.ShippingStateCode;
        order.ShippingCity = originalOrder.ShippingCity;
        order.CurrencyISOCode = originalOrder.currencyISOCode;
        order.Type_licence__c = originalOrder.Type_licence__c;
        order.Domaine_utilisateur__c = originalOrder.Domaine_utilisateur__c;
        order.paymentType__c = originalOrder.paymentType__c;
        order.customerToken__c = originalOrder.customerToken__c;
        order.Paymentmethod__c = originalOrder.Paymentmethod__c;
        
        insert order;
        
        /********************* creation  des lignes de commandes *************************************************************/
        List<OrderItem> originalOrdersItems = [select UnitPrice, Quantity, PricebookEntryId from OrderItem where OrderId = :originalOrder.Id];
        List<OrderItem> ordersItems = new List<OrderItem> ();
        For (OrderItem originalOrderItem : originalOrdersItems) {
            orderItem orderItem = new OrderItem();
            orderItem.OrderId = order.Id;
            orderItem.Quantity = originalOrderItem.Quantity;
            orderItem.PricebookEntryId = originalOrderItem.PricebookEntryId;
            orderItem.UnitPrice = originalOrderItem.UnitPrice;
            
            ordersItems.add(orderItem);
            System.debug('[#CL001_UTL_OrderCreationInSF] orderItems :' + orderItem);
        }
        insert ordersItems;

        System.debug('[#CL001_UTL_OrderCreationInSF] order :' + order);
        
        return order;
    }
}