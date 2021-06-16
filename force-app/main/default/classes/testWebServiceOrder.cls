@isTest
private class testWebServiceOrder {
    
    private static String SOLUTION_NAME_TEST = 'XLSTAT-Base';
    
    @testSetup static void setup(){   
        
        //Create common test Currencies_Exchanges_Rates__c
        insert new Currencies_Exchange_Rates__c(Day__c = Date.today(), CurrencyIsoCode = 'USD', Rate__c = 1);
        
        //Create common test PriceBook
        Pricebook2 pricebook = new Pricebook2(Name = 'Test',IsActive = true,CurrencyIsoCode__c = 'USD');
        insert pricebook;
        
        //Create common test Product2
        Product2 product = new Product2(IsActive = true,Name = SOLUTION_NAME_TEST, ProductCode = 'S_BAS_EDU_AN', Family = 'Solution',Domaine_utilisateur__c='Entreprise/Privé',Type_licence__c='Annuelle');
        Product2 product2 = new Product2(IsActive = true,Name = SOLUTION_NAME_TEST, ProductCode = 'S_BAS_CMP_AN', Family = 'Solution',Domaine_utilisateur__c='Campus',Type_licence__c='Annuelle');
        insert product; insert product2;
        
        
        
        //Create common test PriceBookEntry standard
        insert new PricebookEntry(IsActive = true,Product2Id = product.Id,Pricebook2Id = Test.getStandardPricebookId(),UnitPrice = 10);
        insert new PricebookEntry(IsActive = true,Product2Id = product2.Id,Pricebook2Id = Test.getStandardPricebookId(),UnitPrice = 10);
        
        //Create common test PriceBookEntry
        insert new PricebookEntry(IsActive = true,Product2Id = product.Id,Pricebook2Id = pricebook.Id,UnitPrice = 10);
        insert new PricebookEntry(IsActive = true,Product2Id = product2.Id,Pricebook2Id = pricebook.Id,UnitPrice = 10);   
        
        Account acc = new Account(Name='Company');
        insert acc;
        
        insert new Contact (LastName = 'Lezer',Email = 'mlezer54@adinsoft.edu', accountId=acc.Id);
    } 
    
    @isTest
    public static void testMain() {     
        Test.setMock(WebServiceMock.class, new FlexeraWebServiceMockImpl());
        
        WebServiceOrder.PlanProduct orderProduct = new WebServiceOrder.PlanProduct ();
        orderProduct.ProductCode = 'S_BAS_EDU_AN';
        orderProduct.Quantity = 3;
        orderProduct.UnitPrice = 295;
        orderProduct.productName = 'test';
        orderProduct.currencyISOCode = 'USD';
        
        WebServiceOrder.Customer contact = new  WebServiceOrder.Customer();
        contact.FirstName = 'Martin';
        contact.LastName = 'Lezer';
        contact.Email = 'mlezer@adinsoft.edu';
        contact.company = '';
        contact.countryCode = 'FR';
        contact.street1='88 rue chevalier';
        contact.street2='88 rue chevar';
        contact.postalCode='33000';
        contact.city='Bordeaux';
        contact.language = 'FR';
        
        WebServiceOrder.Customer contactDelivering = new  WebServiceOrder.Customer();
        contactDelivering.FirstName = 'Martin-Charles';
        contactDelivering.LastName = 'Lezer Gerard';
        contactDelivering.Email = Label.emailAdmin;
        contactDelivering.company = '';
        contactDelivering.countryCode = 'FR';
        contactDelivering.street1='88 rue chevalier';
        contactDelivering.street2='80 rue chevalier';
        contactDelivering.postalCode='33000';
        contactDelivering.city='Bordeaux';
        contactDelivering.language = 'FR';
        
        WebServiceOrder.Plan order = new  WebServiceOrder.Plan();
        order.planProducts = new List<WebServiceOrder.PlanProduct>();
        order.planProducts.add(orderProduct);
        order.customerBilling = contact;
        order.customerDelivering = contactDelivering;
        order.isQuote = true;
        order.isAutorenewal = null;
        order.currencyISOCode='USD';
        
        
        WebServiceOrder.Plan plan = WebServiceOrder.AddOrder(order);
        if(plan.status){
            WebServiceOrder.SendOrder(plan);
        }
    }
    
    @isTest static void testMain2() {
        Test.setMock(WebServiceMock.class, new FlexeraWebServiceMockImpl());
        
        WebServiceOrder.PlanProduct orderProduct = new WebServiceOrder.PlanProduct ();
        orderProduct.ProductCode = 'S_BAS_EDU_AN';
        orderProduct.Quantity = 3;
        orderProduct.UnitPrice = 295;
        orderProduct.productName = 'test';
        orderProduct.currencyISOCode = 'USD';
        
        WebServiceOrder.Customer contact = new  WebServiceOrder.Customer();
        contact.FirstName = 'Martin';
        contact.LastName = 'Lezer';
        contact.Email = 'mlezer@adinsoft.edu';
        contact.company = '';
        contact.countryCode = 'FR';
        contact.street1='88 rue chevalier';
        contact.postalCode='33000';
        contact.city='Bordeaux';
        contact.language = 'FR';
        
        WebServiceOrder.Plan order = new  WebServiceOrder.Plan();
        order.planProducts = new List<WebServiceOrder.PlanProduct>();
        order.planProducts.add(orderProduct);
        order.customerBilling = contact;
        order.isQuote = true;
        order.currencyISOCode='USD';
        
        contact.Company = 'test';
        WebServiceOrder.Plan plan = WebServiceOrder.AddOrder(order);
        if(plan.status){
            WebServiceOrder.SendOrder(plan);
        }
        
        plan = WebServiceOrder.AddOrder(order);
        if(plan.status){
            WebServiceOrder.SendOrder(plan);
        }
    }
    
    @isTest static void testMain3() {
        
        WebServiceOrder.PlanProduct orderProduct = new WebServiceOrder.PlanProduct ();
        orderProduct.ProductCode = 'S_BAS_CMP_AN';
        orderProduct.Quantity = 3;
        orderProduct.UnitPrice = 295;
        orderProduct.productName = 'test';
        orderProduct.currencyISOCode = 'USD';
        
        WebServiceOrder.Customer contact = new  WebServiceOrder.Customer();
        contact.FirstName = 'Martin-Charles';
        contact.LastName = 'Lezer Grand';
        contact.Email = 'mlezer99@adinsoft.edu';
        contact.company = '';
        contact.countryCode = 'FR';
        contact.street1='88 rue chevalier';
        contact.postalCode='33000';
        contact.city='Bordeaux';
        contact.language = 'FR';
        
        WebServiceOrder.Plan order = new  WebServiceOrder.Plan();
        order.planProducts = new List<WebServiceOrder.PlanProduct>();
        order.planProducts.add(orderProduct);
        order.customerBilling = contact;
        order.isQuote = true;
        order.currencyISOCode='USD';
        
        contact.Company = '';
        order.isQuote = false;
        WebServiceOrder.Plan plan = WebServiceOrder.AddOrder(order);
        if(plan.status && plan.generateLicense){
            Test.startTest();
            Test.setMock(WebServiceMock.class, new FlexeraWebServiceMockImpl());
            WebServiceOrder.SendOrder(plan);
            Test.stopTest();
        }
    }
    
    @isTest static void testMain4(){
        
        WebServiceOrder.PlanProduct orderProduct = new WebServiceOrder.PlanProduct ();
        orderProduct.ProductCode = 'S_BAS_CMP_AN';
        orderProduct.Quantity = 3;
        orderProduct.UnitPrice = 295;
        orderProduct.productName = 'test';
        orderProduct.currencyISOCode = 'USD';
        
        WebServiceOrder.Customer contact = new  WebServiceOrder.Customer();
        contact.FirstName = 'Martin';
        contact.LastName = 'Lezer';
        contact.Email = 'mlezer@adinsoft.edu';
        contact.company = '';
        contact.countryCode = 'FR';
        contact.street1='88 rue chevalier';
        contact.postalCode='33000';
        contact.city='Bordeaux';
        contact.language = 'FR';
        
        WebServiceOrder.Plan order = new  WebServiceOrder.Plan();
        order.planProducts = new List<WebServiceOrder.PlanProduct>();
        order.planProducts.add(orderProduct);
        order.customerBilling = contact;
        order.isQuote = true;
        order.currencyISOCode='USD';
        order.isAutoRenewal = true;
        
        contact.Company = '';
        order.isQuote = false;
        WebServiceOrder.Plan plan = WebServiceOrder.AddOrder(order);
        if(plan.status && plan.generateLicense){
            Test.startTest();
            Test.setMock(WebServiceMock.class, new FlexeraWebServiceMockImpl());
            WebServiceOrder.SendOrder(plan);
            Test.stopTest();
        }  
    }
    
    @isTest static void testMain5() {
        
        WebServiceOrder.PlanProduct orderProduct = new WebServiceOrder.PlanProduct ();
        orderProduct.ProductCode = 'S_BAS_CMP_AN';
        orderProduct.Quantity = 3;
        orderProduct.UnitPrice = 295;
        orderProduct.productName = 'test';
        orderProduct.currencyISOCode = 'USD';
        
        WebServiceOrder.Customer contact = new  WebServiceOrder.Customer();
        contact.FirstName = 'Martin-Charles';
        contact.LastName = 'Lezer Grand';
        contact.Email = 'mlezer@adinsoft.edu';
        contact.company = '';
        contact.countryCode = '';
        contact.street1='88 rue chevalier';
        contact.postalCode='33000';
        contact.city='Bordeaux';
        contact.language = 'FR';
        
        WebServiceOrder.Plan order = new  WebServiceOrder.Plan();
        order.planProducts = new List<WebServiceOrder.PlanProduct>();
        order.planProducts.add(orderProduct);
        order.customerBilling = contact;
        order.isQuote = false;
        order.currencyISOCode='USD';
        
        contact.Company = '';
        order.isQuote = false;
        WebServiceOrder.Plan plan = WebServiceOrder.AddOrder(order);
        if(plan.status && plan.generateLicense){
            Test.startTest();
            Test.setMock(WebServiceMock.class, new FlexeraWebServiceMockImpl());
            WebServiceOrder.SendOrder(plan);
            Test.stopTest();
        }
    }
    
    @isTest static void testMain6() {
        WebServiceOrder.PlanProduct orderProduct = new WebServiceOrder.PlanProduct ();
        orderProduct.ProductCode = 'S_BAS_CMP_AN';
        orderProduct.Quantity = 3;
        orderProduct.UnitPrice = 295;
        orderProduct.productName = 'test';
        orderProduct.currencyISOCode = 'USD';
        
        Contact ctsetup = [select Website_Id__c from Contact where Email = 'mlezer54@adinsoft.edu' limit 1];
        
        WebServiceOrder.Customer contact = new  WebServiceOrder.Customer();
        contact.FirstName = 'Martin';
        contact.LastName = 'Lezer';
        contact.Id = ctsetup.Website_Id__c;
        contact.Email = 'mlezer@adinsoft.edu';
        contact.company = 'TataXW';
        contact.countryCode = 'FR';
        contact.street1='88 rue chevalier';
        contact.street2='89 rue chevalier';
        contact.postalCode='3300000000000000000000';
        contact.city='Bordeaux';
        contact.language = 'FR';
        
        WebServiceOrder.Plan order = new  WebServiceOrder.Plan();
        order.planProducts = new List<WebServiceOrder.PlanProduct>();
        order.planProducts.add(orderProduct);
        order.customerBilling = contact;
        order.isQuote = false;
        order.currencyISOCode='USD';
        
        contact.Company = '';
        order.isQuote = false;
        WebServiceOrder.Plan plan = WebServiceOrder.AddOrder(order);
        if(plan.status && plan.generateLicense){
            Test.startTest();
            Test.setMock(WebServiceMock.class, new FlexeraWebServiceMockImpl());
            WebServiceOrder.SendOrder(plan);
            Test.stopTest();
        }
    }
    
    @isTest static void testMain7() {
        WebServiceOrder.PlanProduct orderProduct = new WebServiceOrder.PlanProduct ();
        orderProduct.ProductCode = 'S_BAS_CMP_AN';
        orderProduct.Quantity = 3;
        orderProduct.UnitPrice = 295;
        orderProduct.productName = 'test';
        orderProduct.currencyISOCode = 'USD';
        
        WebServiceOrder.Customer contact = new  WebServiceOrder.Customer();
        contact.FirstName = 'Martin';
        contact.LastName = 'Lezer';
        contact.Email = 'mlezer54@adinsoft.edu';
        contact.company = 'TataXW';
        contact.countryCode = 'FR';
        contact.street1='88 rue chevalier';
        contact.postalCode='33000';
        contact.city='Bordeaux';
        contact.language = 'FR';
        
        WebServiceOrder.Plan order = new  WebServiceOrder.Plan();
        order.planProducts = new List<WebServiceOrder.PlanProduct>();
        order.planProducts.add(orderProduct);
        order.customerBilling = contact;
        order.isQuote = false;
        order.currencyISOCode='USD';
        
        contact.Company = '';
        order.isQuote = false;
        WebServiceOrder.Plan plan = WebServiceOrder.AddOrder(order);
        if(plan.status && plan.generateLicense){
            Test.startTest();
            Test.setMock(WebServiceMock.class, new FlexeraWebServiceMockImpl());
            WebServiceOrder.SendOrder(plan);
            Test.stopTest();
        }
    }
    
    @isTest static void testMain8() {
        WebServiceOrder.PlanProduct orderProduct = new WebServiceOrder.PlanProduct ();
        orderProduct.ProductCode = 'S_BAS_CMP_AN';
        orderProduct.Quantity = 3;
        orderProduct.UnitPrice = 295;
        orderProduct.productName = 'test';
        orderProduct.currencyISOCode = 'USD';                
        
        WebServiceOrder.Customer contact = new  WebServiceOrder.Customer();
        contact.FirstName = 'Martin';
        contact.LastName = 'Lezer';
        contact.Email = 'mlezer54@adinsoft.edu';
        contact.company = 'TataXW';
        contact.countryCode = 'FR';
        contact.street1='88 rue chevalier';
        contact.postalCode='33000';
        contact.city='Bordeaux';
        contact.language = 'FR'; 
        
        WebServiceOrder.Plan order = new  WebServiceOrder.Plan();
        order.planProducts = new List<WebServiceOrder.PlanProduct>();
        order.planProducts.add(orderProduct);
        order.customerBilling = contact;
        order.isQuote = false;
        order.isAutoRenewal = true;
        order.currencyISOCode='USD';
        
        WebServiceOrder.Plan plan = WebServiceOrder.AddOrder(order);
        if(plan.status && plan.generateLicense){
            Test.startTest();
            Test.setMock(WebServiceMock.class, new FlexeraWebServiceMockImpl());
            WebServiceOrder.SendOrder(plan);
            Test.stopTest();
        }
    }
    
}