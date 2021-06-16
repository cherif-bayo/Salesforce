trigger insertCouponBonOrder on Order (before insert) {
    for(Order order : Trigger.new){
        Opportunity[] opportunity = [select Discount_Manuel_Activated__c, Discount_Client_Activated__c, Discount_Coupon_Activated__c, Discount_Manuel__c, R_f_Bon_de_commande__c, Ref_du_coupon__c from Opportunity where Id = :order.OpportunityId];
        
        if(opportunity.size() > 0){
            order.Ref_du_coupon__c = opportunity[0].Ref_du_coupon__c;
            order.R_f_Bon_de_commande__c = opportunity[0].R_f_Bon_de_commande__c;
            order.Discount_Manuel__c = opportunity[0].Discount_Manuel__c;
            order.Discount_Manuel_Activated__c = opportunity[0].Discount_Manuel_Activated__c;
            order.Discount_Client_Activated__c = opportunity[0].Discount_Client_Activated__c;
            order.Discount_Coupon_Activated__c = opportunity[0].Discount_Coupon_Activated__c;
        }
    }
}