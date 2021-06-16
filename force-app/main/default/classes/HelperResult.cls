public class HelperResult {

	public static WebServiceOrderV2.Result getResultKoWithErrorCode(Integer errorCode) {
		WebServiceOrderV2.Result result = new WebServiceOrderV2.Result();
		result.status = false;
		result.errorCode = errorCode;

		return result;
	}

	public static WebServiceOrderV2.Result getResultOk() {
		WebServiceOrderV2.Result result = new WebServiceOrderV2.Result();
		result.status = true;

		return result;
	}

	public static WebServiceOrderV2.Result getResultOkWithId(String Id) {
		WebServiceOrderV2.Result result = new WebServiceOrderV2.Result();
		result.status = true;
		result.id = Id;

		return result;
	}

}