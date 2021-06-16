public class ParametersForOrders {

	public static String SEND_KEY_LICENSE_TYPE_1 = 'Annuelle';
	public static String SEND_KEY_LICENSE_TYPE_2 = 'Perpétuelle';
	public static String SEND_KEY_LICENSE_TYPE_3 = 'Support et maintenance ( 1 an )';
	public static String SEND_KEY_USER_DOMAIN_COMPANY = 'Company';
	public static String SEND_KEY_USER_DOMAIN_ACADEMIC = 'Academic';
	public static String SEND_KEY_USER_DOMAIN_STUDENT = 'Student';

	public static String PRODUCT_FAMILY_SOLUTION = 'Solution';
	public static String PRODUCT_FAMILY_OPTION = 'Module';

	public static Integer BILLING_CARD = 0;
	public static Integer BILLING_WIRE = 1;
	public static Integer BILLING_CHECK = 2;

	public static String GENERATE_LICENSE_USER_DOMAIN_1 = 'Entreprise/Privé';
	public static String GENERATE_LICENSE_USER_DOMAIN_2 = 'Etudiant';
	public static String GENERATE_LICENSE_USER_DOMAIN_3 = 'Education';
	public static String GENERATE_LICENSE_NO_TYPE_LICENSE_1 = 'Support et maintenance ( 1 an )';
	public static String GENERATE_LICENSE_NO_TYPE_LICENSE_3 = 'Campus';

	public static Map<String, String> productDomainToOrderDomain = new Map<String, String> { 'Entreprise/Privé' => 'Company', 'Education' => 'Academic', 'Etudiant' => 'Student' };
	public static Map<String, String> productLicenseTypeToOrderLicenseType = new Map<String, String> { 'Large Campus' => 'Campus', 'Small Campus' => 'Campus', 'Classroom' => 'Campus' };
	public static Set<String> productCodePartOptions = new Set<String> { '3DP', 'CCR', 'LG' };
	public static Set<String> countriesCodesWithStatesCodes = new Set<String> { 'CA', 'AU', 'US' };

	public static String QUOTE_TYPE = 'Devis';

	public static String FR_COMPANY = 'Addinsoft';
	public static String US_COMPANY = 'Addinsoft Inc.';

	public static String STRIPE_PAYMENT = 'Stripe';

	// Origine de la commande : site internet avec Stripe ou bon de commande
	public static String ORIGIN_STRIPE = 'Stripe';
	public static String ORIGIN_PURCHASE_ORDER = 'Bon de Commande';

	public static Integer NB_OF_DAYS_FREE_FOR_STUDENT = 3; //Duree de la clé étudiante 3j

	// Status de la commande
	public static String ORDER_STATUS_ABANDONNE = 'Stripe - Non Payée';
}