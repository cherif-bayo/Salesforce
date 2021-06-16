@isTest(SeeAllData=false)
public class SendEmailMyAccountTest{
    public static testMethod void testMain(){
        Contact contact = new Contact();
        contact.FirstName = 'Martin';
        contact.LastName = 'Lezer';
        contact.Email = Label.emailAdmin;
        
        insert contact;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(contact);
        SendEmailMyAccountExtension ext = new SendEmailMyAccountExtension(sc);
        
        PageReference pageRef = Page.SendEmailMyAccountExtension;
        Test.setCurrentPage(pageRef);
        
        ext.SendEmail();
        System.assertEquals(true, ext.EmailSent);
    }
    
    public static testMethod void testPersonAccount(){
        Account contact = new Account();
        contact.FirstName = 'Martin';
        contact.LastName = 'Lezer';
        contact.PersonEmail = Label.emailAdmin;
        
        insert contact;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(contact);
        SendEmailPersonAccountMyAccountExtension ext = new SendEmailPersonAccountMyAccountExtension(sc);
        
        PageReference pageRef = Page.SendEmailPersonAccountMyAccountExtension;
        Test.setCurrentPage(pageRef);
        
        ext.SendEmail();
        System.assertEquals(true, ext.EmailSent);
    }
}