@isTest (SeeAllData=true)

public class testWrapperExportCSVStandardPrices{
     public static testMethod void testWrapperExportCSVStandardPrices(){     
         WrapperExportCSVStandardPrices wp = new WrapperExportCSVStandardPrices();
         wp.Id = '0';
         wp.productCode = '0';
         wp.productCurrency= '0';
         wp.productPrice= '0';
         
         System.assertEquals('0' , wp.Id);
         System.assertEquals('0' , wp.productCode );
         System.assertEquals('0' , wp.productCurrency);
         System.assertEquals('0' , wp.productPrice);    
     }
}