@isTest 
private class Test_StripeReportResponse {

	@IsTest
	static void testParse() {
		String json=		'{'+
		'  "id": "frr_1G82uLDlc4BISCKmupmeGri9",'+
		'  "object": "reporting.report_run",'+
		'  "created": 1580728561,'+
		'  "error": null,'+
		'  "livemode": true,'+
		'  "parameters": {'+
		'    "payout": "po_1Fu7VTDlc4BISCKmHGcR3rPm"'+
		'  },'+
		'  "report_type": "payout_reconciliation.by_id.itemized.1",'+
		'  "result": {'+
		'    "id": "file_1G82uTDlc4BISCKmylvRpmZz",'+
		'    "object": "file",'+
		'    "created": 1580728569,'+
		'    "filename": "frr_1G82uLDlc4BISCKmupmeGri9.csv",'+
		'    "links": {'+
		'      "object": "list",'+
		'      "data": [],'+
		'      "has_more": false,'+
		'      "url": "/v1/file_links?file=file_1G82uTDlc4BISCKmylvRpmZz"'+
		'    },'+
		'    "purpose": "finance_report_run",'+
		'    "size": 78055,'+
		'    "title": "FinanceReportRun frr_1G82uLDlc4BISCKmupmeGri9",'+
		'    "type": "csv",'+
		'    "url": "https://files.stripe.com/v1/files/file_1G82uTDlc4BISCKmylvRpmZz/contents"'+
		'  },'+
		'  "status": "succeeded",'+
		'  "succeeded_at": 1580728569'+
		'}';
		StripeReportResponse obj = StripeReportResponse.parse(json);
		System.assert(obj != null);
	}
}