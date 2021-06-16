public class GenerateReportPayoutResponse {

	public String id;
	public Integer created;
	public cls_error error;
	public boolean livemode;
	public cls_parameters parameters;
	public String report_type; //payout_reconciliation.by_id.itemized.1
	public cls_result result;
	public String status; //pending
	public cls_succeeded_at succeeded_at;

	class cls_error {
	}

	class cls_parameters {
		public String payout;//po_1Fu7VTDlc4BISCKmHGcR3rPm
	}

	class cls_result {
	}

	class cls_succeeded_at {
	}

	public static GenerateReportPayoutResponse parse(String json) {
		return(GenerateReportPayoutResponse) System.JSON.deserialize(json, GenerateReportPayoutResponse.class);
	}
}