public class CL001_HelperPlan {

	private static String MINDWARE_NAME = 'Mindware Seulement SH !!';
	private static Map<String, Product2> productsByProductCode;


	public static String getUserDomain(WebServiceOrderV2.Plan plan) {
		Map<String, Product2> productByCode = getProductByProductCode(plan);
		return ParametersForOrders.productDomainToOrderDomain.get(productByCode.get(plan.planProducts[0].productCode).Domaine_utilisateur__c);
	}

	public static String getLicenseType(WebServiceOrderV2.Plan plan) {
		Map<String, Product2> productByCode = getProductByProductCode(plan);
		return productByCode.get(plan.planProducts[0].productCode).Type_licence__c;
	}

	public static Boolean isPlanWithCustomerDelivering(WebServiceOrderV2.Plan plan) {
		return plan.customerDelivering != null && plan.customerDelivering.email != plan.customerBilling.email;
	}

	public static Map<String, Product2> getProductByProductCode(WebServiceOrderV2.Plan plan) {
		if (productsByProductCode != null) return productsByProductCode;
		//Liste des codes produits de la commande / devis
		List<String> planProductsCodes = new List<String> ();
		for (WebServiceOrderV2.PlanProduct planProduct : plan.planProducts) planProductsCodes.add(planProduct.productCode);
		System.debug('CL001_OrderCreation#addOrder: productsCodes : ' + planProductsCodes);
		// Recupération des sobject des produits de la commande 
		Product2[] products = [SELECT Domaine_utilisateur__c, Type_licence__c, Name, ProductCode, Family FROM Product2 WHERE ProductCode IN :planProductsCodes];
		System.debug('CL001_OrderCreation#addOrder: products : ' + products);
		productsByProductCode = new Map<String, Product2> ();
		for (Product2 product : products) {
			productsByProductCode.put(product.ProductCode, product);
		}
		System.debug('CL001_OrderCreation#addOrder: productsByProductCode : ' + productsByProductCode);
		return productsByProductCode;
	}

	public static String getCouponId(WebServiceOrderV2.Plan plan) {
		// Recherche le premier coupon
		String couponId;
		for (WebServiceOrderV2.PlanProduct planProduct : plan.planProducts) {
			if (planProduct.couponReference != null) {
				List<Coupon__c> coupons = [SELECT Id FROM Coupon__c WHERE Name = :planProduct.couponReference];
				if (coupons.size() > 0) couponId = coupons[0].Id;
				break;
			}
		}
		return couponId;
	}

	public static Boolean isValidPlan(WebServiceOrderV2.Plan plan) {
		Boolean planIsValid = hasProducts(plan) && isAffiliateOk(plan)/* && checkNumberOfOptionLicences(plan)*/;
		System.debug('>>>> isValidPlan - planIsValid = '+planIsValid);
		return planIsValid;
	}

	private static Boolean hasProducts(WebServiceOrderV2.Plan plan) {
		WebServiceOrderV2.PlanProduct[] planProducts = plan.planProducts;
		System.debug('>>>> hasProducts - planProducts.size() = '+planProducts.size());
		return planProducts.size() != 0;
	}

	public static List<Account> getDistributeurs(WebServiceOrderV2.Plan plan) {
		Integer affiliate = plan.affiliate; // 1 => Mindware
		// Mapping du code vers le nom du distributeur
		String affiliateName = '';
		if (affiliate == 1) affiliateName = MINDWARE_NAME;
		// Recherche des distributeurs par nom
		List<Account> distributeurs = new List<Account>();		
		if (affiliateName != '') {
			distributeurs = [SELECT Id, Discount_global__c FROM Account WHERE Name = :affiliateName];
		}
		return distributeurs;
	}

	/**
	 * Verifie que le distributeur affilié est bien mindware ou stacon
	 * @return bool
	 */
	private static Boolean isAffiliateOk(WebServiceOrderV2.Plan plan) {
		Integer affiliate = plan.affiliate; // Mindware, statcon ou rien
		System.debug('>>>> isAffiliateOk - affiliate = '+affiliate);
		return  affiliate == null || affiliate == 0 || affiliate == 1;		
	}

	public static Boolean checkNumberOfOptionLicences(WebServiceOrderV2.Plan plan) {
		Integer quantitySolutions = 0;
		Map<String, Product2> productsByCode = getProductByProductCode(plan);
		Map<String, Integer> optionsQuantitiesByOptionsNames = new Map<String, Integer> ();
		for (WebServiceOrderV2.PlanProduct planProduct : plan.planProducts) {
			String productCode = planProduct.productCode;
			Product2 product = productsByCode.get(productCode);
			String[] productCodeSplitted = productCode.split('_');
			if (product.Family == ParametersForOrders.PRODUCT_FAMILY_SOLUTION) {
				quantitySolutions += planProduct.quantity;
			} else if (product.Family == ParametersForOrders.PRODUCT_FAMILY_OPTION) {
				if (productCodeSplitted.size() > 1) optionsQuantitiesByOptionsNames.put(productCodeSplitted[1], planProduct.quantity);
			}
		}
		System.debug('>>>> checkNumberOfOptionLicences - quantitySolutions = '+quantitySolutions);
		System.debug('>>>> checkNumberOfOptionLicences - optionsQuantitiesByOptionsNames.keySet() = '+optionsQuantitiesByOptionsNames.keySet());
		for (String optionName : optionsQuantitiesByOptionsNames.keySet()) {
			if (optionsQuantitiesByOptionsNames.get(optionName) != quantitySolutions) { return false; }
		}
		return true;
	}
}