@isTest (SeeAllData=true)

public class testProductsToFastSpring{
    public static testMethod void testMain(){
        ProductsToFastSpring productsToFastSpring = new ProductsToFastSpring();
        productsToFastSpring.ExportEDU();
        productsToFastSpring.ExportCMP();
        productsToFastSpring.ExportCAM();
        productsToFastSpring.ExportSTU();                        
    }
}