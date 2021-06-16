@isTest
global class Test_HelperResult {

	@IsTest
	static void main() {
		HelperResult.getResultKoWithErrorCode(1);
		HelperResult.getResultOkWithId('');
		HelperResult.getResultOk();
	}
}