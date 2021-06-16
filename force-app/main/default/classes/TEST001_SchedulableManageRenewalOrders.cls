@isTest
public class TEST001_SchedulableManageRenewalOrders {

	@isTest
	public static void test() {
		Test.startTest();     
		String jobId = System.schedule('S001_ManageRenewalOrders','0 0 0 15 3 ? 2022',new S001_ManageRenewalOrders());
		CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];

		System.assertEquals(0, ct.TimesTriggered);
		System.assertEquals('2022-03-15 00:00:00',String.valueOf(ct.NextFireTime));
		Test.stopTest();
	}
}