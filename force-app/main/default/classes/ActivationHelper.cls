public class ActivationHelper {

	private static Integer NB_ACTIVATIONS_LARGE_CAMPUS = 1000;
	private static Integer NB_ACTIVATIONS_SMALL_CAMPUS = 500;
	private static Integer NB_ACTIVATIONS_CLASSROOM = 60;
	private static Integer FREE_ACTIVATIONS_LESS_20 = 1;
	private static Integer PERCENT_FREE_ACTIVATIONS_MORE_20 = 10;

	public static Decimal getNbActivationsAllowedFromQuantityBought(String userDomain, String licenceType, Decimal quantity) {
		Decimal nbActivations;

		if (ParametersClesXlstat.DOMAIN_CAMPUS.equalsIgnoreCase(userDomain)) {
			if (ParametersClesXlstat.LICENSE_LARGE_CAMPUS.equalsIgnoreCase(licenceType)) nbActivations = quantity * NB_ACTIVATIONS_LARGE_CAMPUS;
			else if (ParametersClesXlstat.LICENSE_SMALL_CAMPUS.equalsIgnoreCase(licenceType)) nbActivations = quantity * NB_ACTIVATIONS_SMALL_CAMPUS;
			else nbActivations = quantity * NB_ACTIVATIONS_CLASSROOM;
		} else {
			if (ParametersClesXlstat.LICENSE_NETWORK.equals(licenceType) || ParametersClesXlstat.DOMAIN_STUDENT.equalsIgnoreCase(userDomain)) nbActivations = quantity;
			else nbActivations = quantity< 20 ? quantity + FREE_ACTIVATIONS_LESS_20 : Integer.valueof(quantity + quantity * PERCENT_FREE_ACTIVATIONS_MORE_20 /100);
		}

		return nbActivations;
	}

	public static Decimal getQuantityBoughtFromNbActivationsAllowed(Decimal quantity) {
		return quantity <= 20 ? quantity - 1 : Integer.valueof(Math.roundToLong(quantity - quantity * 0.1));
	}
	// Test addin comment from VSCODE

}