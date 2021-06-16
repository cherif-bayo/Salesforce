public class CTL_HelpCenterRedirections {

	public String targetUrl { get; set; }
	public String sourceUrl { get; set; }

	public Boolean errorRedirection = false;

	final String REDIRECT_1 = '/customer/';
	final String REDIRECT_2 = '/articles/';
	final String HOMEPAGE = '/s/';
	final String PUBLISH_STATUS_ONLINE = 'Online';
	final List<String> langs = new List<String> {'en','de','fr','es','ja'};

	public CTL_HelpCenterRedirections() {
		sourceUrl = ApexPages.currentPage().getParameters().get('source');
		System.debug('[CTL_HelpCenterRedirections] sourceUrl=' + sourceUrl);

		String deskId;
		String slug;
		String lang;

		targetUrl = HOMEPAGE; //Redirection vers la home en cas de tuto non trouvé

		String[] urlParts = sourceUrl.split('/');
		if (sourceUrl.startsWith(REDIRECT_1)) { // Url type : /customer/(lang)/portal/articles/deskId-(slug)?blablah						
			lang = urlParts[urlParts.size() - 4];

			// slug
			String deskIdAndSlugAndQueryString = urlParts[urlParts.size() - 1];
			String deskIdAndSlug = deskIdAndSlugAndQueryString.split('\\?') [0];
			System.debug('[CTL_HelpCenterRedirections] deskIdAndSlug=' + deskIdAndSlug);
			slug = deskIdAndSlug.replaceAll('^[0-9]*-', '');

			deskId = deskIdAndSlug.split('-') [0];
		} else if (sourceUrl.startsWith(REDIRECT_2)) { // URl type : /articles/(lang)/Knowledge/(slug)?blahblah
			lang = urlParts[urlParts.size() - 3];

			// slug
			String slugAndQueryString = urlParts[urlParts.size() - 1];
			slug = slugAndQueryString.split('\\?') [0];
		}

		System.debug('[CTL_HelpCenterRedirections] slug=' + slug);
		System.debug('[CTL_HelpCenterRedirections] lang=' + lang);

		if (deskId != null && langs.contains(lang)) { // Recherche dans la table des id Desk
			List<Redirection__c> redirections = [select Url_Name__c from Redirection__c where Desk_Article_Id__c = :deskId and Language__c = :lang];
			if (redirections.size() > 0) {
				targetUrl = '/s/article/' + redirections[0].Url_Name__c + '?language=' + lang;
				System.debug('>>>>> Id desk trouvé pour url=' + sourceUrl);
			}
		}

		if (targetUrl.equals(HOMEPAGE) && langs.contains(lang)) { // Recherche du slug dans les articlesVersions de salesforce 
			final String q1 = 'SELECT Id FROM Knowledge__kav WHERE PublishStatus = :PUBLISH_STATUS_ONLINE AND Language = :lang AND UrlName = :slug AND IsLatestVersion=true';
			List<Knowledge__kav> avs = Database.query(q1);
			if (avs.size() > 0) {
				targetUrl = '/s/article/' + slug + '?language=' + lang;
				System.debug('>>>>> Slug trouvé dans les UrlName__c kav pour url=' + sourceUrl);
			} else errorRedirection = true;
		}

		if (targetUrl.equals(HOMEPAGE) && langs.contains(lang)) { // Localisation si possible
			targetUrl += '?language=' + lang;
		}

		System.debug('[CTL_HelpCenterRedirections] targetUrl=' + targetUrl);
	}

	public void logErrorRedirection() {
		String isLogging = Parameters.getString('ErrorRedirection_Log');

		if (errorRedirection && 'yes'.equalsIgnoreCase(isLogging)) {
			List<ErrorRedirection__c> errors = [select counter__c from ErrorRedirection__c where urlName__c = :sourceUrl];
			if (errors.size() > 0) {
				errors[0].counter__c += 1;
				update errors[0];
			} else {
				ErrorRedirection__c error = new ErrorRedirection__c(urlName__c = sourceUrl, counter__c = 1);
				insert error;
			}
		}
	}
}