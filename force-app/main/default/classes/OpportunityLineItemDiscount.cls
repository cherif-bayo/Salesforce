public class OpportunityLineItemDiscount{
    public static void UpdateDiscounts(Boolean fromTrigger, List<OpportunityLineItem> orderItemsToUpdate, List<String> pricebookEntriesIds){
        Set<String> pricebookIds = new Set<String>();
        Set<String> productIds = new Set<String>();
        Set<Decimal> quantities = new Set<Decimal>();
        
        List<String> orderIds = new List<String>();
        
        List<PricebookEntry> listPricebookEntries = [select Id, Product2.Id, Product2.Type_licence__c, Pricebook2.Id, CurrencyIsoCode, UnitPrice from PricebookEntry WHERE Id in :pricebookEntriesIds];
        Map<Id, PricebookEntry> pricebookEntries = new Map<Id, PricebookEntry>(listPricebookEntries);
        
        for(OpportunityLineItem orderItem : orderItemsToUpdate){
            PricebookEntry peOrderItem = pricebookEntries.get(orderItem.PricebookEntryId);
            
            pricebookIds.add(peOrderItem.Pricebook2.Id);
            productIds.add(peOrderItem.Product2.Id);
            quantities.add(orderItem.Quantity);
            orderIds.add(orderItem.OpportunityId);
        }
        
        AyPrice__DiscountDetail__c[] discountDetails = [select Price_After_Discount__c, AyPrice__Range_From__c, AyPrice__Range_To__c, AyPrice__Price_Book_Id__c, AyPrice__Product_Id__c from AyPrice__DiscountDetail__c where AyPrice__Product_Id__c in :productIds and AyPrice__Price_Book_Id__c in :pricebookIds and AyPrice__Range_From__c in :quantities and AyPrice__Range_To__c in :quantities];
    
        AyPrice__DiscountDetail__c[] discountDetailsMax = [select Price_After_Discount__c, AyPrice__Product_Id__c, AyPrice__Price_Book_Id__c, AyPrice__Range_From__c from AyPrice__DiscountDetail__c where AyPrice__Product_Id__c in :productIds and AyPrice__Price_Book_Id__c in :pricebookIds and  AyPrice__Range_From__c = 30];
        
        Map<String, Opportunity> ordersToUpdate = new Map<String, Opportunity>();
        Map<String, String> accountIdByOrderId = new Map<String, String>();  
        for(Opportunity order : [select Discount_Manuel__c, Discount_Client_Activated__c, Discount_Coupon_Activated__c, Discount_Manuel_Activated__c, CurrencyIsoCode, Id,AccountId, Ref_du_coupon__c, Account.Type from Opportunity where Id in :orderIds]){
            ordersToUpdate.put(order.Id, order);
            accountIdByOrderId.put(order.Id, order.AccountId);
        }
        
        Map<String, Account> accountByOrderId = new Map<String, Account>();
        for(Account account : [select Id, Discount_global__c, Type from Account where Id in :accountIdByOrderId.values() limit 1]){
            accountByOrderId.put(account.Id, account);
        }
        
        for(OpportunityLineItem orderItem : orderItemsToUpdate){
            Opportunity order = ordersToUpdate.get(orderItem.OpportunityId);
            Account account = accountByOrderId.get(accountIdByOrderId.get(order.Id));
            
            Boolean updateOrder = false;
            Boolean orderItemHasDiscount = false;
        
            orderItem.Percent_Discount_Coupon__c = null;
            orderItem.Percent_Discount_Total__c = null;
            orderItem.Percent_Discount_Client__c = null;
            orderItem.Percent_Discount_Manuel__c = null;
        
            PricebookEntry peOrderItem = pricebookEntries.get(orderItem.PricebookEntryId);
            
            Decimal price = orderItem.UnitPrice * orderItem.Quantity;
        
            orderItem.Unit_Price_Discount_Volume__c = orderItem.UnitPrice;
            
            AyPrice__DiscountDetail__c discountDetailMax = null;
            AyPrice__DiscountDetail__c discountDetail = null;
            
            for(AyPrice__DiscountDetail__c dd : discountDetailsMax){
                if(dd.AyPrice__Product_Id__c == peOrderItem.Product2.Id && dd.AyPrice__Price_Book_Id__c == peOrderItem.Pricebook2.Id){
                    discountDetailMax = dd;
                    break;
                }
            }
            
            for(AyPrice__DiscountDetail__c dd : discountDetails){
                if(dd.AyPrice__Product_Id__c == peOrderItem.Product2.Id && dd.AyPrice__Price_Book_Id__c == peOrderItem.Pricebook2.Id && dd.AyPrice__Range_From__c == orderItem.Quantity && dd.AyPrice__Range_To__c == orderItem.Quantity){
                    discountDetail = dd;
                    break;
                }
            }
            
            if(discountDetailMax != null){
                if(orderItem.Quantity >= discountDetailMax.AyPrice__Range_From__c){
                    price = discountDetailMax.Price_After_Discount__c * orderItem.Quantity;
                    orderItem.Unit_Price_Catalogue__c = discountDetailMax.Price_After_Discount__c;
                }else if(discountDetail != null){
                    price = discountDetail.Price_After_Discount__c * orderItem.Quantity;
                    orderItem.Unit_Price_Catalogue__c  = discountDetail.Price_After_Discount__c;
                }
            }
                
                
            if(peOrderItem.Product2.Id != '01t24000002qdWp' && peOrderItem.UnitPrice > 0){
                
                if(peOrderItem.UnitPrice == orderItem.UnitPrice || account.Type == 'Distributeur'){
                    
                    Decimal realPrice;
                    if(discountDetailMax != null){
                        if(orderItem.Quantity >= discountDetailMax.AyPrice__Range_From__c){
                            price = discountDetailMax.Price_After_Discount__c * orderItem.Quantity;
                            realPrice = price;
                            orderItem.Unit_Price_Discount_Volume__c = discountDetailMax.Price_After_Discount__c;
                        }else if(discountDetail != null){
                            price = discountDetail.Price_After_Discount__c * orderItem.Quantity;
                            realPrice = price;
                            orderItem.Unit_Price_Discount_Volume__c = discountDetail.Price_After_Discount__c;
                        }
                    }
                    
                    Decimal oldPriceDiscountClient;
                    if(account.Type == 'Distributeur' && peOrderItem.UnitPrice != orderItem.UnitPrice){
                        price = orderItem.UnitPrice * orderItem.Quantity;
                        realPrice = price;
                        Decimal realPriceDistributor = orderItem.Unit_Price_Discount_Volume__c > 0 ? orderItem.Unit_Price_Discount_Volume__c * orderItem.Quantity : peOrderItem.UnitPrice * orderItem.Quantity;
                        
                        orderItem.Unit_Price_Discount_Volume__c = orderItem.UnitPrice;
                        
                        if(!(orderItem.UnitPrice > peOrderItem.UnitPrice && orderItem.Quantity == 1)){
                            oldPriceDiscountClient = realPriceDistributor;
                            orderItem.Percent_Discount_Client__c = ((realPriceDistributor - price) / realPriceDistributor) * 100;
                        }
                    }
                    
                    if(order.Discount_Manuel__c != null && order.Discount_Manuel__c > 0 && order.Discount_Manuel_Activated__c){
                        price = price - (price * (order.Discount_Manuel__c / 100));
                        orderItem.Percent_Discount_Manuel__c = order.Discount_Manuel__c;
                    }
                    
                    if(order.Ref_du_coupon__c != null && order.Discount_Coupon_Activated__c){
                        Coupon__c coupon = [select discount_GBP__c, discount_USD__c , discount_EUR__c, discount_JPY__c, Debut__c, Fin__c from Coupon__c where Id = :order.Ref_du_coupon__c];
                            if(coupon.Debut__c <= Date.today() && coupon.Fin__c >= Date.today()){
                            Decimal discount = 0;
                            if(peOrderItem.CurrencyIsoCode == 'EUR'){
                                discount = coupon.discount_EUR__c;
                            }else if(peOrderItem.CurrencyIsoCode == 'GBP'){
                                discount = coupon.discount_GBP__c;
                            }else if(peOrderItem.CurrencyIsoCode == 'USD'){
                                discount = coupon.discount_USD__c;
                            }else if(peOrderItem.CurrencyIsoCode == 'JPY'){
                                discount = coupon.discount_JPY__c;
                            }
                            orderItem.Percent_Discount_Coupon__c = discount;
                            if(discount > 0){
                                orderItemHasDiscount = true;
                            }
                            price = price - (price * (discount / 100));
                        }
                    }else{
                        if(account.Discount_global__c != null && order.Discount_Client_Activated__c){
                                price = price - (price * (account.Discount_global__c / 100));
                                if(orderItem.Percent_Discount_Client__c == null){
                                    orderItem.Percent_Discount_Client__c = 0;
                                }
                                if(oldPriceDiscountClient != null){
                                    orderItem.Percent_Discount_Client__c = ((oldPriceDiscountClient  - price) / oldPriceDiscountClient) * 100;
                                }else{
                                    orderItem.Percent_Discount_Client__c = account.Discount_global__c;
                                }
                                if(account.Discount_global__c > 0){
                                    orderItemHasDiscount = true;
                                }
                            }
                    }
                    
                    if(realPrice == null){
                        realPrice = peOrderItem.UnitPrice * orderItem.Quantity;
                    }
                    orderItem.Total_Price_Before_Discount__c = realPrice;
                    orderItem.Percent_Discount_Total__c = ((realPrice  - price) / realPrice) * 100;
                }else{
                    Decimal realPrice = peOrderItem.UnitPrice * orderItem.Quantity;
                    price = orderItem.UnitPrice * orderItem.Quantity;
                    orderItem.Total_Price_Before_Discount__c = price;
                    
                    if(!(orderItem.UnitPrice > peOrderItem.UnitPrice && orderItem.Quantity == 1)){
                        Decimal percentDiscount = ((realPrice  - price) / realPrice) * 100;
                        orderItem.Percent_Discount_Client__c = percentDiscount;
                        orderItem.Percent_Discount_Total__c = percentDiscount;
                        
                        orderItemHasDiscount = true;
                    }
                }
            }
                
            orderItem.Total_Price_After_Discount__c = price;
        }
        
        update ordersToUpdate.values();
        
        if(fromTrigger == false){
            update orderItemsToUpdate;
        }
    }
}