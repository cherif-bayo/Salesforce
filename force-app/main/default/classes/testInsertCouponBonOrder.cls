@isTest (SeeAllData=true)

public class testInsertCouponBonOrder{
     public static testMethod void testTriggerNew(){
         Opportunity opportunity = [select Id, AccountId from opportunity limit 1];
         
         Order order = new Order();
         order.OpportunityId = opportunity.Id;
         order.Name = 'test';
         order.AccountId = opportunity.AccountId;
         order.EffectiveDate = Date.today();
         order.status = 'Version préliminaire';
         
         insert order;
     }
 }