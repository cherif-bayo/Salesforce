public class SchedulerHelper {

	public static String getSchedulerForNMinutesFromNow(Integer n) {
		Datetime currentDatetime = Datetime.now().addSeconds(n * 60);
		String seconds = String.valueOf(currentDatetime.second());
		String minutes = String.valueOf(currentDatetime.minute());
		String hours = String.valueOf(currentDatetime.hour());
		String month = String.valueOf(currentDatetime.month());
		String year = String.valueOf(currentDatetime.year());
		String dayOfMonth = String.valueOf(currentDatetime.day());
		String dayOfWeek = '?';

		return seconds + ' ' + minutes + ' ' + hours + ' ' + dayOfMonth + ' ' + month + ' ' + dayOfWeek + ' ' + year;
	}

	public static String getSchedulerForNSecondesFromNow(Integer n) {
		Datetime currentDatetime = Datetime.now().addSeconds(n);
		String seconds = String.valueOf(currentDatetime.second());
		String minutes = String.valueOf(currentDatetime.minute());
		String hours = String.valueOf(currentDatetime.hour());
		String month = String.valueOf(currentDatetime.month());
		String year = String.valueOf(currentDatetime.year());
		String dayOfMonth = String.valueOf(currentDatetime.day());
		String dayOfWeek = '?';

		return seconds + ' ' + minutes + ' ' + hours + ' ' + dayOfMonth + ' ' + month + ' ' + dayOfWeek + ' ' + year;
	}
}