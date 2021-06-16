@IsTest
public class OrderPaidStatusExtensionTest{
    
    @TestSetup static void setUp() {
        HelperTestData.insertTextEmail();
        
        Account account = new Account(Name='test');
        insert account;
        
        Contact contact = new Contact (FirstName='a', LastName='test', AccountId = account.Id, Email = 'test@addissoft.com');
        insert contact;
        
       // Id orderId = HelperTestData.createOrderWithProductWithContact(contact);
        
        
		Pricebook2 pricebook = new Pricebook2();
		pricebook.Name = 'Test';

		insert pricebook;

		Product2 product = new Product2(IsActive = true, Name = 'XLSTAT-Base', ProductCode = 'S_BAS_CMP_AN', Family = 'Solution',
		                                CurrencyIsoCode = 'USD', Domaine_utilisateur__c = 'Campus', Type_licence__c = 'Annuelle');
		insert product;
        
        PricebookEntry pes2 = new PricebookEntry();
		pes2.Product2Id = product.Id;
		pes2.Pricebook2Id = Test.getStandardPricebookId();
		pes2.UnitPrice = 10;
		pes2.CurrencyIsoCode = 'USD';
		insert pes2;
        
        PricebookEntry pe = new PricebookEntry();
		pe.Product2Id = product.Id;
		pe.Pricebook2Id = pricebook.Id;
		pe.UnitPrice = 10;
		pe.CurrencyIsoCode = 'USD';
		insert pe;
        
        Order order = new Order();
		order.AccountId = account.Id;
		order.EffectiveDate = Date.today();
		order.Pricebook2Id = pricebook.Id;
		order.CurrencyIsoCode = 'USD';
		order.BillingCountry = 'France';
		order.Status = 'Version préliminaire';
        //order.Provenance__c = 'ShareIt';
		insert order;
                
        OrderItem orderItem = new OrderItem();
		orderItem.PricebookEntryId = pe.Id;
		orderItem.OrderId = order.Id;
		orderItem.Quantity = 1;
		orderItem.UnitPrice = 10;
		insert orderItem;
        
        List<Software__c> softwares = new List<Software__c>{
                new Software__c(AccessType__c='Multiple', Code__c='00', Name='XLSTAT', DevelopmentDone__c=true, ProductId__c='44affc53-2fc9-4942-a8bb-5f87214c8f0a'),
                new Software__c(AccessType__c='Simple', Code__c='01', Name='XLRISK', ProductId__c='abb8ac81-f3a1-402a-a5e5-e90b444aa933')
        };
        insert softwares;

        Flexera_Key__c flexeraKey = new Flexera_Key__c( Order__c = order.Id, Contact__c = contact.Id, Date_limite__c=Date.today().addDays(365), Quantity__c=5);
        insert flexeraKey;        
    }
    
    @IsTest static void ShareIt(){
        Flexera_Key__c flexeraKey = [SELECT Order__c FROM Flexera_Key__c WHERE Order__c != NULL AND Contact__c != NULL LIMIT 1];
        
        Order order = [SELECT Id, Provenance__c FROM Order WHERE Id = :flexeraKey.Order__c];
        
        Test.setCurrentPage(Page.OrderPaidStatusExtension);
        OrderPaidStatusExtension controller = new OrderPaidStatusExtension(new ApexPages.StandardController(order));
        /*controller.ChangeStatus();
        controller = new OrderPaidStatusExtension(new ApexPages.StandardController(order));*/
        
        Test.startTest();
        controller.ChangeStatus();
        Test.stopTest();
    }
    
        @IsTest static void testNotShareIt(){
        Flexera_Key__c flexeraKey = [SELECT Order__c FROM Flexera_Key__c WHERE Order__c != NULL AND Contact__c != NULL LIMIT 1];
        Order order = [SELECT Id, Provenance__c FROM Order WHERE Id = :flexeraKey.Order__c];
              
        OrderPaidStatusExtension controller = new OrderPaidStatusExtension(new ApexPages.StandardController(order));
        Test.startTest();
        controller.ChangeStatusNotShareIt();
        Test.stopTest();        
    }
}