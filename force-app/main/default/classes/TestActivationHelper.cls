@isTest
public class TestActivationHelper  {

	@isTest
	public static void testAll() {
		Decimal qty;
		Decimal activations;

		qty = ActivationHelper.getQuantityBoughtFromNbActivationsAllowed(11.0);
		System.assertEquals(10, qty); 

		qty = ActivationHelper.getQuantityBoughtFromNbActivationsAllowed(22.0);
		System.assertEquals(20, qty); 

		activations = ActivationHelper.getNbActivationsAllowedFromQuantityBought('Company','annuelle',2);
		System.assertEquals(activations, 3); 

		activations = ActivationHelper.getNbActivationsAllowedFromQuantityBought('Company','annuelle',22);
		System.assertEquals(activations, 24); 

		activations = ActivationHelper.getNbActivationsAllowedFromQuantityBought('Student','annuelle',2);
		System.assertEquals(activations, 2); 
		
		activations = ActivationHelper.getNbActivationsAllowedFromQuantityBought('Campus','classroom',2);
		System.assertEquals(activations, 120); 

		activations = ActivationHelper.getNbActivationsAllowedFromQuantityBought('Campus','Small Campus',2);
		System.assertEquals(activations, 1000); 

		activations = ActivationHelper.getNbActivationsAllowedFromQuantityBought('Campus','Large Campus',2);
		System.assertEquals(activations, 2000); 
	}
}