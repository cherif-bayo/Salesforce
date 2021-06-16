@isTest public class CommunityArticleDetailControllerTest {
	@isTest static void testGetSummary() {
		Knowledge__kav articleVersion = new Knowledge__kav();
		articleVersion.UrlName = 'unitTest';
		articleVersion.Title = 'unitTest';
		articleVersion.Body__c = 'unitTest';
		articleVersion.Language = 'en_US';
		insert articleVersion;

		Test.startTest();
		articleVersion = [SELECT Id, Title, KnowledgearticleId FROM knowledge__kav WHERE Id = :articleVersion.Id];
		KbManagement.PublishingService.publisharticle(articleVersion.KnowledgearticleId, true);

		CommunityarticleDetailController.getSummary(articleVersion.Id);
		Test.stopTest();
	}

	@isTest static void testGetSummaryKo() {
		Knowledge__kav articleVersion = new Knowledge__kav();
		articleVersion.UrlName = 'unitTest';
		articleVersion.Title = 'unitTest';
		articleVersion.Body__c = 'unitTest';
		articleVersion.Language = 'en_US';
		insert articleVersion;

		Test.startTest();
		articleVersion = [SELECT Id, Title, KnowledgearticleId FROM knowledge__kav WHERE Id = :articleVersion.Id];
		KbManagement.PublishingService.publisharticle(articleVersion.KnowledgearticleId, true);

		CommunityarticleDetailController.getSummary('00524000000Ncd2');
		Test.stopTest();
	}

	@isTest static void testGetFilesMasterLanguage() {
		Knowledge__kav articleVersion = new Knowledge__kav();
		articleVersion.UrlName = 'unitTest';
		articleVersion.Title = 'unitTest';
		articleVersion.Body__c = 'unitTest';
		articleVersion.filenames__c = 'a|b|c';
		articleVersion.Language = 'en_US';
		insert articleVersion;

		Test.startTest();
		articleVersion = [SELECT Id, Title, KnowledgearticleId FROM knowledge__kav WHERE Id = :articleVersion.Id];
		KbManagement.PublishingService.publisharticle(articleVersion.KnowledgearticleId, true);

		List<String> files = CommunityarticleDetailController.getFiles(articleVersion.Id);
		Test.stopTest();
	}

	@isTest static void testGetFilesForeignLanguage() {
		Knowledge__kav articleVersion = new Knowledge__kav();
		articleVersion.UrlName = 'unitTest';
		articleVersion.Title = 'unitTest';
		articleVersion.Body__c = 'unitTest';
		articleVersion.filenames__c = 'd|e|f';
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
		List<String> files = CommunityarticleDetailController.getFiles(articleVersionFr.Id);
		Test.stopTest();
	}
}