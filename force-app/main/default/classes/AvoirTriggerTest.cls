/**
 * Created by William on 25/09/2020.
 */


@IsTest
public with sharing class AvoirTriggerTest {
    static Order order;
    static Order orderUS;
    static {
        Account account = new Account(Name = 'Account Test');
        insert account;
        Contact contact = new Contact( AccountId = account.Id, LastName = 'Test', FirstName = 'Test', Email = 'Test@test.de');
        insert contact;
        Pricebook2 pricebook = new Pricebook2(Name = 'Test');
        insert pricebook;
        Product2 product = new Product2(Name = 'Test' );
        insert product;
        PricebookEntry pricebookEntryStandard = new PricebookEntry(Product2Id = product.Id, Pricebook2Id = Test.getStandardPricebookId(), UnitPrice = 10 );
        PricebookEntry pricebookEntry = new PricebookEntry(Product2Id = product.Id, Pricebook2Id = pricebook.Id, UnitPrice = 10 );
        insert pricebookEntryStandard;
        insert pricebookEntry;
         order = new Order(AccountId = account.Id, EffectiveDate = Date.today(), CurrencyIsoCode = 'USD', Status = 'Version préliminaire',
                Pricebook2Id = pricebook.Id, Contact_lie__c = contact.Id , AddinSoftCompany__c = ParametersForOrders.FR_COMPANY);
        insert order;
        orderUS = new Order(AccountId = account.Id, EffectiveDate = Date.today(), CurrencyIsoCode = 'USD', Status = 'Version préliminaire',
                Pricebook2Id = pricebook.Id, Contact_lie__c = contact.Id , AddinSoftCompany__c = ParametersForOrders.US_COMPANY);
        insert orderUS;
        OrderItem orderItem = new OrderItem(OrderId = order.Id, Quantity = 1, UnitPrice = 10, PricebookEntryId = pricebookEntry.Id);
        insert orderItem;
        Facture__c facture = new Facture__c(Date__c = Date.today(), Commande_lie__c = order.Id);
        insert facture;

        OrderItem orderItemUS = new OrderItem(OrderId = orderUS.Id, Quantity = 1, UnitPrice = 10, PricebookEntryId = pricebookEntry.Id);
        insert orderItemUS;
        Facture__c factureUS = new Facture__c(Date__c = Date.today(), Commande_lie__c = orderUS.Id);
        insert factureUS;
    }

    @IsTest
    static void testInitWithLabelFR (){
        Avoir__c avoir = new Avoir__c(Commande_lie__c = order.Id, Montant__c = 1000);
        Test.startTest();
        insert avoir;
        avoir = [SELECT Id, FRCreditNumber__c FROM Avoir__c WHERE Id =: avoir.Id];
        Test.stopTest();
        System.assertEquals(Decimal.valueOf(Label.startSequenceAvoirFr) , avoir.FRCreditNumber__c);
    }

    @IsTest
    static void testInitWithLabelUS() {
        Avoir__c avoir = new Avoir__c(Commande_lie__c = orderUS.Id, Montant__c = 1000);
        Test.startTest();
        insert avoir;
        avoir = [SELECT Id, USCreditNumber__c FROM Avoir__c WHERE Id =: avoir.Id];
        Test.stopTest();
        System.assertEquals(Decimal.valueOf(Label.startSequenceAvoirUS) , avoir.USCreditNumber__c);
    }

    @IsTest
    static void testSequenceWithLabelFR (){
        Avoir__c avoir = new Avoir__c(Commande_lie__c = order.Id, Montant__c = 1000);
        Avoir__c otherAvoir = new Avoir__c(Commande_lie__c = order.Id, Montant__c = 1000);
        Test.startTest();
        insert new List<Avoir__c>{avoir, otherAvoir};

        avoir = [SELECT Id, FRCreditNumber__c FROM Avoir__c WHERE Id =: otherAvoir.Id];
        Test.stopTest();
        System.assertEquals(Decimal.valueOf(Label.startSequenceAvoirFr) + 1 , avoir.FRCreditNumber__c);
    }

    @IsTest
    static void testSequenceWithLabelUS (){
        Avoir__c avoir = new Avoir__c(Commande_lie__c = orderUS.Id, Montant__c = 1000);
        Avoir__c otherAvoir = new Avoir__c(Commande_lie__c = orderUS.Id, Montant__c = 1000);

        Test.startTest();
        insert new List<Avoir__c>{avoir, otherAvoir};
        avoir = [SELECT Id, USCreditNumber__c FROM Avoir__c WHERE Id =: otherAvoir.Id];
        Test.stopTest();
        System.assertEquals(Decimal.valueOf(Label.startSequenceAvoirUS) +1 , avoir.USCreditNumber__c);
    }
}