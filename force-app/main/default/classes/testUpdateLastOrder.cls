@isTest
public class testUpdateLastOrder{
    
    @testSetup
    public static void setUp() {
        
    }
    
    @isTest
    public static void testMain() {
        UpdateLastOrder testController = new UpdateLastOrder();
        while(testController.CountOrder > 0){
            testController.UpdateOrders();
        }
    }
}