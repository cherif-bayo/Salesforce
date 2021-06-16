@isTest
public class Test_CreateTutosFiles  {
	
	@testSetup
	public static void setUp() {
		Knowledge__kav article = new Knowledge__kav (urlname='url-test', body__c='test',title='test');
		insert article;
		
		article = [Select KnowledgeArticleId from Knowledge__kav where Id= :article.Id];
		KBManagement.PublishingService.publishArticle(article.KnowledgeArticleId, false);
	}

	@isTest
	public static void test() {
		CreateTutosFiles.createFiles('en_US');
	}
}