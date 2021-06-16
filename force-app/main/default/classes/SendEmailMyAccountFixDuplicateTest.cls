@isTest(SeeAllData=false)
public class SendEmailMyAccountFixDuplicateTest {
    public static testMethod void testMain(){
        Contact contact = new Contact();
        contact.FirstName = 'Cherif';
        contact.LastName = 'Bayo';
        contact.Email = Label.emailAdmin;
        
        insert contact;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(contact);
        SendEmailMyAccountFixDuplicateExtension ext = new SendEmailMyAccountFixDuplicateExtension(sc);
        
        PageReference pageRef = Page.SendEmailMyAccountFixDuplicateExtension;
        Test.setCurrentPage(pageRef);
        
        ext.SendEmail();
        System.assertEquals(true, ext.EmailSent);
    }
    
    public static testMethod void testPersonAccount(){
        Account contact = new Account();
        contact.FirstName = 'Mohamed';
        contact.LastName = 'Bayo';
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