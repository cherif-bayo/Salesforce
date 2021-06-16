public with sharing class OpportUpdateOrderItemsDiscountExtension{   
    private final Id orderId;
 
    private OpportunityLineItem[] orderItems;
    
    public OpportUpdateOrderItemsDiscountExtension(ApexPages.StandardController standardController){
        this.orderId = standardController.getId();
    
        this.orderItems = [SELECT PricebookEntryId, Quantity, OpportunityId, Percent_Discount_Coupon__c, Percent_Discount_Total__c, Percent_Discount_Client__c, UnitPrice, Unit_Price_Discount_Volume__c, Percent_Discount_Manuel__c, Total_Price_After_Discount__c FROM OpportunityLineItem WHERE OpportunityId = :this.orderId];
    }
    
    public PageReference UpdateDiscounts(){
        List<String> pricebookEntriesIds = new List<String>();
        for(OpportunityLineItem orderItem : this.orderItems){
            pricebookEntriesIds.add(orderItem.PricebookEntryId);
        }
    
        OpportunityLineItemDiscount.UpdateDiscounts(false, this.orderItems, pricebookEntriesIds);
        
        PageReference pageRef = new PageReference('/' + this.orderId);
        pageRef.setRedirect(true);
        return pageRef;
    }
}