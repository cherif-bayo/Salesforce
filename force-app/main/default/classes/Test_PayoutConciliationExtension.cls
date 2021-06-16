@isTest
public class Test_PayoutConciliationExtension  {

	@isTest
	public static void mainTest() {		
		stripe_payouts__c p = new stripe_payouts__c();
		Test.setCurrentPage(Page.PayoutConciliation);
		PayoutConciliationExtension page = new PayoutConciliationExtension (new ApexPages.StandardController(p));		
		page.conciliate();
	}
}