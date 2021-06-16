public with sharing class OrderUpdateOrderItemsDiscountExtension{   
    private final Id orderId;
 
    private OrderItem[] orderItems;
    
    public OrderUpdateOrderItemsDiscountExtension(ApexPages.StandardController standardController){
        this.orderId = standardController.getId();
    
        this.orderItems = [SELECT PricebookEntryId, Quantity, OrderId, Percent_Discount_Coupon__c, Percent_Discount_Total__c, Percent_Discount_Client__c, UnitPrice, Unit_Price_Discount_Volume__c, Percent_Discount_Manuel__c, Total_Price_After_Discount__c, Total_Price_After_DiscountEUR__c, Total_Price_After_DiscountUSD__c, Total_Price_After_DiscountGBP__c, Total_Price_After_DiscountJPY__c, UnitPriceDiscountVolumeShowed__c FROM OrderItem WHERE OrderId = :this.orderId];
    }
    
    public PageReference UpdateDiscounts(){
        List<String> pricebookEntriesIds = new List<String>();
        for(OrderItem orderItem : this.orderItems){
            pricebookEntriesIds.add(orderItem.PricebookEntryId);
        }
    
        OrderItemDiscount.UpdateDiscounts(false, this.orderItems, pricebookEntriesIds);
        
        PageReference pageRef = new PageReference('/' + this.orderId);
        pageRef.setRedirect(true);
        return pageRef;
    }
}