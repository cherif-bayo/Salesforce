@isTest (SeeAllData=true)

public class testWrapperPricebookEntry{
     public static testMethod void testWrapperPricebookEntryMethod(){
         PricebookEntry p = [select id from PricebookEntry][0];
         
         WrapperPricebookEntry wp = new WrapperPricebookEntry(p);
         
         System.assertEquals(false, wp.checked);
         System.assertEquals(wp.pe, p); 
     }
}