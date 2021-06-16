trigger orderMontants on OrderItem (after update, after insert) {
    Order order = [select Id,AccountId, Ref_du_coupon__c, HasDiscount__c, HasCD__c, Import_Auto__c, Account.Type, Editor_Auto__c, MontantModule__c, MontantSolution__c, MontantFormation__c, MontantExpertise__c, MontantShipping__c, MontantSupport__c from Order where Id = :Trigger.new[0].OrderId limit 1];
    
    order.MontantModule__c = 0;
    order.MontantSolution__c = 0;
    order.MontantFormation__c  = 0;
    order.MontantExpertise__c = 0;
    order.MontantSupport__c = 0;
    order.MontantShipping__c = 0;      
    for(OrderItem oi:[select PricebookEntry.Product2.Family, TotalPriceAfterDiscountShowed__c from OrderItem where OrderId = :Trigger.new[0].OrderId]){
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
    }
    for(OrderItem oi : Trigger.new){
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
    }
    
    update order;
}