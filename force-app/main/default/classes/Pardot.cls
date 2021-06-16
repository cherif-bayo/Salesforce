public class Pardot {

	public static final String ENDPOINT_LOGIN = 'https://pi.pardot.com/api/login/version/4';
	public static final String ENDPOINT_BATCH_UPSERT = 'https://pi.pardot.com/api/prospect/version/4/do/batchUpsert';
	public static final String LOGIN_EMAIL = 'nl@xlstat.com';
	public static final String LOGIN_PASSWORD = '431e%2A%21Ki%21S4'; // URL Encodé
	public static final String USER_KEY = '1c2ef22c382f1c2e4ffe8b9d639ce68f';
	public static final String LIST_ABANDONNED_CARTS_ID = '24729';  
    public static final String LIST_ABANDONNED_QUOTES_ID = '28692';

	public class Prospect {
		public String fid;
		public String first_name;
		public String last_name;
		public String email;
		public Decimal Montant_Panier;
		public String Produit_Panier;
		public String Devise_Panier;
	}

}