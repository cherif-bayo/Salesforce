@isTest
public class OrderAddProductsExtensionTest{

    public static testMethod void testMain() {
        
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
        product.Type_Licence__c = 'Annuelle';
        product.Domaine_Utilisateur__c = 'Entreprise/Privé';
        
        insert product;
        
        PricebookEntry pes = new PricebookEntry();
        pes.Product2Id = product.Id;
        pes.Pricebook2Id = Test.getStandardPricebookId();
        pes.UnitPrice = 50;
        
        insert pes;
        
        PricebookEntry pe = new PricebookEntry();
        pe.Product2Id = product.Id;
        pe.Pricebook2Id = pricebook.Id;
        pe.UnitPrice = 50;
        
        insert pe;
        
        Account account = new Account();
        account.Name = 'Test';
        account.BillingCountryCode = 'FR';
        
        insert account;
        
        Contact contact = new Contact();
        contact.FirstName = 'Test';
        contact.LastName = 'Test';
        contact.Email = 'test@xlstat.com';
        contact.Langue__c = 'FR';
        contact.AccountId = account.Id;
        
        insert contact;
        
        Order order = new Order();
        order.EffectiveDate = Date.today();
        order.AccountId = account.Id;
        order.Status = 'Version préliminaire';
        order.Contact_Lie__c = contact.id;
        order.CurrencyIsoCode = 'USD';
        order.BillingCountryCode = 'FR';
        order.Pricebook2Id = pricebook.Id;
        order.Domaine_Utilisateur__c = 'Company';
        
        insert order;
        
        OrderItem orderItem = new OrderItem();
        orderItem.PricebookEntryId = pe.Id;
        orderItem.OrderId = order.Id;
        orderItem.Quantity = 2;
        orderItem.UnitPrice = 50;
        
        insert orderItem;
    
        Test.setCurrentPage(Page.OrderAddProducts);
        Test.startTest();
        OrderAddProductsExtension controller = new OrderAddProductsExtension(new ApexPages.StandardController(order));
        Test.stopTest();      
    }
}