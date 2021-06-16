@IsTest
public class StripeExpiredLicenseEmailTest{   
    
    @isTest
    public static void testSchedulable(){
        Account account = new Account();
        account.Name = 'Test';
        account.Type = 'Client';
        
        insert account;
        
        Account accountDistrib = new Account();
        accountDistrib.Name = 'TestDistrib';
        accountDistrib.Type = 'Distributeur';
        
        insert accountDistrib;
        
        Order order = new Order();
        order.EffectiveDate = Date.today();
        order.Status = 'Version préliminaire';
        order.AccountId = account.Id;
        order.Provenance__c = 'Bon de commande';
        
        insert order;
        
        Order orderStripe = order.clone(false, true);
        orderStripe.Provenance__c = 'Stripe';
        
        insert orderStripe;
       
        Order orderDistrib = order.clone(false, true);
        orderDistrib.AccountId = accountDistrib.Id;
        
        insert orderDistrib;
        
        Contact contact = new Contact();
        contact.FirstName = 'Test';
        contact.LastName = 'Test';
        contact.Email = 'test@test.com';
        contact.AccountId = account.Id;
        
        insert contact;
        
        Contact contactFR = contact.clone(false, true);
        contactFR.Email = 'test2@test.com';
        contactFR.Langue__c = 'FR';
        
        insert contactFR;
        
        Contact contactUS = contact.clone(false, true);
        contactUS.Email = 'testEN@test.com';
        contactUS.Langue__c = 'US';
        
        insert contactUS;
        
        Contact contactWithMyAccount = contact.clone(false, true);
        contactWithMyAccount.Compte_MyAccount_cree__c = true;
        contactWithMyAccount.Email = 'test3@test.com';
        
        insert contactWithMyAccount;
        
        Version__c version = new Version__c();
        version.Name = 'Test';
        version.Date__c = Date.today();
        
        insert version;
        
        Flexera_Key__c keySTU = new Flexera_Key__c();
        keySTU.Name = 'Test';
        keySTU.Entitlement_Id__c = 'Test';
        keySTU.Contact__c = contact.Id;
        keySTU.Version__c = version.Id;
        keySTU.Date_Limite__c = Date.today().addDays(3);
        keySTU.Quantity__c = 1;
        keySTU.XLSTAT_Solution__c = 'XLSTAT-Premium';
        keySTU.XLSTAT_Options__c = '';
        keySTU.Domaine_Utilisateur__c = 'Company';
        keySTU.Type_Licence__c = 'Perpétuelle';
        keySTU.Expiration__c = 'Permanent';
        keySTU.Order__c = order.Id;
        
        insert keySTU;
        
        Flexera_Key__c keyNotExpired = keySTU.clone(false, true);
        keyNotExpired.Date_Limite__c = Date.today().addDays(4);
        
        insert keyNotExpired;
        
        Flexera_Key__c keyDistrib = keySTU.clone(false, true);
        keyDistrib.Order__c = orderDistrib.Id;
        
        insert keyDistrib;
        
        Flexera_Key__c keyExpiringStripe = keySTU.clone(false, true);
        keyExpiringStripe.Expiration__c = 'Expiring';
        keyExpiringStripe.Order__c = orderStripe.Id;
        keyExpiringStripe.Domaine_Utilisateur__c = 'Company';
        
        insert keyExpiringStripe;
       
        Flexera_Key__c keyExpiringNotStripeQuantity6 = keyExpiringStripe.clone(false, true);
        keyExpiringNotStripeQuantity6.Order__c = order.Id;
        keyExpiringNotStripeQuantity6.Quantity__c = 6;
        
        insert keyExpiringNotStripeQuantity6;
        
        Flexera_Key__c keyExpiringNotStripeQuantity5NotMyAccount = keyExpiringNotStripeQuantity6.clone(false, true);
        keyExpiringNotStripeQuantity5NotMyAccount.Order__c = order.Id;
        keyExpiringNotStripeQuantity5NotMyAccount.Quantity__c = 5;
        
        insert keyExpiringNotStripeQuantity5NotMyAccount;
        
        Flexera_Key__c keyExpiringNotStripeQuantity5MyAccount = keyExpiringNotStripeQuantity5NotMyAccount.clone(false, true);
        keyExpiringNotStripeQuantity5MyAccount.Contact__c = contactWithMyAccount.Id;
        
        insert keyExpiringNotStripeQuantity5MyAccount;
        
        Flexera_Key__c keyPermanentShareIt = keySTU.clone(false, true);
        keyPermanentShareIt.Expiration__c = 'Permanent';
        keyPermanentShareIt.Order__c = orderStripe.Id;
        keyPermanentShareIt.Domaine_Utilisateur__c = 'Academic';
        
        insert keyPermanentShareIt;
        
        Flexera_Key__c keyPermanentNotShareItQuantity6 = keyPermanentShareIt.clone(false, true);
        keyPermanentNotShareItQuantity6.Order__c = order.Id;
        keyPermanentNotShareItQuantity6.Quantity__c = 6;
        
        insert keyPermanentNotShareItQuantity6;
        
        Flexera_Key__c keyPermanentNotShareItQuantity5NotMyAccount = keyPermanentNotShareItQuantity6.clone(false, true);
        keyPermanentNotShareItQuantity5NotMyAccount.Order__c = order.Id;
        keyPermanentNotShareItQuantity5NotMyAccount.Quantity__c = 5;
        
        insert keyPermanentNotShareItQuantity5NotMyAccount;
        
        Flexera_Key__c keyPermanentNotShareItQuantity5MyAccount = keyPermanentNotShareItQuantity5NotMyAccount.clone(false, true);
        keyPermanentNotShareItQuantity5MyAccount.Contact__c = contactWithMyAccount.Id;
        
        insert keyPermanentNotShareItQuantity5MyAccount;
        
        Flexera_Key__c keyExpiringNotStripeQuantity6FR = keyExpiringNotStripeQuantity6.clone(false, true);
        keyExpiringNotStripeQuantity6FR.Contact__c = contactFR.Id;
        
        insert keyExpiringNotStripeQuantity6FR;        
        
        Flexera_Key__c keyWithManualRelance = keyExpiringNotStripeQuantity6FR.clone(false, true);
        keyWithManualRelance.Relance_manuelle__c = true;
        keyWithManualRelance.Name = 'TestManualRelanceStripe';
        
        insert keyWithManualRelance; 

		Flexera_Key__c keyExpiringNotStripeQuantity6US = keyExpiringNotStripeQuantity6.clone(false, true);
        keyExpiringNotStripeQuantity6US.Contact__c = contactUS.Id;
        
        insert keyExpiringNotStripeQuantity6US;         
        
        Flexera_Key__c keyWithManualRelanceStripe = keyExpiringNotStripeQuantity6FR.clone(false, true);
        keyWithManualRelanceStripe.Relance_manuelle__c = true;
        keyWithManualRelanceStripe.Name = 'TestManualRelanceStripe';
        
        insert keyWithManualRelanceStripe; 
       
        Test.StartTest();        
        Database.executeBatch(new StripeExpiredLicenseEmailBatchable(), 200);
        Test.StopTest();
        
        List<Flexera_key__c> keys = [SELECT Date_Relance__c, Relance_manuelle__c, XLSTAT_Solution__c FROM Flexera_Key__c WHERE Id = :keySTU.Id];
        
        String jobId = System.schedule('ScheduleApexClassTestStripe', '0 0 0 15 3 ? 2022', new StripeExpiredLicenseEmailSchedulable());
        
        for (Flexera_key__c key :keys) System.assertEquals('XLSTAT-Premium', key.XLSTAT_Solution__c);
    }
}