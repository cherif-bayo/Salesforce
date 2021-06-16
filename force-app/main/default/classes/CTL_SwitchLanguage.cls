public class CTL_SwitchLanguage {

	@AuraEnabled
	public static Map<String,String> getLocalisedArticles(String recordId) {	
		Map<String,String> languagesLabelByCode = new Map<String,String> {'en_US'=>'English','fr'=>'French','de'=>'German','ja'=>'Japanese','es'=>'Spanish'};

		System.debug('[CTL_SwitchLanguage] recordId :' + recordId);

		Map<String,String> articlesByLang = new Map<String,String> ();
		final String PUBLISH_STATUS_ONLINE = 'Online';

		final String q1 = 'SELECT Language,KnowledgeArticleId FROM Knowledge__kav WHERE PublishStatus = :PUBLISH_STATUS_ONLINE AND Id = :recordId AND IsLatestVersion=true';
		List<Knowledge__kav> articlesVersion = Database.query(q1);

		System.debug('[CTL_SwitchLanguage] articlesVersion :' + articlesVersion);
		articlesByLang.put(languagesLabelByCode.get(articlesVersion[0].Language),'');


		String articleId;
		if (!articlesVersion.isEmpty()) {
			articleId = articlesVersion[0].KnowledgeArticleId;
			String q2 = 'SELECT Language,UrlName FROM Knowledge__kav WHERE PublishStatus = :PUBLISH_STATUS_ONLINE AND KnowledgeArticleId = :articleId AND IsLatestVersion=true AND Language = :lang';

			List<Knowledge__kav> localisedArticleVersions;
			for (String lang :languagesLabelByCode.keySet()) {
				System.debug('>' + lang);
				localisedArticleVersions = Database.query(q2);
				if (!localisedArticleVersions.isEmpty()) if (lang != articlesVersion[0].Language) {
					articlesByLang.put(languagesLabelByCode.get(lang),localisedArticleVersions[0].UrlName);
				}
			}
		}
		return articlesByLang;
	}
}