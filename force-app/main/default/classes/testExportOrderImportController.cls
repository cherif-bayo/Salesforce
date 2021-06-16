@isTest (SeeAllData=true)

public class testExportOrderImportController{
    public static testMethod void testMain() {
        ExportOrderImportController exportOrderImportController = new ExportOrderImportController();
        
        exportOrderImportController.TextToUpload = 'test';
        exportOrderImportController.export();
    }
}