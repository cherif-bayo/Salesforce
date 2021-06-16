@IsTest
public class TEST004_SendEmailTest {

    @TestSetup
    private static void setup() {
        List<EmailTemplate> emtsToInsert = new List<EmailTemplate>();

        EmailTemplate emtOrderOkFrXlRisk = new EmailTemplate();
        emtOrderOkFrXlRisk.IsActive = true;
        emtOrderOkFrXlRisk.Name = 'name';
        emtOrderOkFrXlRisk.DeveloperName = 'ORDER_OK_FR_GENERIC';
        emtOrderOkFrXlRisk.TemplateType = 'text';
        emtOrderOkFrXlRisk.FolderId = UserInfo.getUserId();

        EmailTemplate emtOrderOkEnXlRisk = new EmailTemplate();
        emtOrderOkEnXlRisk.IsActive = true;
        emtOrderOkEnXlRisk.Name = 'name';
        emtOrderOkEnXlRisk.DeveloperName = 'ORDER_OK_EN_GENERIC';
        emtOrderOkEnXlRisk.TemplateType = 'text';
        emtOrderOkEnXlRisk.FolderId = UserInfo.getUserId();

        EmailTemplate emtTrialFrXlStat = new EmailTemplate();
        emtTrialFrXlStat.IsActive = true;
        emtTrialFrXlStat.Name = 'name';
        emtTrialFrXlStat.DeveloperName = 'DOWNLOAD_FR';
        emtTrialFrXlStat.TemplateType = 'text';
        emtTrialFrXlStat.FolderId = UserInfo.getUserId();

        EmailTemplate emtTrialEnXlStat = new EmailTemplate();
        emtTrialEnXlStat.IsActive = true;
        emtTrialEnXlStat.Name = 'name';
        emtTrialEnXlStat.DeveloperName = 'DOWNLOAD_EN';
        emtTrialEnXlStat.TemplateType = 'text';
        emtTrialEnXlStat.FolderId = UserInfo.getUserId();

        EmailTemplate emtTrialFrXlRisk = new EmailTemplate();
        emtTrialFrXlRisk.IsActive = true;
        emtTrialFrXlRisk.Name = 'name';
        emtTrialFrXlRisk.DeveloperName = 'DOWNLOAD_XLRISK_FR';
        emtTrialFrXlRisk.TemplateType = 'text';
        emtTrialFrXlRisk.FolderId = UserInfo.getUserId();

        EmailTemplate emtTrialEnXlRisk = new EmailTemplate();
        emtTrialEnXlRisk.IsActive = true;
        emtTrialEnXlRisk.Name = 'name';
        emtTrialEnXlRisk.DeveloperName = 'DOWNLOAD_XLRISK_EN';
        emtTrialEnXlRisk.TemplateType = 'text';
        emtTrialEnXlRisk.FolderId = UserInfo.getUserId();

        emtsToInsert.add(emtOrderOkFrXlRisk);
        emtsToInsert.add(emtOrderOkEnXlRisk);
        emtsToInsert.add(emtTrialFrXlStat);
        emtsToInsert.add(emtTrialEnXlStat);
        emtsToInsert.add(emtTrialFrXlRisk);
        emtsToInsert.add(emtTrialEnXlRisk);

        insert emtsToInsert;
    }

    @IsTest public static void testSendEmailXlStat() {
        Lead lead = new Lead(FirstName='firstName', LastName='lastName', Email='test@xlstat.com', numoKey__c='12345test');
        insert lead;

        List<Software__c> softwares = new List<Software__c>{
                new Software__c(AccessType__c='Multiple', Code__c='00', Name='XLSTAT', DevelopmentDone__c=true, ProductId__c='44affc53-2fc9-4942-a8bb-5f87214c8f0a'),
                new Software__c(AccessType__c='Simple', Code__c='01', Name='XLRISK', ProductId__c='abb8ac81-f3a1-402a-a5e5-e90b444aa933')
        };
        insert softwares;

        Test.startTest();
        CL004_SendEmail.sendEmailWithKey(lead.Id, 'FR');
        Integer invocations = Limits.getEmailInvocations();
        Test.stopTest();

        System.assertEquals(1, invocations, 'An email has not been sent');
    }

    @IsTest public static void testSendEmailGeneric() {
        Lead lead = new Lead(FirstName='firstName', LastName='lastName', Email='test@xlrisk.com', numoKey__c='12345test');
        insert lead;

        List<Software__c> softwares = new List<Software__c>{
                new Software__c(AccessType__c='Multiple', Code__c='00', Name='XLSTAT', DevelopmentDone__c=true, ProductId__c='44affc53-2fc9-4942-a8bb-5f87214c8f0a'),
                new Software__c(AccessType__c='Simple', Code__c='01', Name='XLRISK', ProductId__c='abb8ac81-f3a1-402a-a5e5-e90b444aa933')
        };
        insert softwares;
                
        Test.startTest();
        CL004_SendEmail.sendEmailWithKey(lead, 'FR', '01');
        Integer invocations = Limits.getEmailInvocations();
        Test.stopTest();
        
        System.assertEquals(1, invocations, 'An email has not been sent');
    }
}