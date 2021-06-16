@isTest (SeeAllData=true)

public class testWrapperProduct{
     public static testMethod void testWrapperProductMethod(){
         Product2 p = [select id from Product2][0];
         
         WrapperProduct wp = new WrapperProduct(p);
         
         System.assertEquals(false, wp.checked);
         System.assertEquals(wp.p, p); 
     }
}