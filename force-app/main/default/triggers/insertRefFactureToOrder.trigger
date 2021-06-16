trigger insertRefFactureToOrder on Facture__c (after insert, after update, after delete) {
    Order order;
    if(Trigger.isDelete){
        order = [select Id, R_f_Facture__c, Date_facture__c from Order where Id = :Trigger.old[0].Commande_lie__c limit 1];
    }else{
        order = [select Id, R_f_Facture__c, Date_facture__c from Order where Id = :Trigger.new[0].Commande_lie__c limit 1];
    }
    
    String refFacture = null;
    Date factureDate = null;
    Facture__c[] factures = [select Name, Date__c from Facture__c where Commande_lie__c = :order.Id order by Date__c desc];
    
    if(factures.size() > 0){
         factureDate = factures[0].Date__c;
         for(Facture__c facture : factures){
            if(refFacture != null){
                refFacture = refFacture + ', ' + facture.Name;
            }else{
                refFacture = facture.Name;
            }
        }
    }
    
    order.R_f_Facture__c = refFacture;
    order.Date_facture__c = factureDate;
    
    update order;
}