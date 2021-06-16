trigger insertTotalPriceAfterDiscountQuote on QuoteLineItem (before insert, before update, after delete) {

    if(Trigger.isDelete){ // Warning : pas compatible avec un delete en masse des QuoteLineItem!!!
        Quote quote = [select Type_licence__c, AddinSoftCompany__c, HasDiscount__c from Quote where Id = :Trigger.old[0].QuoteId];        
        Boolean hasDiscount = false;        
        for(QuoteLineItem oi:[select PricebookEntry.Product2.Type_licence__c, Percent_Discount_Total__c, PricebookEntry.Product2.Id, PricebookEntry.Product2.Family from QuoteLineItem where QuoteId = :Trigger.old[0].QuoteId]){
            if (oi.Percent_Discount_Total__c != null) hasDiscount = true;
            if (oi.PricebookEntry.Product2.Type_licence__c != 'N.A.'){
                if(oi.PricebookEntry.Product2.Type_licence__c == 'Small Campus' || oi.PricebookEntry.Product2.Type_licence__c == 'Large Campus'){
                    quote.Type_licence__c = 'Campus';
                }else if(oi.PricebookEntry.Product2.Type_licence__c == 'Extension support et mise à jour ( 1 an )'){
                    quote.Type_licence__c = 'Support et maintenance ( 1 an )';
                }else{
                    quote.Type_licence__c = oi.PricebookEntry.Product2.Type_licence__c;
                }
            }
        }        
        if(quote.HasDiscount__c != hasDiscount) quote.HasDiscount__c = hasDiscount;    				            		        
		update quote;
		if (ParametersForOrders.US_COMPANY.equals(quote.AddinSoftCompany__c)) System.enqueueJob(new QuoteLineItemTaxes(new List<Quote>{quote}));
    }else{
		Set<Id> quoteIds = new Set<Id>();
        List<QuoteLineItem> quoteItemsToUpdate = new List<QuoteLineItem>();

		// Gestion des discount et coupons
        List<String> pricebookEntriesIds = new List<String>();
        for(QuoteLineItem quoteItem : Trigger.new){
            if(Trigger.isUpdate){
                Decimal oldPrice = Trigger.oldMap.get(quoteItem.Id).ListPrice;
                Decimal newPrice = quoteItem.ListPrice;
                
                Decimal oldUnitPrice = Trigger.oldMap.get(quoteItem.Id).UnitPrice;
                Decimal newUnitPrice = quoteItem.UnitPrice;
                
                Decimal oldQuantity = Trigger.oldMap.get(quoteItem.Id).Quantity;
                Decimal newQuantity = quoteItem.Quantity;
                
                if(oldPrice != newPrice || oldUnitPrice != newUnitPrice || oldQuantity != newQuantity){
                    quoteItemsToUpdate.add(quoteItem);
                    pricebookEntriesIds.add(quoteItem.PricebookEntryId);
					quoteIds.add(quoteItem.quoteId);
                }
            }else if(Trigger.isInsert){
                quoteItemsToUpdate.add(quoteItem);
                pricebookEntriesIds.add(quoteItem.PricebookEntryId);
				quoteIds.add(quoteItem.quoteId);
            }
        }
        QuoteLineItemDiscount.UpdateDiscounts(true, quoteItemsToUpdate, pricebookEntriesIds);
		
		// Gestion des taxes taxamo (uniquement si il existe un devis pour Addinsoft Company)
		Set<Quote> USquotes = new Set<Quote>();
		List<Quote> allQuotes = [select AddinSoftCompany__c from Quote where Id in :quoteIds];
		For (Quote quote :allQuotes) if (ParametersForOrders.US_COMPANY.equals(quote.AddinSoftCompany__c)) USquotes.add(quote);
		if (USquotes.size() >0) System.enqueueJob(new QuoteLineItemTaxes(new List<Quote>(USquotes)));		
    }
}