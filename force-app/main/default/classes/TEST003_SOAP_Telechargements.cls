@isTest
public class TEST003_SOAP_Telechargements {

    @isTest
    public static void testCreateLead() {
        WS003_SOAP_Telechargements.Person p = new WS003_SOAP_Telechargements.Person ();
        p.firstName = 'firstName';
        p.lastName='lastName';
        p.email = 'test@test.fr';
        p.phone = '04040404'; 
        p.position = 'position';
        p.company = 'company';
        p.locale='fr'; 
        p.countryCode='FR'; 
        p.domainCode ='domain';                
        
        WS003_SOAP_Telechargements.Download download = new WS003_SOAP_Telechargements.Download ();
        download.dateDownload = Date.newInstance(1960, 2, 17);
        
        Test.startTest();
        	WS003_SOAP_Telechargements.createTelechargement(p,download);
        Test.stopTest();
        
        List<Lead> leads = [select Id from lead];
        System.assert(leads.size()>0);
    }
    
    @isTest
    public static void testUpdateLead() {
        Lead lead = new Lead(LastName='test',email='test@test.fr');
        insert lead;
        
        WS003_SOAP_Telechargements.Person p = new WS003_SOAP_Telechargements.Person ();
        p.firstName = 'firstName';
        p.lastName='lastName';
        p.email = 'test@test.fr';
        p.phone = '04040404'; 
        p.position = 'position';
        p.company = 'company';
        p.locale='fr'; 
        p.countryCode='FR'; 
        p.domainCode ='domain';                
        
        WS003_SOAP_Telechargements.Download download = new WS003_SOAP_Telechargements.Download ();
        download.dateDownload = Date.newInstance(1960, 2, 17);
        
        Test.startTest();
        	WS003_SOAP_Telechargements.createTelechargement(p,download);
        Test.stopTest();
        
        // Pas de création mais MAJ du lead existant
        List<Lead> leads = [select firstName from lead where email='test@test.fr'];
        System.assert(leads.size()==1);      
        System.assertEquals(leads[0].firstName,'firstName');
    }    
    
    @isTest
    public static void testUpdateContact() {
        Account act = new Account(Name='test');
        insert act;
        
        Contact ct = new Contact(LastName='test',email='test@test.fr');
        insert ct;
        
        WS003_SOAP_Telechargements.Person p = new WS003_SOAP_Telechargements.Person ();
        p.firstName = 'firstName';
        p.lastName='lastName';
        p.email = 'test@test.fr';
        p.phone = '04040404'; 
        p.position = 'position';
        p.company = 'company';
        p.locale='fr'; 
        p.countryCode='FR'; 
        p.domainCode ='domain';                
        
        WS003_SOAP_Telechargements.Download download = new WS003_SOAP_Telechargements.Download ();
        download.dateDownload = Date.newInstance(1960, 2, 17);
        
        Test.startTest();
        	WS003_SOAP_Telechargements.createTelechargement(p,download);
        Test.stopTest();
        
        // Pas de lead créé
        List<Lead> leads = [select firstName from lead where email='test@test.fr'];
        System.assert(leads.size()==0);      
        
		// Pas de contact créé mais un contact MAJ
        List<Contact> cts = [select firstName from Contact where email='test@test.fr'];
        System.assert(cts.size()==1);         
    }    
    
    
}