/**
 * MA CountryZoneBatchable TEST
 */
@isTest
private class MA_CountryZoneBatchable_TEST {
	/** Variable Declaration */


	/**
	 * Data Setup fot the test
	 */
	@testSetup static void setup() {

		//Create common test Account
		Account account = new Account();
		account.Type = 'Client';
		account.Domaine_utilisateur__c = 'Academic';
		account.FirstName = 'Camille';
		account.LastName = 'Honnet';
		account.PersonEmail = 'camille.honnet@email.com';
		insert account;

		Account acc02 = new Account();
		acc02.Name = 'Test';
		acc02.Domaine_Utilisateur__c = 'Student';
		insert acc02;

		//Create common test Contact
		Contact contact = new Contact();
		contact.FirstName = 'Axel';
		contact.LastName = 'Air';
		contact.Email = 'axel.air@email.com';
		contact.AccountId = acc02.Id;
		insert contact;

		//Create common test Order
		Order order = new Order();
		order.AccountId = account.Id;
		order.Contact_Lie__c = contact.Id;
		order.EffectiveDate = Date.today();
		order.Status = 'Version préliminaire';
		order.BillingCountry = 'France';

		insert order;

		//Create common test Lead
		Lead lead = new Lead();
        lead.FirstName = 'Sophie';
        lead.LastName = 'Fonfek';
        lead.Email = 'sophie.fonfek@xlstat.com';
        lead.Nombre_de_telechargements__c = 2;
        lead.Country = 'Espagne';
        insert lead;

        Lead lead02 = new Lead();
        lead02.FirstName = 'Jean';
        lead02.LastName = 'Bonblanc';
        lead02.Email = 'jean.bonblanc@xlstat.com';
        lead02.Nombre_de_telechargements__c = 5;
        lead02.Country = 'France';
        insert lead02;

	}

	@isTest static void testMethod_batch() {

		System.assertEquals(0,[SELECT count() FROM MA_CountryZone__c]);

		//Batch testing
		MA_CountryZoneBatchable czb = new MA_CountryZoneBatchable();
		Id batchId = Database.executeBatch(czb);

		System.assertEquals(0,[SELECT count() FROM MA_CountryZone__c]);

		batchId = Database.executeBatch(czb);
	}
}