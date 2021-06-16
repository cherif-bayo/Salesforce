trigger insertTotalPriceAfterDiscount on OrderItem (before insert, before update, after delete) {
    private static Decimal CURRENCY_EUR_RATE = 1.00;
    private static String CURRENCY_EUR = 'EUR';   
    private static String CURRENCY_USD = 'USD';   
    private static String CURRENCY_JPY = 'JPY';   
    private static String CURRENCY_GBP = 'GBP';                

    if(Trigger.isDelete){
        Order order = [select Type_licence__c, Id, HasDiscount__c, MontantModule__c, MontantSolution__c, MontantFormation__c, MontantExpertise__c, MontantShipping__c, MontantSupport__c from Order where Id = :Trigger.old[0].OrderId];
        
        Boolean hasDiscount = false;
        
        order.MontantModule__c = 0;
        order.MontantSolution__c = 0;
        order.MontantFormation__c  = 0;
        order.MontantExpertise__c = 0;
        order.MontantSupport__c = 0;
        order.MontantShipping__c = 0;
        
        for(OrderItem oi:[select PricebookEntry.Product2.Type_licence__c, Percent_Discount_Total__c, PricebookEntry.Product2.Id, PricebookEntry.Product2.Family, TotalPriceAfterDiscountShowed__c from OrderItem where OrderId = :Trigger.old[0].OrderId]){
            if(oi.Percent_Discount_Total__c != null) hasDiscount = true;

            if(oi.PricebookEntry.Product2.Family == 'Module'){
                order.MontantModule__c = order.MontantModule__c + oi.TotalPriceAfterDiscountShowed__c;
            }else if(oi.PricebookEntry.Product2.Family == 'Solution'){
                order.MontantSolution__c = order.MontantSolution__c + oi.TotalPriceAfterDiscountShowed__c;
            }else if(oi.PricebookEntry.Product2.Family == 'Formation'){
                order.MontantFormation__c = order.MontantFormation__c + oi.TotalPriceAfterDiscountShowed__c;
            }else if(oi.PricebookEntry.Product2.Family == 'Expertise'){
                order.MontantExpertise__c = order.MontantExpertise__c + oi.TotalPriceAfterDiscountShowed__c;
            }else if(oi.PricebookEntry.Product2.Family == 'Support'){
                order.MontantSupport__c = order.MontantSupport__c + oi.TotalPriceAfterDiscountShowed__c;
            }else if(oi.PricebookEntry.Product2.Family == 'Shipping'){
                order.MontantShipping__c = order.MontantShipping__c + oi.TotalPriceAfterDiscountShowed__c;
            }

            if(oi.PricebookEntry.Product2.Type_licence__c != 'N.A.'){
                if(oi.PricebookEntry.Product2.Type_licence__c == 'Small Campus' || oi.PricebookEntry.Product2.Type_licence__c == 'Large Campus'){
                    order.Type_licence__c = 'Campus';
                }else if(oi.PricebookEntry.Product2.Type_licence__c == 'Extension support et mise à jour ( 1 an )'){
                    order.Type_licence__c = 'Support et maintenance ( 1 an )';
                }else{
                    order.Type_licence__c = oi.PricebookEntry.Product2.Type_licence__c;
                }
            }
        }
        
        if(order.HasDiscount__c != hasDiscount) order.HasDiscount__c = hasDiscount;        
        update order;
		if (ParametersForOrders.US_COMPANY.equals(order.AddinSoftCompany__c)) System.enqueueJob(new OrderLineItemTaxes(order.Id,false)); // Pas d'enregistrement de la transaction dans Taxamo
    } else { // insert or update orderItem
        List<OrderItem> orderItemsToUpdate = new List<OrderItem>();
        List<String> pricebookEntriesIds = new List<String>();
		Set<Id> orderIds = new Set<Id>();
        for(OrderItem orderItem : Trigger.new){
            if(Trigger.isUpdate){ // Update OrderItem
                Decimal oldPrice = Trigger.oldMap.get(orderItem.Id).ListPrice;
                Decimal newPrice = orderItem.ListPrice;
                
                Decimal oldUnitPrice = Trigger.oldMap.get(orderItem.Id).UnitPrice;
                Decimal newUnitPrice = orderItem.UnitPrice;
                
                Decimal oldQuantity = Trigger.oldMap.get(orderItem.Id).Quantity;
                Decimal newQuantity = orderItem.Quantity;
                
                if(oldPrice != newPrice || oldUnitPrice != newUnitPrice || oldQuantity != newQuantity){
                    orderItemsToUpdate.add(orderItem);
                    pricebookEntriesIds.add(orderItem.PricebookEntryId);
					orderIds.add(orderItem.OrderId);
                }
            }else if(Trigger.isInsert){
                System.debug('insertTotalPriceAfterDiscount#orderItem : '+orderItem);
                orderItemsToUpdate.add(orderItem);
                pricebookEntriesIds.add(orderItem.PricebookEntryId);
				orderIds.add(orderItem.OrderId);
            }
        }

        System.debug('insertTotalPriceAfterDiscount#pricebookEntriesIds : '+pricebookEntriesIds);
        System.debug('insertTotalPriceAfterDiscount#orderItemsToUpdate : '+orderItemsToUpdate);

        // Pas de discount sur les renewal
        if (!SH001_AnnualLicenseAutomaticRenewalBatch.isRenewal) OrderItemDiscount.UpdateDiscounts(true, orderItemsToUpdate, pricebookEntriesIds);

		// Gestion des taxes taxamo (uniquement si il existe une commande pour Addinsoft Company)
		List<Order> allOrders = [select AddinSoftCompany__c from Order where Id in :orderIds];
		for (Order order :allOrders) if (ParametersForOrders.US_COMPANY.equals(order.AddinSoftCompany__c)) System.enqueueJob(new OrderLineItemTaxes(order.Id,false));	
    }
}