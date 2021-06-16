@isTest
public class OrderControllerPersonnaliseTest {
	@testSetup static void fillProductPrices() {
		Currencies_Exchange_Rates__c rate = new Currencies_Exchange_Rates__c();
		rate.Day__c = Date.today();
		rate.CurrencyIsoCode = 'USD';
		rate.Rate__c = 1;

		insert rate;

		Pricebook2 pricebook = new Pricebook2();
		pricebook.Name = 'Test';
		pricebook.CurrencyIsoCode = 'USD';
		pricebook.CurrencyIsoCode__c = 'USD';

		insert pricebook;

		Product2 product = new Product2();
		product.Name = 'Test';
		product.Type_Licence__c = 'Annual';
		product.Domaine_Utilisateur__c = 'Etudiant';
		product.ProductCode = 'S_BAS_STU_AN';
		product.Family = 'test';

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

		AyPrice__DiscountDetail__c discount = new AyPrice__DiscountDetail__c();
		discount.Price_After_Discount__c = 10;
		discount.AyPrice__Range_From__c = 1;
		discount.AyPrice__Range_To__c = 1;
		discount.AyPrice__Price_Book_Id__c = pricebook.Id;
		discount.AyPrice__Product_Id__c = product.Id;

		insert discount;

		Coupon__c coupon = new Coupon__c(Name = 'test',
		                                 DomainName__c = 'STUDENT',
		                                 Fin__c = Date.today().addDays(1),
		                                 Debut__c = Date.today().addDays(- 1),
		                                 Discount_EUR__c = 10,
		                                 Discount_USD__c = 10,
		                                 Discount_JPY__c = 10,
		                                 Discount_GBP__c = 10);
		insert coupon;

		Account account = new Account();
		account.Name = 'Test';
		account.Domaine_Utilisateur__c = 'Student';

		insert account;

		Contact contact = new Contact();
		contact.FirstName = 'Test';
		contact.LastName = 'Test';
		contact.Email = 'test@test.com';
		contact.AccountId = account.Id;

		insert contact;
	}

	@isTest static void testMain() {
		Coupon__c coupon = [SELECT Id FROM Coupon__c LIMIT 1];
		Contact contact = [SELECT Id FROM Contact LIMIT 1];

		OrderControllerPersonnalise controller = new OrderControllerPersonnalise();
		controller.SelectedDomaine = controller.getDomaineList() [1].getValue();
		controller.RefreshLicences();
		controller.getSalutationList();
		controller.getStateList();
		controller.RefreshDiscountManual();
		controller.RefreshDiscountClient();
		controller.Refresh();
		controller.MyOrder.Contact_Lie__c = contact.Id;
		controller.SelectedProvenance = controller.getProvenance() [0].getValue();
		controller.AppearReferenceField();
		controller.SelectedProvenance = controller.getProvenance() [1].getValue();
		controller.AppearReferenceField();
		controller.SelectedStatutClient = controller.getStatutClient() [1].getValue();
		controller.AppearClientFields();
		controller.SelectedStatutClient = controller.getStatutClient() [2].getValue();
		controller.AppearClientFields();
		controller.SelectedStatutClient = controller.getStatutClient() [1].getValue();
		controller.AppearClientFields();
		controller.SelectedStatutClientFinal = controller.getStatutClientFinal() [0].getValue();
		controller.AppearClientFinalFields();
		controller.SelectedStatutCompteClientFinal = controller.getStatutCompteClientFinal() [0].getValue();
		controller.SelectedStatutClientFinal = controller.getStatutClientFinal() [1].getValue();
		controller.AppearClientFinalFields();
		controller.SelectedStatutCompteClientFinal = controller.getStatutCompteClientFinal() [1].getValue();
		controller.AppearClientFinalFields();
		controller.SelectedStatutClientFinal = controller.getStatutClientFinal() [2].getValue();
		controller.AppearClientFinalFields();
		controller.SelectedLicence = 'Annual';
		controller.DupliquerAdresse();
		controller.ClientFinalAccount = controller.PersonAccount;
		controller.DupliquerAdresseClientFinal();
		controller.RefreshCoupon();
		controller.getProductList();
		controller.IsOldProductSelected = false;
		controller.Refresh();
		controller.UpdatePricebook();
		controller.wrapProductList[0].IsSelected = true;
		controller.AddLicence();
		controller.RowId = controller.wrapProductList[0].prod.Id;
		controller.UpdateDIscount();
		controller.SelectedStatutClient = controller.getStatutClient() [1].getValue();
		controller.PersonAccount.Name = 'Test';
		controller.ClientFinalAccount.Name = 'Test2';
		controller.NewContact.FirstName = 'Axel';
		controller.NewContact.LastName = 'Air';
		controller.NewContact.Email = 'axe.air@email.com';
		controller.Valider();
		controller.getTotalPriceOrder();
		controller.RowId = controller.wrapProductList[0].prod.Id;
		controller.ProductsOrderItems[0].GetTotalPrice();
		controller.Remove();
	}

	@isTest static void testMain2() {
		Coupon__c coupon = [SELECT Id FROM Coupon__c LIMIT 1];
		Contact contact = [SELECT Id FROM Contact LIMIT 1];

		OrderControllerPersonnalise controller = new OrderControllerPersonnalise();
		controller.SelectedDomaine = controller.getDomaineList() [1].getValue();
		controller.getSalutationList();
		controller.getStateList();
		controller.RefreshDiscountManual();
		controller.RefreshDiscountClient();
		controller.Refresh();
		controller.MyOrder.Contact_Lie__c = contact.Id;
		controller.SelectedStatutClient = controller.getStatutClient() [0].getValue();
		controller.AppearClientFields();
		controller.SelectedProvenance = controller.getProvenance() [0].getValue();
		controller.AppearReferenceField();
		controller.SelectedProvenance = controller.getProvenance() [1].getValue();
		controller.AppearReferenceField();
		controller.SelectedLicence = 'Annual';
		controller.MyOrder.Ref_du_Coupon__c = coupon.Id;
		controller.RecupAccountName();
		controller.DupliquerAdresse();
		controller.RefreshCoupon();
		controller.getProductList();
		controller.IsOldProductSelected = false;
		controller.Refresh();
		controller.wrapProductList[0].IsSelected = true;
		controller.AddLicence();
		controller.Valider();
		controller.getTotalPriceOrder();
		controller.RowId = controller.wrapProductList[0].prod.Id;
		controller.ProductsOrderItems[0].GetTotalPrice();
		controller.Remove();
	}

	@isTest static void testMain3() {
		Coupon__c coupon = [SELECT Id FROM Coupon__c LIMIT 1];
		Contact contact = [SELECT Id FROM Contact LIMIT 1];

		OrderControllerPersonnalise controller = new OrderControllerPersonnalise();
		controller.SelectedDomaine = controller.getDomaineList() [1].getValue();
		controller.getSalutationList();
		controller.getStateList();
		controller.RefreshDiscountManual();
		controller.RefreshDiscountClient();
		controller.Refresh();
		controller.MyOrder.Contact_Lie__c = contact.Id;
		controller.SelectedProvenance = controller.getProvenance() [0].getValue();
		controller.AppearReferenceField();
		controller.SelectedProvenance = controller.getProvenance() [1].getValue();
		controller.AppearReferenceField();
		controller.SelectedStatutClient = controller.getStatutClient() [2].getValue();
		controller.AppearClientFields();
		controller.SelectedLicence = 'Annual';
		controller.MyOrder.Ref_du_Coupon__c = coupon.Id;
		controller.DupliquerAdresse();
		controller.RefreshCoupon();
		controller.getProductList();
		controller.IsOldProductSelected = false;
		controller.Refresh();
		controller.wrapProductList[0].IsSelected = true;
		controller.AddLicence();
		controller.PersonAccount.FirstName = 'Test';
		controller.PersonAccount.LastName = 'Test';
		controller.PersonAccount.PersonEMail = 'Test@test.com';
		controller.Valider();
		controller.getTotalPriceOrder();
		controller.RowId = controller.wrapProductList[0].prod.Id;
		controller.ProductsOrderItems[0].GetTotalPrice();
		controller.Remove();
	}

	@IsTest static void testExtensionAddProduct() {
		Contact contact = [SELECT Id FROM Contact LIMIT 1];
		Account account = [SELECT Id FROM Account LIMIT 1];
		Pricebook2 p = [SELECT Id FROM Pricebook2 LIMIT 1];
		PricebookEntry pe = [SELECT Id, UnitPrice FROM PricebookEntry WHERE Pricebook2Id = :p.Id LIMIT 1];

		Order order = new Order();
		order.Status = 'Version préliminaire';
		order.EffectiveDate = Date.today();
		order.AccountId = account.Id;
		order.Contact_Lie__c = contact.Id;
		order.Pricebook2Id = p.Id;

		insert order;

		OrderItem orderItem = new OrderItem();
		orderItem.OrderId = order.Id;
		orderItem.PricebookEntryId = pe.Id;
		orderItem.UnitPrice = pe.UnitPrice;
		orderItem.Quantity = 1;

		insert orderItem;

		PageReference pageRef = Page.OrderAddProducts;
		Test.setCurrentPage(pageRef);

		ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(order);
		OrderAddProductsExtension controller = new OrderAddProductsExtension(sc);
	}
}