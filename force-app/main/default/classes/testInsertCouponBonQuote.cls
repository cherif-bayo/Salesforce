@isTest (SeeAllData=true)

public class testInsertCouponBonQuote{
     public static testMethod void testTriggerNew(){
         Opportunity opportunity = [select Id from opportunity limit 1];
         
         Quote quote = new Quote();
         quote.Name = 'Test';
         quote.OpportunityId = opportunity.Id;
         quote.Date__c = Date.today();
         
         insert quote;
     }
 }