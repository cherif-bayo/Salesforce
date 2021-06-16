trigger AvoirTrigger on Avoir__c (before insert) {

    private Map<Id, Order> ordersByIds = new Map<Id, Order> ();
    public static final Id FR_RECORD_TYPE_ID = Schema.SObjectType.Avoir__c.getRecordTypeInfosByName().get('FR').getRecordTypeId();
    public static final Id US_RECORD_TYPE_ID = Schema.SObjectType.Avoir__c.getRecordTypeInfosByName().get('US').getRecordTypeId();
    public List<AggregateResult> aggregateResultsUS = [SELECT MAX(USCreditNumber__c) maxAvoirUS FROM Avoir__c WHERE USCreditNumber__c != NULL];
    public List<AggregateResult> aggregateResultFR = [SELECT MAX(FRCreditNumber__c) maxAvoirFR FROM Avoir__c WHERE FRCreditNumber__c != NULL];
    public Decimal maxAvoirUS = aggregateResultsUS.get(0).get('maxAvoirUS') != null ? (Decimal) aggregateResultsUS.get(0).get('maxAvoirUS') : 0;
    public Decimal maxAvoirFR = aggregateResultFR.get(0).get('maxAvoirFR') != null ? (Decimal) aggregateResultFR.get(0).get('maxAvoirFR') : 0;

    if (Trigger.isInsert) {
        List<Id> ordersId = new List<Id>();
        List<Avoir__c> avoirs = Trigger.new;
        for (Avoir__c avoir : avoirs) {
            ordersId.add(avoir.Commande_lie__c);
        }
        for (Order order : [SELECT AddinSoftCompany__c FROM Order WHERE Id IN :ordersId]) {
            ordersByIds.put(order.Id, order);
        }
        for (Avoir__c avoir : avoirs) {
            if (ParametersForOrders.FR_COMPANY.equals(ordersByIds.get(avoir.Commande_lie__c).AddinSoftCompany__c)) {
                avoir.FRCreditNumber__c = maxAvoirFR != 0 ? maxAvoirFR + 1 : Integer.valueOf(Label.startSequenceAvoirFr);
                avoir.RecordTypeId = FR_RECORD_TYPE_ID;
                avoir.FR_Credit_Code__c =  'FR-'+String.valueOf(avoir.FRCreditNumber__c).leftPad(8,'0');
                maxAvoirFR = avoir.FRCreditNumber__c;
            } else if (ParametersForOrders.US_COMPANY.equals(ordersByIds.get(avoir.Commande_lie__c).AddinSoftCompany__c)) {
                avoir.USCreditNumber__c = maxAvoirUS != 0 ? maxAvoirUS + 1 : Integer.valueOf(Label.startSequenceAvoirUS);
                avoir.RecordTypeId = US_RECORD_TYPE_ID;
                avoir.US_Credit_Code__c =  'US-'+String.valueOf(avoir.USCreditNumber__c).leftPad(8,'0');
                maxAvoirUS = avoir.USCreditNumber__c;
            }
        }
    }
}