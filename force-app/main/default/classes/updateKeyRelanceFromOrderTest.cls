@isTest
public  with sharing class updateKeyRelanceFromOrderTest {
    
    @isTest
    public static void testupdateKey() {
		// Create Common test Account
        Account act = new Account();
        act.Type = 'Client';
        act.Name ='BAYO Co';
       	act.Domaine_utilisateur__c = 'Student';
        
       	insert act;
        
        // Create Contact 
        Contact ct = new Contact();
        ct.LastName = 'BAYO';
        ct.FirstName = 'Cherif';
        ct.AccountId = act.Id;
        ct.Email = 'cbayo@xlstat.com';
        
        Map<Id,Order> oldmap = new Map<Id,Order>();
        Map<Id,Order> newmap = new Map<Id,Order>();
        
        Order od = new Order();
        od.Status = ' Version Préliminaire';
        od.Domaine_utilisateur__c = 'Student';
        od.AccountId = act.Id;
        od.Autorenewalable__c = true;
        od.EffectiveDate = Date.today();
        
        insert od;
        oldmap.put(od.id, od);
        
        od = [SELECT Id, Autorenewalable__c FROM Order WHERE Id = :od.Id];

		System.assertEquals(true, od.Autorenewalable__c);

		od.AccountId = act.Id;
        
        //Create common test flexera_key
        Flexera_Key__c keyToUpdate = new Flexera_Key__c();
        keyToUpdate.Account__c = act.Id;
        keyToUpdate.Contact__c = ct.Id;
        keyToUpdate.Date_limite__c = Date.today();
        keyToUpdate.Quantity__c = 1;
        keyToUpdate.Expiration__c = 'Expiring';
        keyToUpdate.Entitlement_Id__c = 'Test';
        keyToUpdate.Nb_activations_allowed__c = 1;
        keyToUpdate.Domaine_utilisateur__c = 'Company';
        keyToUpdate.Type_licence__c = 'Annuelle';
        keyToUpdate.Date_limite__c = Date.today();
        keyToUpdate.XLSTAT_Solution__c = 'XLSTAT-Premium';
        keyToUpdate.Relance_manuelle__c = false;
        insert keyToUpdate;
        
        keyToUpdate = [SELECT Id, Relance_manuelle__c FROM Flexera_key__c WHERE Id = :keyToUpdate.Id];

		System.assertEquals(false, keyToUpdate.Relance_manuelle__c);
        
	    Test.startTest();
        od.Autorenewalable__c = false;
        keyToUpdate.Relance_manuelle__c = true;
        update od;
        update keyToUpdate;
		Test.stopTest();
    }
      
}