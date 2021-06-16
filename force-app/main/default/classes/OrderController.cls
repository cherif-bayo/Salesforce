/**
 * Order Controller
 */
public class OrderController{

	public Order myOrder;
	public Integer orderItemQuantity {get;set;}
	public Decimal orderItemUnityPrice {get;set;}
	public List<wrapProduct> wrapProductList {get;set;}
	public Pricebook2 priceBook {get;set;}

	/**
	 * [OrderController description]
	 */
	public OrderController(){}
	public OrderController(ApexPages.StandardController stdController){
		this.myOrder = (Order)stdController.getRecord();

		init();
	}

	/**
	 * [init description]
	 */
	private void init(){
		
		if(ApexPages.currentPage().getParameters().get('Campaign') != null) {
			Campaign campaing = [SELECT Id, CurrencyIsoCode FROM Campaign WHERE Id = :ApexPages.currentPage().getParameters().get('Campaign') LIMIT 1];
			this.myOrder.Formations__c = campaing.Id;
			this.myOrder.Provenance__c = 'Formation';
			this.myOrder.Domaine_utilisateur__c = 'N.A.';
			this.myOrder.Type_licence__c = 'N.A.';
			this.myOrder.CurrencyIsoCode = campaing.CurrencyIsoCode;
			this.myOrder.Status = 'Version préliminaire';
			this.myOrder.EffectiveDate = system.today();
			this.orderItemQuantity = 1;
			this.orderItemUnityPrice = 0.00;

			DisplayProductList();
		}
	}

	/**
	 * [DisplayProductList description]
	 */
	public void DisplayProductList(){
		this.pricebook = [SELECT Id FROM PriceBook2 WHERE CurrencyIsoCode__c = :this.myOrder.CurrencyIsoCode AND IsStandard = false];
			this.wrapProductList = new List<wrapProduct>();
			Map<Id, Product2> productsByIds = new Map<Id, Product2>();
			productsByIds.putAll([select Id, Name, ProductCode, Type_licence_desc_EN__c, Type_licence__c, Domaine_utilisateur__c, Domaine_utilisateur_en__c FROM Product2 WHERE ProductCode LIKE 'F%' AND CurrencyIsoCode = :myOrder.CurrencyIsoCode ORDER BY Name, Family]);

			for(PricebookEntry pe : [SELECT Product2Id, UnitPrice FROM PricebookEntry WHERE Product2Id in :productsByIds.keySet() AND Pricebook2Id = :this.priceBook.Id]){
				WrapProduct wrapProduct = new WrapProduct(productsByIds.get(pe.Product2Id), pe.UnitPrice);
				this.wrapProductList.add(wrapProduct);
			}
	}

	/**
	 * [save description]
	 * @return PageReference
	 */
	public PageReference save() {
		
		/* Insert Order */
		Order o = new Order();

		try {
			this.myOrder.AccountId = [SELECT AccountId FROM Contact WHERE Id = :myOrder.Contact_Lie__c LIMIT 1].AccountId;
			this.myOrder.PriceBook2Id = this.priceBook.Id;

			o = this.myOrder;
			insert o;
			//upsert(this.myOrder);
			
		} catch(Exception e) {
				ApexPages.addMessages(e);
				return null;
		}

		/* Inser*/
		try {			
			PriceBookEntry priceBookEntry = [SELECT Id FROM PriceBookEntry WHERE ProductCode LIKE 'F_XLSTAT%' AND CurrencyIsoCode = :this.myOrder.CurrencyIsoCode AND UseStandardPrice = true LIMIT 1];

			Orderitem oi = new Orderitem();
			oi.OrderId = o.Id;
			oi.PricebookEntryId = priceBookEntry.Id;
			oi.Quantity = this.orderItemQuantity;
			oi.UnitPrice = this.orderItemUnityPrice;
			oi.Not_Apply_Discounts__c = true;
			insert oi;

		} catch(Exception e) {
			ApexPages.addMessages(e);
				return null;
		}

		//After successful Save, navigate to the default view page
		PageReference redirectSuccess = new ApexPages.StandardController(this.myOrder).view();
		return (redirectSuccess);
	}

	/**
	 * Class WrapProduct
	 */
	public class wrapProduct{
		/* Variable Declaration */
		public Product2 prod {get; set;}
		public Boolean isSelected {get; set;}
		public Decimal UnitPrice {get; set;}
		
		//Constructor
		public wrapProduct(Product2 p, Decimal unitPrice){
			this.prod = p;
			this.isSelected = false;
			this.UnitPrice = unitPrice;
		}
	}
}