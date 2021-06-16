@RestResource(urlMapping = '/products/v1/*')
global class WS001_Products {

	@HttpGet
	global static String getAllMyCommerceFormat() {
		RestResponse res = RestContext.response;
		Map<Id, product2> productsByIds = new Map<Id, product2> ([SELECT Name, ProductCode, PlanCode__c, Family,
		                                                         Description_courte_us__c, Description_longue_us__c,
		                                                         Description_courte_fr__c, Description_longue_fr__c,
		                                                         Description_courte_de__c, Description_longue_de__c,
		                                                         Description_courte_jp__c, Description_longue_jp__c
		                                                         from product2 where isSoldOnline__c = true]);

		// Create a Map to associate Id Product => List<Price>
		String pricebookId = UtilsCQP.getStdPricebookId();		
		Map<String, List<Price>> pricesByIdProduct = new Map<String, List<Price>> ();
		List<PriceBookEntry> priceBookEntries = [SELECT UnitPrice, Product2Id, CurrencyIsoCode
		                                         FROM PricebookEntry WHERE Pricebook2Id = :pricebookId and Product2Id in :productsByIds.keySet()];
		for (PriceBookEntry pbe : priceBookEntries) {
			List<Price> prices = pricesByIdProduct.get(pbe.Product2Id);
			if (prices == null) prices = new List<Price> ();
			prices.add(new Price(pbe.CurrencyIsoCode, pbe.UnitPrice));
			pricesByIdProduct.put(pbe.Product2Id, prices);
		}

		List<MyProduct> myProducts = new List<MyProduct> ();
		for (Product2 p : productsByIds.values()) {
			MyProduct myProduct = new MyProduct();
			myProduct.name = p.Name;
			myProduct.product_code = p.ProductCode;

			// Add proces for each currency
			myProduct.prices.addAll(pricesByIdProduct.get(p.Id));
			myProducts.add(myProduct);
		}

		JSONGenerator gen = JSON.createGenerator(false);
		gen.writeStartObject();
		gen.writeNumberField('total_results', productsByIds.keySet().size());
		gen.writeObjectField('products', myProducts);
		gen.writeEndObject();

		return gen.getAsString().replace('\"currency2\"','\"currency\"');// not my fault
	}

	Class MyProduct {
		String name;
		String product_code;
		List<Price> prices = new List<Price> ();
	}

	Class Price {
		String currency2;
		Decimal unit_price;

		public Price(String myCurrency, Decimal unit_price) {
			this.currency2 = myCurrency;
			this.unit_price = unit_price;
		}
	}
}