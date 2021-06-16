public class CTL_RedirectionToHomePage {

	public PageReference urlRedirection() {
		string url = 'https://help.xlstat.com';

		PageReference page = new PageReference(url);
		page.setRedirect(true);
		return page;
	}
}