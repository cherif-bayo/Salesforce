@isTest
public class TEST001_HelpCenterRedirections  {
	
	@IsTest
	public static void mainTest() {
		CL001_HelpCenterRedirections redirections = new CL001_HelpCenterRedirections();

		PageReference page = new PageReference('/customer/');
		redirections.mapRequestUrl(page); 		

		PageReference page2 = new PageReference('/articles/');
		redirections.mapRequestUrl(page2); 		

		PageReference[] pages = new PageReference[1];
		pages[0] = page;
		redirections.generateUrlFor(pages);
	}
}