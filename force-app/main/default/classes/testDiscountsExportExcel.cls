@isTest (SeeAllData=true)

public class testDiscountsExportExcel{
    public static testMethod void testExportExcelMethod(){
        
        exportDiscountsExcel exportExcelClass = new exportDiscountsExcel();
        exportExcelClass.exportToExcel();
    }
}