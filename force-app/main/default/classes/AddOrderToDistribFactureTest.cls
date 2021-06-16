@isTest
public class AddOrderToDistribFactureTest{

	@isTest
     public static void testMain(){
         Account account = new Account();
         account.Type = 'Distributeur';
         account.Name = 'test';
		 account.BillingCountry = 'France';
         
         insert account;
         
         Order order = new Order();
         order.AccountId = account.Id;
         Date dateToday = Date.today();
         order.EffectiveDate = Date.newInstance(dateToday.year(), dateToday.month() - 3, dateToday.day());
         order.Status = 'Version préliminaire';
		 order.BillingCountry = 'France';
         
         insert order;
         
         Facture_distributeur__c facture = new Facture_distributeur__c();
         facture.Compte_lie__c = account.Id;
         
         insert facture;
         
         AddOrderToDistribFacture controller = new AddOrderToDistribFacture();
         controller.IdFacture = facture.Id;
         
         Test.startTest();
         controller.Initialize();
         controller.DeSelectAlll();
         controller.SelectAlll();
         controller.AddOrders();
         controller.Cancel();
         Test.stopTest();
         
         order = [SELECT TotalAmountAfterDiscountShowed__c, Ref_Facture_distributeur__c FROM Order WHERE Id = :order.Id limit 1];
         facture = [SELECT Id, Montant_commandes_selectionnees__c FROM Facture_distributeur__c WHERE Id = :facture.Id limit 1];
         
         System.assertEquals(facture.Id, order.Ref_Facture_distributeur__c);
         System.assertEquals(facture.Montant_commandes_selectionnees__c, 0);
         
         order.Ref_Facture_distributeur__c = null;
         update order;
         
         System.assertEquals(facture.Montant_commandes_selectionnees__c, 0);
     }
 }