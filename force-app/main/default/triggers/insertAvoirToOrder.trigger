trigger insertAvoirToOrder on Avoir__c (after insert, after update, after delete) {
    Order order;
    if(Trigger.isDelete){
        order = [select Id, Avoir_Ref__c, Avoir_Date__c, Avoir_Montant__c from Order where Id = :Trigger.old[0].Commande_lie__c limit 1];
    }else{
        order = [select Id, Avoir_Ref__c, Avoir_Date__c, Avoir_Montant__c from Order where Id = :Trigger.new[0].Commande_lie__c limit 1];
    }
    
    String avoirNames = null;
    DateTime avoirDate = null;
    Decimal avoirMontants = 0;
    Decimal avoirMontantsToOrder = 0;
    Avoir__c[] avoirs = [select Name, Montant__c, CreatedDate, Commande_lie__c, Impact_Order_Price__c from Avoir__c where Commande_lie__c = :order.Id order by CreatedDate desc];
    
    if(avoirs.size() > 0){
        avoirDate = avoirs[0].CreatedDate;
        for(Avoir__c avoir : avoirs){
            if(avoirNames != null){
                avoirNames = avoirNames + ', ' + avoir.Name;
            }else{
                avoirNames = avoir.Name;
            }
            avoirMontants = avoirMontants + avoir.Montant__c;
            if(avoir.Impact_Order_price__c == true){
                avoirMontantsToOrder += avoir.Montant__c;
            }
        }
    }
    
    order.Avoir_Montant__c = avoirMontants;
    order.Montant_Avoir__c = avoirMontantsToOrder;
    order.Avoir_Date__c = avoirDate;
    order.Avoir_Ref__c = avoirNames;
    
    update order;
}