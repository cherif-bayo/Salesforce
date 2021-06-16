@isTest
public class Test_PayoutsListResponse  {

	@IsTest
	static void testParse() {
		String json=		'{'+
		'  "object": "list",'+
		'  "url": "/v1/payouts",'+
		'  "has_more": false,'+
		'  "data": ['+
		'    {'+
		'      "id": "po_1Fu8JyDlc4BISCKmdJMWVgOn",'+
		'      "object": "payout",'+
		'      "amount": 851858,'+
		'      "arrival_date": 1577923200,'+
		'      "automatic": true,'+
		'      "balance_transaction": "txn_1Dz3ZJDlc4BISCKmExxZCBlM",'+
		'      "created": 1577412778,'+
		'      "currency": "eur",'+
		'      "description": "STRIPE PAYOUT",'+
		'      "destination": "ba_1DxcwsDlc4BISCKmvDeo1AiH",'+
		'      "failure_balance_transaction": null,'+
		'      "failure_code": null,'+
		'      "failure_message": null,'+
		'      "livemode": false,'+
		'      "metadata": {},'+
		'      "method": "standard",'+
		'      "source_type": "card",'+
		'      "statement_descriptor": null,'+
		'      "status": "paid",'+
		'      "type": "bank_account"'+
		'    }'+
		'  ]'+
		'}';
		PayoutsListResponse payouts = PayoutsListResponse.parse(json);
		System.assert(payouts != null);
	}
}