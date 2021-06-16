global class CL001_HelpCenterRedirections implements Site.UrlRewriter {

	String REDIRECT_1 = '/customer/';
	String REDIRECT_2 = '/articles/';

	global PageReference mapRequestUrl(PageReference oldUrl) {
		String url = oldUrl.getUrl();
		System.debug('[CL001_HelpCenterRedirections] source: '+url);

		if (url.startsWithIgnoreCase(REDIRECT_1) || url.startsWithIgnoreCase(REDIRECT_2)) {
			PageReference p = new PageReference('HelperCenterRedirections');
			p.getParameters().put('source',url);
			return p;
		} 
		return oldUrl;
	}

	global PageReference[] generateUrlFor(PageReference[] yourSalesforceUrls) {
		return yourSalesforceUrls; // Pas utile on ne fait pas du beautifuling d'url
	}
}