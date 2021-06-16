@isTest
global class TEST001_RelanceClientSupport {
	@TestSetup
	public static void testSetup() {
		EmailTemplate validEmailTemplate = new EmailTemplate();
		validEmailTemplate.isActive = true;
		validEmailTemplate.Name = 'relance';
		validEmailTemplate.DeveloperName = 'Template';
		validEmailTemplate.TemplateType = 'text';
		validEmailTemplate.FolderId = UserInfo.getUserId();
		validEmailTemplate.Body = 'relance';
		validEmailTemplate.HtmlValue = 'relance';
		
		insert validEmailTemplate;
	}

	@isTest
	public static void testMain() {
		Account acc = new Account(Name = 'testAccount');
		insert acc;

		Contact ct = new Contact(LastName = 'testContact', AccountId = acc.id, Email = 'lbeaubier@xlstat.com');
		insert ct;

		Case aCase = new Case(Subject = 'Test Case', ContactId = ct.Id, AccountId = acc.Id,
		                      DateChangementStatus__c = Date.today().addYears(- 1));
		insert aCase;

		SCH001_RelanceClientSupport sch = new SCH001_RelanceClientSupport();
		sch.execute(null);

		EmailTemplate validEmailTemplate = [select Name from EmailTemplate limit 1];
		sch.sendEmails(new List<Case> { aCase }, validEmailTemplate.Id, 'relance','Closed');
	}
}