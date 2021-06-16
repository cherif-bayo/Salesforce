trigger updateFactureDistrib on Order (after update) {
    List<String> refsFactures = new List<String>();
    System.debug('[updateFactureDistrib] orders='+Trigger.new);

    for(Order order : Trigger.new){
        String oldIdFacture = Trigger.oldMap.get(order.Id).Ref_Facture_distributeur__c;
        String newIdFacture = order.Ref_Facture_distributeur__c;
        Decimal oldAmount = Trigger.oldMap.get(order.Id).TotalAmountAfterDiscountShowed__c;
        Decimal newAmount = order.TotalAmountAfterDiscountShowed__c;        
        
        if((oldIdFacture != newIdFacture || oldAmount != newAmount) && (oldIdFacture != null || newIdFacture != null)){
            if (newIdFacture != null) refsFactures.add(newIdFacture);
            if (oldIdFacture != null) refsFactures.add(oldIdFacture);
        }
    }
    System.debug('[updateFactureDistrib] refsFactures='+refsFactures);
	
    if(refsFactures.size() > 0){
        Map<String, List<Order>> ordersByFactureId = new Map<String, List<Order>>();
        List<String> currencies = new List<String>();
        for(Order order : [SELECT Id, Ref_Facture_distributeur__c, TotalAmountAfterDiscountEUR__c, TotalAmountAfterDiscountUSD__c, TotalAmountAfterDiscountJPY__c, TotalAmountAfterDiscountGBP__c, CurrencyIsoCode FROM Order WHERE Ref_Facture_distributeur__c in :refsFactures]){
            if(ordersByFactureId.containsKey(order.Ref_Facture_distributeur__c)){
                ordersByFactureId.get(order.Ref_Facture_distributeur__c).add(order);
            }else{
                ordersByFactureId.put(order.Ref_Facture_distributeur__c, new List<Order>{order});
            }
            
            currencies.add(order.CurrencyIsoCode);
        }
        
        Map<String, Facture_distributeur__c> factureById = new Map<String, Facture_distributeur__c>();
        List<String> currenciesFactures = new List<String>();
        for(Facture_distributeur__c facture : [SELECT Id, Montant_commandes_selectionnees__c, CurrencyIsoCode FROM Facture_distributeur__c WHERE Id in :refsFactures]){
            factureById.put(facture.Id, facture);
            currenciesFactures.add(facture.CurrencyIsoCode);
        }  
        
        for(String factureId : factureById.keySet()){
            Decimal amountNewFacture = 0;
            Facture_distributeur__c facture = factureById.get(factureId);
            
            if(ordersByFactureId.containsKey(factureId)){
                for(Order order : ordersByFactureId.get(factureId)){                
                    if(facture.CurrencyIsoCode == 'EUR'){
                        amountNewFacture += order.TotalAmountAfterDiscountEUR__c == null ? 0 : order.TotalAmountAfterDiscountEUR__c;
                    }else if(facture.CurrencyIsoCode == 'USD'){
                        amountNewFacture += order.TotalAmountAfterDiscountUSD__c == null ? 0 : order.TotalAmountAfterDiscountUSD__c;
                    }else if(facture.CurrencyIsoCode == 'JPY'){
                        amountNewFacture += order.TotalAmountAfterDiscountJPY__c == null ? 0 : order.TotalAmountAfterDiscountJPY__c;
                    }else if(facture.CurrencyIsoCode == 'GBP'){
                        amountNewFacture += order.TotalAmountAfterDiscountGBP__c == null ? 0 : order.TotalAmountAfterDiscountGBP__c;
                    }
                }
            }
            
            facture.Montant_commandes_selectionnees__c = amountNewFacture;
        }
        
        update factureById.values();
    }
}