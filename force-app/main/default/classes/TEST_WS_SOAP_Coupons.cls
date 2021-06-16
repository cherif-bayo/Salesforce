@isTest
public class TEST_WS_SOAP_Coupons {

	@TestSetup
	public static void setUp() {
		insert new Coupon__c(
		                     name = 'testCoupon',
		                     discount_EUR__c = 0.5,
		                     discount_GBP__c = 1.5,
		                     discount_JPY__c = 2.5,
		                     discount_USD__c = 3.5,
							 DomainName__c = 'STUDENT',
		                     Debut__c = Date.today().addDays(- 5),
		                     Fin__c = Date.today().addMonths(1)
		);
	}

	@IsTest
	public static void testMain() {
		WS_SOAP_Coupons.Coupon coupon = WS_SOAP_Coupons.getCouponByName('testCoupon');
		System.assert(coupon != null);
	}
}