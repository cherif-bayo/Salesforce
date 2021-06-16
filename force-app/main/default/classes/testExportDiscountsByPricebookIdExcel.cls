@isTest (SeeAllData=true)

public class testExportDiscountsByPricebookIdExcel{
    public static testMethod void testExportExcelMethod(){
        
        exportDiscountsByPricebookIdExcel exportExcelClass = new exportDiscountsByPricebookIdExcel();
        exportExcelClass.exportToExcel();
    }
}