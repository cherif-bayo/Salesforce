trigger updateKeyRelanceFromOrder on Order (after update) {
	Set<Id> ordersIds = new Set<Id>();
    List<Flexera_key__c> relanceOnKeyToUpdate = new List<Flexera_key__c>();
    List<Account> accountToUse = new List<Account>();
    List<Contact> contactToUse = new List<Contact>();
    
    for (Order order: Trigger.new) {
        Order oldOrders = Trigger.oldMap.get(order.Id);
        
        if (order.Autorenewalable__c != oldOrders.Autorenewalable__c && order.Autorenewalable__c == false) {
            ordersIds.add(order.Id);
        }
    }
    for (Flexera_key__c key: [SELECT Id, Relance_manuelle__c, Order__c FROM Flexera_key__c WHERE Order__c IN :ordersIds]) {
        if (key.Relance_manuelle__c != true) {
            key.Relance_manuelle__c = true;
            relanceOnKeyToUpdate.add(key);
        }
    }
    if (!relanceOnKeyToUpdate.isEmpty()) {update relanceOnKeyToUpdate;}
    
    
}