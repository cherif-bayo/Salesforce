trigger OrderDiscountActivation on Order (before insert, before update) {
    for(Order order : Trigger.new){
    
        Id oldAccountId = Trigger.isUpdate ? Trigger.oldMap.get(order.Id).AccountId : null;
        Id newAccountId = order.AccountId;    
        if(((Trigger.isUpdate == true && oldAccountId != newAccountId) || Trigger.isInsert == true) && order.Discount_client__c != null && order.Discount_client__c != 0){
            order.Discount_Client_Activated__c = true;
        }
        
        Id oldCouponId = Trigger.isUpdate ? Trigger.oldMap.get(order.Id).Ref_du_coupon__c : null;
        Id newCouponId = order.Ref_du_coupon__c;
        if(((Trigger.isUpdate == true && oldCouponId != newCouponId) || Trigger.isInsert == true) && order.Discount_Coupon__c != null && order.Discount_Coupon__c != 0){
            order.Discount_Coupon_Activated__c = true;
        }
        
        Decimal oldDiscountManuel = Trigger.isUpdate ? Trigger.oldMap.get(order.Id).Discount_Manuel__c : null;
        Decimal newDiscountManuel = order.Discount_Manuel__c;
        if(((Trigger.isUpdate == true && oldDiscountManuel != newDiscountManuel) || Trigger.isInsert == true) && order.Discount_Manuel__c != null && order.Discount_Manuel__c != 0){
            order.Discount_Manuel_Activated__c = true;
        }
    }
}