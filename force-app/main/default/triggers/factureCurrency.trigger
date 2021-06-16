trigger factureCurrency on Facture__c (before insert, before update) {

    public static final Id FR_RECORD_TYPE_ID = Schema.SObjectType.Facture__c.getRecordTypeInfosByName().get('FR').getRecordTypeId();
    public static final Id US_RECORD_TYPE_ID = Schema.SObjectType.Facture__c.getRecordTypeInfosByName().get('US').getRecordTypeId();
    public static List<Facture__c> factures = Trigger.new;
    public static List<Id> idOrdersLiee = new List<Id>();
    public static Map<Id, Order> orders;
    public List<AggregateResult> aggregateResultsFR = [SELECT MAX(FRInvoiceNumber__c) maxInvoiceFR FROM Facture__c WHERE FRInvoiceNumber__c != NULL];
    public List<AggregateResult> aggregateResultsUS = [SELECT MAX(USInvoiceNumber__c) maxInvoiceUS FROM Facture__c WHERE USInvoiceNumber__c != NULL];
    public Decimal maxInvoiceUS = aggregateResultsUS.get(0).get('maxInvoiceUS') != null ? (Decimal) aggregateResultsUS.get(0).get('maxInvoiceUS') : 0;
    public Decimal maxInvoiceFR = aggregateResultsFR.get(0).get('maxInvoiceFR') != null ? (Decimal) aggregateResultsFR.get(0).get('maxInvoiceFR') : 0;

    for (Facture__c facture : factures) {
        idOrdersLiee.add(facture.Commande_lie__c);
    }
    orders = new Map<Id, Order>([SELECT Id, CurrencyIsoCode, AddinSoftCompany__c, Account.BillingCountryCode FROM Order WHERE Id IN :idOrdersLiee]);
    for (Facture__c facture : factures) {
        Order order = orders.get(facture.Commande_lie__c);
        facture.CurrencyIsoCode = order.CurrencyIsoCode;
        if (Trigger.isInsert) {
            facture.AddinSoftCompany2__c = order.AddinSoftCompany__c;
            if (ParametersForOrders.FR_COMPANY.equals(facture.AddinSoftCompany2__c)) {
                facture.FRInvoiceNumber__c = maxInvoiceFR != 0 ? maxInvoiceFR + 1 : Integer.valueOf(Label.startSequenceFactureFR);
                facture.RecordTypeId = FR_RECORD_TYPE_ID;
                facture.FR_Invoice_Code__c =  'FR-'+String.valueOf(facture.FRInvoiceNumber__c).leftPad(8,'0');
                maxInvoiceFR = facture.FRInvoiceNumber__c;
            } else {
                facture.USInvoiceNumber__c = maxInvoiceUS != 0 ? maxInvoiceUS + 1 : Integer.valueOf(Label.startSequenceFactureUS);
                facture.RecordTypeId = US_RECORD_TYPE_ID;
                facture.US_Invoice_Code__c =  'US-'+String.valueOf(facture.USInvoiceNumber__c).leftPad(8,'0');
                maxInvoiceUS = facture.USInvoiceNumber__c;
            }
            if (order.Account.BillingCountryCode != 'fr') {
                facture.GenerateFactureEN__c = true;
            }
        }
    }
}