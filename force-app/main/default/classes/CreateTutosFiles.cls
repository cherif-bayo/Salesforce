public class CreateTutosFiles {

	//private static List<String> langs = new List<String> { 'en_US', 'fr', 'de', 'ja', 'es' };

	public static void createFiles(String lang) {

		final String q1 = 'select urlname, body__c from Knowledge__kav where PublishStatus=\'online\' and Language = :lang';
		List<Knowledge__kav> articles = Database.query(q1);

		List<ContentVersion> cvs = new List<ContentVersion> ();

		for (Knowledge__kav article : articles) if (article.body__c != null) {
			ContentVersion cv = new ContentVersion();
			cv.ContentLocation = 'S';
			cv.VersionData = Blob.valueof(article.body__c);
			cv.Title = 'tuto_'+ lang +'_'+article.urlname;
			cv.PathOnClient = article.urlname + '.html';
			cvs.add(cv);
		}

		insert cvs;
	}
}