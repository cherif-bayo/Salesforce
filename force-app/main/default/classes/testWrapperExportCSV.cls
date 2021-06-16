@isTest (SeeAllData=true)

public class testWrapperExportCSV{
     public static testMethod void testWrapperExportCSVMethod(){         
         WrapperExportCSV wp = new WrapperExportCSV();
         wp.discount  = 0;
         wp.pricebookId = '0';
         wp.pricebookName = '0';
         wp.productId = '0';
         wp.productCode = '0';
         wp.rangeFrom = '0';
         wp.rangeTo = '0';
         wp.rowCounter = '0';
         
         System.assertEquals(0 , wp.discount);
         System.assertEquals('0' , wp.pricebookId );
         System.assertEquals('0' , wp.pricebookName );
         System.assertEquals('0' , wp.productId );
         System.assertEquals('0' , wp.productCode );
         System.assertEquals('0' , wp.rangeFrom );
         System.assertEquals('0' , wp.rangeTo);
         System.assertEquals('0' , wp.rowCounter);         
     }
}