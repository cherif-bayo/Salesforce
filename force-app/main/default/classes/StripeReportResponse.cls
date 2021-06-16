public class StripeReportResponse{
	public String id;	
	public String stripe_object;	
	public Integer created;
	public cls_error error;
	public boolean livemode;
	public cls_parameters parameters;
	public String report_type;	
	public cls_result result;
	public String status;	
	public Integer succeeded_at;

	public class cls_error {}

	public class cls_parameters {
		public String payout;	
	}

	public class cls_result {
		public String id;
		public String stripe_object;	
		public Integer created;	
		public String filename;
		public cls_links links;
		public String purpose;
		public Integer size;
		public String title;	
		public String type;
		public String url;
	}

	public class cls_links {
		public String stripe_object;
		public cls_data[] data;
		public boolean has_more;
		public String url;
	}

	public class cls_data {}

	public static StripeReportResponse parse(String json){
		return (StripeReportResponse) System.JSON.deserialize(json.replaceAll('object','stripe_object'), StripeReportResponse.class);
	}
}