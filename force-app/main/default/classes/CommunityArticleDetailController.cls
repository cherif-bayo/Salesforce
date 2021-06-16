public class CommunityArticleDetailController {

	@AuraEnabled
	public static Knowledge__kav getSummary(Id recordId) {
		System.debug('recordId :' + recordId);

		final String PUBLISH_STATUS_ONLINE = 'Online';

		final String q = 'SELECT Summary,body__c,Title FROM Knowledge__kav WHERE PublishStatus = :PUBLISH_STATUS_ONLINE AND Id = :recordId AND IsLatestVersion=true';
		List<Knowledge__kav> articles = Database.query(q);
		if (!articles.isEmpty()) {
			return articles[0];
		}
		return null;
	}

	@AuraEnabled
	public static List<String> getFiles(Id recordId) {
		List<String> filenames = new List<String> ();
		final String PUBLISH_STATUS_ONLINE = 'Online';

		final String q1 = 'SELECT filenames__c,KnowledgeArticleId,IsMasterLanguage FROM Knowledge__kav WHERE PublishStatus = :PUBLISH_STATUS_ONLINE AND Id = :recordId AND IsLatestVersion=true';
		List<Knowledge__kav> articlesVersion = Database.query(q1);

		System.debug('q1 :' + q1);
		System.debug('articlesVersion :' + articlesVersion);

		if (!articlesVersion.isEmpty() && articlesVersion[0].filenames__c != null && articlesVersion[0].filenames__c.length() > 0) {
			for (String s : articlesVersion[0].filenames__c.split('\\|')) {
				if (s.length() > 2) filenames.add(s.replaceAll('Article-Attachment-[0-9]*-en', ''));
			}
		} else {
			if (!articlesVersion.isEmpty() && !articlesVersion[0].IsMasterLanguage) {
				String articleId = articlesVersion[0].KnowledgeArticleId;
				final String q2 = 'SELECT filenames__c FROM Knowledge__kav WHERE PublishStatus = :PUBLISH_STATUS_ONLINE AND KnowledgeArticleId = :articleId AND IsLatestVersion=true AND IsMasterLanguage = true';
				List<Knowledge__kav> masterArticleVersions = Database.query(q2);
				if (!masterArticleVersions.isEmpty() && masterArticleVersions[0].filenames__c != null && masterArticleVersions[0].filenames__c.length() > 0)
				for (String s : masterArticleVersions[0].filenames__c.split('\\|')) if (s.length() > 2) filenames.add(s.replaceAll('Article-Attachment-[0-9]*-en', ''));
			}
		}
		return filenames;
	}
}