@isTest
public class TestSchedulerHelper {

	@IsTest
	public static void main() {
		SchedulerHelper.getSchedulerForNMinutesFromNow(1);
		SchedulerHelper.getSchedulerForNSecondesFromNow(15);
	}
}