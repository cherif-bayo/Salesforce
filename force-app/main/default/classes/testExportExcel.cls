@isTest (SeeAllData=true)

public class testExportExcel{
    public static testMethod void testExportExcelMethod(){
        
        exportExcel exportExcelClass = new exportExcel();
        exportExcelClass.exportToExcel();
    }
}