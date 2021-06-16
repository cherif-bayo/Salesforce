@isTest
private class WebServiceLeadsTest{

	@TestSetup
	static void setup() {
		insert new Contact (lastname='test',Email='test@test.fr');
		insert new Lead (lastname='test',Email='test@test.fr');
	}

	@isTest
    static void testRecommend(){
        Contact contact = [SELECT Email FROM Contact LIMIT 1];
        Lead lead = [SELECT Email FROM Lead LIMIT 1];
    
        WebServiceLeads.Customer customer = new WebServiceLeads.Customer();
        customer.Email = contact.Email;
        customer.Language = 'FR';
        customer.CurrencyCode = 'EUR';
        
        String[] emails = new String[]{contact.Email, 'crougetet@xlstat.com', 'asifre@xlstat.com', 'tfahmy@xlstat.com'};
        
        WebServiceLeads.AddFromRecommend(customer, emails);
        
        customer.Email = lead.Email;
        emails = new String[]{lead.Email, 'crougetet@xlstat.com', 'asifre@xlstat.com', 'tfahmy@xlstat.com'};
        
        WebServiceLeads.AddFromRecommend(customer, emails);
        
        customer.Email = 'emailwhich@dontexist.com';
        
        WebServiceLeads.AddFromRecommend(customer, emails);
        
        WebServiceLeads.AddFromRecommend(customer, emails);
    }
    
	@isTest
    static void testDownload(){
        Version__c version = new Version__c();
        version.Name = 'Test';
        version.Date__c = Date.today();
        
        insert version;
        
        Version__c version2 = new Version__c();
        version2.Name = 'Test2';
        version2.Date__c = Date.today().AddDays(-1);
        
        insert version2;
    
        Contact contact = [SELECT Email FROM Contact LIMIT 1];
    
        WebServiceLeads.Customer customer = new WebServiceLeads.Customer();
        customer.FirstName = 'Martin';
        customer.LastName = 'Lezer';
        customer.Email = contact.Email;
        customer.Language = 'FR';
        customer.CurrencyCode = 'EUR';
        
        WebServiceLeads.DownloadedFile file = new WebServiceLeads.DownloadedFile();
        file.OS = 'Windows';
        file.Version = 'Vista';
        file.Extension = 'ZIP';
        
        Test.startTest();
        WebServiceLeads.AddFromDownload(customer, 'SE', file,  version2.Name);
        
        customer.Email = 'emailwhich@dontexist2.com';
        
        WebServiceLeads.AddFromDownload(customer, 'NOT_IN_MAP', file,  version2.Name);
        
        WebServiceLeads.AddFromDownload(customer, 'NOT_IN_MAP', file,  version2.Name);
        
        WebServiceLeads.AddFromDownloadWithDate(customer, 'SE', file, '11/03/1997 02:51',  version2.Name);
        
        WebServiceLeads.AddFromDownloadWithDate(customer, 'SE', file, '11/03/1997 02:51', version2.Name);
        Test.stopTest();
        
        DateTime dateTimeTest = DateTime.newInstance(2000, 1, 1);
        Telechargement__c[] telechargement = [SELECT Date__c FROM Telechargement__c WHERE Date__c < :dateTimeTest];
        Telechargement__c[] telechargementsWithVersion = [SELECT Id FROM Telechargement__c WHERE XLSTAT_Version__c = :version2.Id];
        System.assertEquals(1997, telechargement[0].Date__c.year());
        System.assertEquals(true, telechargementsWithVersion.size() > 0);
    }
}