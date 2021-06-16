@IsTest
public class Test_CtlHelpCenterRedirections {

	@IsTest
	public static void testDeskUrl() {

		ApexPages.currentPage().getParameters().put('source', '/customer/fr/portal/articles/2062231-regresfsdfsdfsion-lineaire-multiple-avec-xlstat?b_id=9283');
		CTL_HelpCenterRedirections redirections = new CTL_HelpCenterRedirections();
		redirections.logErrorRedirection();
	}

	@IsTest
	public static void testDeskWWW() {

		ApexPages.currentPage().getParameters().put('source', '/articles/es/Knowledge/regresfsdfsdfsion-lineaire-multiple-avec-xlstat?b_id=9283');
		CTL_HelpCenterRedirections redirections = new CTL_HelpCenterRedirections();
		redirections.logErrorRedirection();
	}
}