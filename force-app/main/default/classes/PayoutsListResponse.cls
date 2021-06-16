public class PayoutsListResponse {

	public String url; ///v1/payouts
	public boolean has_more;
	public cls_data[] data;
	public class cls_data {
		public String id; //po_1Fu8JyDlc4BISCKmdJMWVgOn
		public Long amount; //851858
		public Long arrival_date; //1577923200
		public boolean automatic;
		public String balance_transaction; //txn_1Dz3ZJDlc4BISCKmExxZCBlM
		public Long created; //1577412778
		public String currency_x; //eur
		public String description; //STRIPE PAYOUT
		public String destination; //ba_1DxcwsDlc4BISCKmvDeo1AiH
		public cls_failure_balance_transaction failure_balance_transaction;
		public cls_failure_code failure_code;
		public cls_failure_message failure_message;
		public boolean livemode;
		public cls_metadata metadata;
		public String method; //standard
		public String source_type; //card
		public cls_statement_descriptor statement_descriptor;
		public String status; //paid
		public String type; //bank_account
	}
	class cls_failure_balance_transaction {
	}
	class cls_failure_code {
	}
	class cls_failure_message {
	}
	class cls_metadata {
	}
	class cls_statement_descriptor {
	}
	public static PayoutsListResponse parse(String json) {
		return(PayoutsListResponse) System.JSON.deserialize(json.replace('"currency":', '"currency_x":'), PayoutsListResponse.class);
	}
}