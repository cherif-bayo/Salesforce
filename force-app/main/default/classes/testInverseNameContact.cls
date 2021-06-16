@isTest
public class testInverseNameContact{
    
    @testSetup
    public static void setUp() {
        insert new Contact (LastName='test', FirstName='test',Import_Auto__c = true );
    }
    
    @isTest
    public static void testInverse() {
        InverseNameContactController controller = new InverseNameContactController();
        controller.Inverse();
    } 
}