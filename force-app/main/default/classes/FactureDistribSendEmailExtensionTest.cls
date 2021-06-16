@isTest
public class FactureDistribSendEmailExtensionTest{
    
    @testSetup
    public static void setup() {
        Account acc = new Account(Name='test', type = 'Distributeur');
        insert acc;
        
        Contact ct1 = new Contact (LastName='test1', accountId = acc.Id, email='test@test.fr');
        insert ct1;
        
        Contact ct2 = new Contact (LastName='test2', accountId = acc.Id, email='test2@test.fr');
        insert ct2;
        
        Facture_Distributeur__c facture = new Facture_Distributeur__c (Compte_lie__c = acc.Id);
        insert facture;
        
        insert new Attachment(Name = 'test', ParentId = facture.Id, body = Blob.valueOf('test'));
    }
    
    @isTest
    public static void testMain() {
        List<String> accountIds = new List<String>();
        for(Account account: [SELECT Id FROM Account WHERE type = 'Distributeur']){
            accountIds.add(account.Id);
        }
        
         Facture_Distributeur__c facture = [SELECT Id, GenerateFactureEN__c FROM Facture_Distributeur__c WHERE Compte_Lie__c IN :accountIds limit 1];
         
         ApexPages.StandardController sc = new ApexPages.standardController(facture); 
         FactureDistributeurSendEmailExtension ext = new FactureDistributeurSendEmailExtension(sc);
         ext.Email = ext.Emails[0].getValue();
         ext.GetFactureId();
         ext.GetAttachmentLink();
         ext.GetAttachmentName();
         ext.Send();
         
         facture.GenerateFactureEN__c = !facture.GenerateFactureEN__c;
         update facture;
         
         sc = new ApexPages.standardController(facture); 
         ext = new FactureDistributeurSendEmailExtension(sc);
         ext.Email = ext.Emails[0].getValue();
         ext.Send();
    }
}