global class WS_SOAP_Coupons {

	private static final Map<String,Integer> DomaineCodeByName = new Map<String,Integer> {'STUDENT' => 0,'ACADEMIC' => 1,'COMPANY' => 2};

	global class Coupon {
		webservice List<String> availableProductCodes;
		webservice Integer domainCodes;
		webservice Decimal discountEUR;
		webservice Decimal discountUSD;
		webservice Decimal discountGBP;
		webservice Decimal discountJPY;
		webservice Date startDate;
		webservice Date endDate;
	}

	webservice static Coupon getCouponByName(String couponName) {
		System.debug('[WS_SOAP_Coupons] #getCouponByName : Appel WS pour récuper un coupon par son nom:' + couponName);

		List<Coupon__c> coupons = [select DomainName__c, discount_EUR__c, discount_GBP__c, discount_JPY__c, discount_USD__c, Debut__c, Fin__c from Coupon__c where Name = :couponName];
		if (coupons.size() > 0) {
			Coupon__c databaseCoupon = coupons[0];
			Coupon coupon = new Coupon();
			coupon.availableProductCodes = null;
			coupon.domainCodes	= DomaineCodeByName.get(databaseCoupon.DomainName__c);
			coupon.discountEUR	= databaseCoupon.discount_EUR__c;
			coupon.discountGBP	= databaseCoupon.discount_GBP__c;
			coupon.discountJPY	= databaseCoupon.discount_JPY__c;
			coupon.discountUSD	= databaseCoupon.discount_USD__c;
			coupon.startDate	= databaseCoupon.Debut__c;
			coupon.endDate		= databaseCoupon.Fin__c;

			return coupon;
		}

		return null;
	}
}