@isTest 
private class Test_GenerateReportPayoutResponse {

	@isTest
	private static void testParse() {
		String json = '{' +
		'  "id": "frr_1GEY9jDlc4BISCKmjrWkf3J6",' +
		'  "object": "reporting.report_run",' +
		'  "created": 1582278647,' +
		'  "error": null,' +
		'  "livemode": true,' +
		'  "parameters": {' +
		'    "payout": "po_1Fu7VTDlc4BISCKmHGcR3rPm"' +
		'  },' +
		'  "report_type": "payout_reconciliation.by_id.itemized.1",' +
		'  "result": null,' +
		'  "status": "pending",' +
		'  "succeeded_at": null' +
		'}';

		GenerateReportPayoutResponse obj = GenerateReportPayoutResponse.parse(json);
		System.assert(obj != null);
	}
}