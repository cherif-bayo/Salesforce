trigger insertTotalPriceAfterDiscountOpportunity on OpportunityLineItem (before insert, before update) {    
    List<OpportunityLineItem> orderItemsToUpdate = new List<OpportunityLineItem>();
    List<String> pricebookEntriesIds = new List<String>();
    for(OpportunityLineItem orderItem : Trigger.new){
        if(Trigger.isUpdate){
            Decimal oldPrice = Trigger.oldMap.get(orderItem.Id).ListPrice;
            Decimal newPrice = orderItem.ListPrice;
            
            Decimal oldUnitPrice = Trigger.oldMap.get(orderItem.Id).UnitPrice;
            Decimal newUnitPrice = orderItem.UnitPrice;
            
            Decimal oldQuantity = Trigger.oldMap.get(orderItem.Id).Quantity;
            Decimal newQuantity = orderItem.Quantity;
            
            if(oldPrice != newPrice || oldUnitPrice != newUnitPrice || oldQuantity != newQuantity){
                orderItemsToUpdate.add(orderItem);
                pricebookEntriesIds.add(orderItem.PricebookEntryId);
            }
        }else if(Trigger.isInsert){
            orderItemsToUpdate.add(orderItem);
            pricebookEntriesIds.add(orderItem.PricebookEntryId);
        }
    }

    OpportunityLineItemDiscount.UpdateDiscounts(true, orderItemsToUpdate, pricebookEntriesIds);
}