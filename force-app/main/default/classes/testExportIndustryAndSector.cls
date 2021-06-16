@isTest
public class testExportIndustryAndSector{
    
    @testSetup
    public static void setup() {
        insert new Account (Name='test', Industry='test');
    }
    
    @isTest
    public static void testMain(){
         ExportSector exportSector = new ExportSector();
         exportSector.exportSectors();
         
         ExportIndustry exportIndustry = new ExportIndustry();
         exportIndustry.exportIndustries();
     }
}