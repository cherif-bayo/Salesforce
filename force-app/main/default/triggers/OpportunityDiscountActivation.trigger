trigger OpportunityDiscountActivation on Opportunity (before insert, before update) {
    Set<Id> couponsIds = new Set<Id>();
    for(Opportunity order : Trigger.new){
        if(order.Ref_du_coupon__c != null){
            couponsIds.add(order.Ref_du_coupon__c);
        }
    }
    
    Map<Id, Coupon__c> couponsByIds = new Map<Id, Coupon__c>([select Id, discount_GBP__c, discount_USD__c , discount_EUR__c, discount_JPY__c, Debut__c, Fin__c from Coupon__c where Id in :couponsIds]);

    for(Opportunity order : Trigger.new){
    
        Id oldAccountId = Trigger.isUpdate ? Trigger.oldMap.get(order.Id).AccountId : null;
        Id newAccountId = order.AccountId;    
        if(((Trigger.isUpdate == true && oldAccountId != newAccountId) || Trigger.isInsert == true) && order.Discount_client__c != null && order.Discount_client__c != 0){
            order.Discount_Client_Activated__c = true;
        }
        
        Id oldCouponId = Trigger.isUpdate ? Trigger.oldMap.get(order.Id).Ref_du_coupon__c : null;
        Id newCouponId = order.Ref_du_coupon__c;
        if((Trigger.isUpdate == true && oldCouponId != newCouponId) || Trigger.isInsert == true){
            if(newCouponId != null){
                Coupon__c coupon = couponsByIds.get(newCouponId);
            
                if(coupon.Debut__c <= Date.today() && coupon.Fin__c >= Date.today()){
                    Decimal discountCoupon = 0;
                    if(order.CurrencyIsoCode == 'EUR'){
                        discountCoupon = coupon.discount_EUR__c;
                    }else if(order.CurrencyIsoCode == 'GBP'){
                        discountCoupon = coupon.discount_GBP__c;
                    }else if(order.CurrencyIsoCode == 'USD'){
                        discountCoupon = coupon.discount_USD__c;
                    }else if(order.CurrencyIsoCode == 'JPY'){
                        discountCoupon = coupon.discount_JPY__c;
                    }
                    
                    if(discountCoupon > 0){
                        order.Discount_Coupon_Activated__c = true;
                    }
                }
            }
        }
        
        Decimal oldDiscountManuel = Trigger.isUpdate ? Trigger.oldMap.get(order.Id).Discount_Manuel__c : null;
        Decimal newDiscountManuel = order.Discount_Manuel__c;
        if(((Trigger.isUpdate == true && oldDiscountManuel != newDiscountManuel) || Trigger.isInsert == true) && order.Discount_Manuel__c != null && order.Discount_Manuel__c != 0){
            order.Discount_Manuel_Activated__c = true;
        }
    }
}