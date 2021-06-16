public with sharing class QuoteUpdateOrderItemsDiscountExtension{   
    private final Id orderId;
 
    private QuoteLineItem[] orderItems;
    
    public QuoteUpdateOrderItemsDiscountExtension(ApexPages.StandardController standardController){
        this.orderId = standardController.getId();
    
        this.orderItems = [SELECT PricebookEntryId, Quantity, QuoteId, Percent_Discount_Coupon__c, Percent_Discount_Total__c, Percent_Discount_Client__c, UnitPrice, Unit_Price_Discount_Volume__c, Percent_Discount_Manuel__c, Total_Price_After_Discount__c FROM QuoteLineItem WHERE QuoteId = :this.orderId];
    }
    
    public PageReference UpdateDiscounts(){
        List<String> pricebookEntriesIds = new List<String>();
        for(QuoteLineItem orderItem : this.orderItems){
            pricebookEntriesIds.add(orderItem.PricebookEntryId);
        }
    
        QuoteLineItemDiscount.UpdateDiscounts(false, this.orderItems, pricebookEntriesIds);
        
        PageReference pageRef = new PageReference('/' + this.orderId);
        pageRef.setRedirect(true);
        return pageRef;
    }
}