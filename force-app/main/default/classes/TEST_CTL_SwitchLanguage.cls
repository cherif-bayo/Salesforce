@isTest public class TEST_CTL_SwitchLanguage  {

	@isTest static void testLocalisedArticles() {
		Knowledge__kav articleVersion = new Knowledge__kav();
		articleVersion.UrlName = 'urlName';
		articleVersion.Title = 'unitTest';
		articleVersion.Body__c = 'unitTest';
		insert articleVersion;

		articleVersion = [SELECT Id, Title, KnowledgearticleId FROM knowledge__kav WHERE Id = :articleVersion.Id];

		String idFr = KbManagement.PublishingService.submitForTranslation(articleVersion.KnowledgeArticleId, 'fr', System.UserInfo.getUserId(), Datetime.newInstanceGmt(2021, 12, 1));
		Knowledge__kav articleVersionFr = [SELECT KnowledgearticleId FROM knowledge__kav WHERE Id = :idFr];
		articleVersionFr.UrlName = 'unitTestFr';
		articleVersionFr.Title = 'unitTestFr';
		articleVersionFr.Body__c = 'unitTestFr';
		update articleVersionFr;
		KbManagement.PublishingService.completeTranslation(articleVersionFr.Id);
		KbManagement.PublishingService.publisharticle(articleVersion.KnowledgearticleId, true);

		Test.startTest();
		Map<String,String> urlsTutoByLanguage = CTL_SwitchLanguage.getLocalisedArticles(articleVersionFr.Id);
		System.debug('>>'+urlsTutoByLanguage);
		Test.stopTest();
	}
}