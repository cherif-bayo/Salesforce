@IsTest(seeAllData=false)
public class OrderUnpaidEmailControllerTest{   
    public static testMethod void testMain(){  
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {        
            EmailTemplate validEmailTemplate = new EmailTemplate();
            validEmailTemplate.isActive = true;
            validEmailTemplate.Name = 'test US';
            validEmailTemplate.DeveloperName = 'test';
            validEmailTemplate.TemplateType = 'text';
            validEmailTemplate.FolderId = UserInfo.getUserId();
            validEmailTemplate.HtmlValue = 'test';
            validEmailTemplate.Body = 'test';
        
            insert validEmailTemplate;
        }
        
        Currencies_Exchange_Rates__c rate = new Currencies_Exchange_Rates__c();
        rate.Day__c = Date.today();
        rate.CurrencyIsoCode = 'USD';
        rate.Rate__c = 1;
        
        insert rate;
    
        Pricebook2 pricebook = new Pricebook2();
        pricebook.Name = 'Test';
        
        insert pricebook;
        
        Product2 product = new Product2();
        product.Name = 'Test';
        
        insert product;
        
        PricebookEntry pes = new PricebookEntry();
        pes.Product2Id = product.Id;
        pes.Pricebook2Id = Test.getStandardPricebookId();
        pes.UnitPrice = 10;
        
        insert pes;
        
        PricebookEntry pe = new PricebookEntry();
        pe.Product2Id = product.Id;
        pe.Pricebook2Id = pricebook.Id;
        pe.UnitPrice = 10;
        
        insert pe;
         
        Relance__c relance = new Relance__c();
        relance.Nb_Days__c = 0;
        relance.Template_Email__c = 'test';
        relance.Order_Status__c = '1ere Relance';
        
        insert relance;
    
        Account account = new Account();
        account.PersonEmail = 'test@test.com';
        account.FirstName = 'test';
        account.LastName = 'test';
        
        insert account;
        
        Order order = new Order();
        order.AccountId = account.Id;
        order.EffectiveDate = Date.today();
        order.Pricebook2Id = pricebook.Id;
        order.CurrencyIsoCode = 'USD';
        order.Status = 'Version préliminaire';
        
        insert order;
        
        OrderItem orderItem = new OrderItem();
        orderItem.PricebookEntryId = pe.Id;
        orderItem.OrderId = order.Id;
        orderItem.Quantity = 1;
        orderItem.UnitPrice = 10;
        
        insert orderItem;
        
        order.Status = 'Validée';
        update order;
        
        Facture__c facture = new Facture__c();
        facture.Date__c = Date.today();
        facture.Commande_Lie__c = order.Id;
        
        insert facture;
   
        Test.StartTest();        
        OrderUnpaidEmailController controller = new OrderUnpaidEmailController();
        controller.Send();
        Test.StopTest();
        
        order = [SELECT Facturation_Date_1ere_relance__c, Facturation_Statut__c FROM Order WHERE Id = :order.Id];
        
        System.assertEquals(order.Facturation_Statut__c, relance.Order_Status__c);
        System.assertEquals(order.Facturation_Date_1ere_relance__c.day(), Date.today().day());
        System.assertEquals(order.Facturation_Date_1ere_relance__c.month(), Date.today().month());
        System.assertEquals(order.Facturation_Date_1ere_relance__c.year(), Date.today().year());                
    }
}