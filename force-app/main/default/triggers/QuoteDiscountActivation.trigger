trigger QuoteDiscountActivation on Quote (before insert, before update) {
    Set<Id> couponsIds = new Set<Id>();
    Set<Id> opportunitiesIds = new Set<Id>();
    if(Trigger.isInsert){
        for(Quote order : Trigger.new){
            opportunitiesIds.add(order.OpportunityId);
        }
    }
    
    Map<Id, Opportunity> opportunitiesByIds = new Map<Id, Opportunity>([select Id, Discount_Manuel_Activated__c, Discount_Coupon_Activated__c, Discount_Manuel__c, R_f_Bon_de_commande__c, Ref_du_coupon__c from Opportunity where Id in :opportunitiesIds]);
    
    for(Quote order : Trigger.new){   
        if(Trigger.isInsert){  
            Opportunity opportunity = opportunitiesByIds.get(order.OpportunityId);
            
            order.Ref_du_coupon__c = opportunity.Ref_du_coupon__c;
            order.Discount_Manuel__c = opportunity.Discount_Manuel__c;
            order.R_f_Bon_de_commande__c = opportunity.R_f_Bon_de_commande__c;
            order.Discount_Manuel_Activated__c = opportunity.Discount_Manuel_Activated__c;
            order.Discount_Coupon_Activated__c = opportunity.Discount_Coupon_Activated__c;
        }
        
        if(order.Ref_du_coupon__c != null){
            couponsIds.add(order.Ref_du_coupon__c);
        }
    }
    
    Map<Id, Coupon__c> couponsByIds = new Map<Id, Coupon__c>([select Id, discount_GBP__c, discount_USD__c , discount_EUR__c, discount_JPY__c, Debut__c, Fin__c from Coupon__c where Id in :couponsIds]);

    for(Quote order : Trigger.new){        
        Id oldCouponId = Trigger.isUpdate ? Trigger.oldMap.get(order.Id).Ref_du_coupon__c : null;
        Id newCouponId = order.Ref_du_coupon__c;
        if((Trigger.isUpdate == true && oldCouponId != newCouponId)){
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
        if(((Trigger.isUpdate == true && oldDiscountManuel != newDiscountManuel)) && order.Discount_Manuel__c != null && order.Discount_Manuel__c != 0){
            order.Discount_Manuel_Activated__c = true;
        }
    }
}