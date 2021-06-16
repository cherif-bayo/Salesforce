@isTest (SeeAllData=true)
public class TestChangeStatusPaidOrder{
    public static testMethod void testChangeStatus() {
        OrderToPaidStatus controller = new OrderToPaidStatus();
        controller.ChangeStatus();
    } 
}