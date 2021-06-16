public class OrderItemDiscount {
	private static Decimal CURRENCY_EUR_RATE = 1.00;
	private static String CURRENCY_EUR = 'EUR';
	private static String CURRENCY_USD = 'USD';
	private static String CURRENCY_JPY = 'JPY';
	private static String CURRENCY_GBP = 'GBP';

	// Calcul des discounts volumiques
	private static void updateOrderItem(OrderItem orderItem, Account account, Order order, AyPrice__DiscountDetail__c[] discountDetails, AyPrice__DiscountDetail__c[] discountDetailsMax, Map<Date, Map<String, Decimal>> ratesByDateAndCurrency, Map<Id, PricebookEntry> pricebookEntries) {
		Decimal rateEUR = 0;
		Decimal rateUSD = 0;
		Decimal rateJPY = 0;
		Decimal rateGBP = 0;
		Decimal rateOrder = 0;

		// Recuperation des taux de change en base
		Map<String, Decimal> ratesByCurrency = ratesByDateAndCurrency.get(order.EffectiveDate);
		if (ratesByCurrency != null) {
			if (ratesByCurrency.containsKey(CURRENCY_USD) && ratesByCurrency.containsKey(CURRENCY_JPY) && ratesByCurrency.containsKey(CURRENCY_GBP)) {
				rateOrder = CURRENCY_EUR_RATE;
				if (order.CurrencyIsoCode != CURRENCY_EUR) {
					rateOrder = ratesByCurrency.get(order.CurrencyIsoCode);
				}

				rateEUR = CURRENCY_EUR_RATE;
				rateUSD = ratesByCurrency.get(CURRENCY_USD);
				rateJPY = ratesByCurrency.get(CURRENCY_JPY);
				rateGBP = ratesByCurrency.get(CURRENCY_GBP);
			}
		}

		Boolean updateOrder = false;
		Boolean orderItemHasDiscount = false;

		orderItem.Percent_Discount_Coupon__c = null;
		orderItem.Percent_Discount_Total__c = null;
		orderItem.Percent_Discount_Client__c = null;
		orderItem.Percent_Discount_Manuel__c = null;

		if (!order.Editor_Auto__c) { // Ne s'applique pas aux commandes éditeurs Pearson/Cengage

			PricebookEntry peOrderItem = pricebookEntries.get(orderItem.PricebookEntryId);

			Decimal price = orderItem.UnitPrice * orderItem.Quantity;

			orderItem.Unit_Price_Discount_Volume__c = orderItem.UnitPrice;
			orderItem.Unit_Price_Facture__c = peOrderItem.UnitPrice;

			// Application des discounts volumiques sur les anciens catalogues de prix
			AyPrice__DiscountDetail__c discountDetailMax = null;
			AyPrice__DiscountDetail__c discountDetail = null;

			for (AyPrice__DiscountDetail__c dd : discountDetailsMax) {
				if (dd.AyPrice__Product_Id__c == peOrderItem.Product2.Id && dd.AyPrice__Price_Book_Id__c == peOrderItem.Pricebook2.Id) {
					discountDetailMax = dd;
					break;
				}
			}

			for (AyPrice__DiscountDetail__c dd : discountDetails) {
				if (dd.AyPrice__Product_Id__c == peOrderItem.Product2.Id && dd.AyPrice__Price_Book_Id__c == peOrderItem.Pricebook2.Id && dd.AyPrice__Range_From__c == orderItem.Quantity && dd.AyPrice__Range_To__c == orderItem.Quantity) {
					discountDetail = dd;
					break;
				}
			}

			if (discountDetailMax != null) {
				if (orderItem.Quantity >= discountDetailMax.AyPrice__Range_From__c) {
					price = discountDetailMax.Price_After_Discount__c * orderItem.Quantity;
					orderItem.Unit_Price_Catalogue__c = discountDetailMax.Price_After_Discount__c;
				} else if (discountDetail != null) {
					price = discountDetail.Price_After_Discount__c * orderItem.Quantity;
					orderItem.Unit_Price_Catalogue__c = discountDetail.Price_After_Discount__c;
				}
			} // Fin application discount volumiques

			if (peOrderItem.Product2.Id != '01t24000002qdWp' && peOrderItem.UnitPrice > 0) { // Hors produit particulier qui est le produit facturation???               
				if ((peOrderItem.UnitPrice == orderItem.UnitPrice) || account.Type == 'Distributeur') { // Distributeur ou prix = catalogue                  
					Decimal realPrice;
					if (discountDetailMax != null) {
						if (orderItem.Quantity >= discountDetailMax.AyPrice__Range_From__c) {
							price = discountDetailMax.Price_After_Discount__c * orderItem.Quantity;
							realPrice = price;
							orderItem.Unit_Price_Discount_Volume__c = discountDetailMax.Price_After_Discount__c;
						} else if (discountDetail != null) {
							price = discountDetail.Price_After_Discount__c * orderItem.Quantity;
							realPrice = price;
							orderItem.Unit_Price_Discount_Volume__c = discountDetail.Price_After_Discount__c;
						}
					}

					Decimal oldPriceDiscountClient;
					if (account.Type == 'Distributeur' && peOrderItem.UnitPrice != orderItem.UnitPrice) { // Distributeur avec prix différent du catalogue
						price = orderItem.UnitPrice * orderItem.Quantity;
						realPrice = price;
						Decimal realPriceDistributor = orderItem.Unit_Price_Discount_Volume__c > 0 ? orderItem.Unit_Price_Discount_Volume__c * orderItem.Quantity : peOrderItem.UnitPrice * orderItem.Quantity;

						orderItem.Unit_Price_Discount_Volume__c = orderItem.UnitPrice;

						if (!(orderItem.UnitPrice > peOrderItem.UnitPrice && orderItem.Quantity == 1)) {
							oldPriceDiscountClient = realPriceDistributor;
							orderItem.Percent_Discount_Client__c = ((realPriceDistributor - price) / realPriceDistributor) * 100;
						}
					}

					// Prix en fonction du discount Manuel
					if (order.Discount_Manuel__c != null && order.Discount_Manuel__c > 0 && order.Discount_Manuel_Activated__c) {
						price = price - (price * (order.Discount_Manuel__c / 100));
						orderItem.Percent_Discount_Manuel__c = order.Discount_Manuel__c;
					}

					Boolean hasCouponDiscount = order.Ref_du_coupon__c != null && order.Discount_Coupon_Activated__c;
					Boolean hasClientDiscount = account.Discount_global__c != null && order.Discount_Client_Activated__c;

					if (hasCouponDiscount) { // Prix en fonction du coupon
						Coupon__c coupon = [select Apply_Discount_Client__c, discount_GBP__c, discount_USD__c, discount_EUR__c, discount_JPY__c, Debut__c, Fin__c from Coupon__c where Id = :order.Ref_du_coupon__c];

						hasClientDiscount = coupon.Apply_Discount_Client__c && hasClientDiscount;

						if (coupon.Debut__c <= Date.today() && coupon.Fin__c >= Date.today()) {
							Decimal discount = 0;
							if (peOrderItem.CurrencyIsoCode == 'EUR') {
								discount = coupon.discount_EUR__c;
							} else if (peOrderItem.CurrencyIsoCode == 'GBP') {
								discount = coupon.discount_GBP__c;
							} else if (peOrderItem.CurrencyIsoCode == 'USD') {
								discount = coupon.discount_USD__c;
							} else if (peOrderItem.CurrencyIsoCode == 'JPY') {
								discount = coupon.discount_JPY__c;
							}
							orderItem.Percent_Discount_Coupon__c = discount;
							if (discount > 0) {
								orderItemHasDiscount = true;
							}
							price = price - (price * (discount / 100));
						}
					}

					if (hasClientDiscount) {
						price = price - (price * (account.Discount_global__c / 100));
						if (orderItem.Percent_Discount_Client__c == null) {
							orderItem.Percent_Discount_Client__c = 0;
						}
						if (oldPriceDiscountClient != null) {
							orderItem.Percent_Discount_Client__c = ((oldPriceDiscountClient - price) / oldPriceDiscountClient) * 100;
						} else {
							orderItem.Percent_Discount_Client__c = account.Discount_global__c;
						}
						if (account.Discount_global__c > 0) {
							orderItemHasDiscount = true;
						}
					}

					if (realPrice == null) {
						realPrice = peOrderItem.UnitPrice * orderItem.Quantity;
					}
					orderItem.Total_Price_Before_Discount__c = realPrice;
					orderItem.Percent_Discount_Total__c = realPrice == 0 ? 100 : ((realPrice - price) / realPrice) * 100;

					if (order.HasDiscount__c == false && orderItemHasDiscount == true) {
						order.HasDiscount__c = true;
					}
				} else {
					Decimal realPrice = peOrderItem.UnitPrice * orderItem.Quantity;
					price = orderItem.UnitPrice * orderItem.Quantity;
					orderItem.Total_Price_Before_Discount__c = price;

					if (!(orderItem.UnitPrice > peOrderItem.UnitPrice && orderItem.Quantity == 1)) {
						Decimal percentDiscount = ((realPrice - price) / realPrice) * 100;
						orderItem.Percent_Discount_Client__c = percentDiscount;
						orderItem.Percent_Discount_Total__c = percentDiscount;

						orderItemHasDiscount = true;

						if (order.HasDiscount__c == false && orderItemHasDiscount == true) {
							order.HasDiscount__c = true;
						}
					}
				}
			}

			orderItem.Total_Price_After_Discount__c = price;

			if (rateEUR != 0) {
				orderItem.Total_Price_After_DiscountEUR__c = (orderItem.Total_Price_After_Discount__c * rateEUR) / rateOrder;
				orderItem.Total_Price_After_DiscountUSD__c = (orderItem.Total_Price_After_Discount__c * rateUSD) / rateOrder;
				orderItem.Total_Price_After_DiscountJPY__c = (orderItem.Total_Price_After_Discount__c * rateJPY) / rateOrder;
				orderItem.Total_Price_After_DiscountGBP__c = (orderItem.Total_Price_After_Discount__c * rateGBP) / rateOrder;

				orderItem.UnitPriceDiscountVolumeShowedEUR__c = ((orderItem.UnitPriceDiscountVolumeShowed__c * rateEUR) / rateOrder) * orderItem.Quantity;
				orderItem.UnitPriceDiscountVolumeShowedUSD__c = ((orderItem.UnitPriceDiscountVolumeShowed__c * rateUSD) / rateOrder) * orderItem.Quantity;
				orderItem.UnitPriceDiscountVolumeShowedJPY__c = ((orderItem.UnitPriceDiscountVolumeShowed__c * rateJPY) / rateOrder) * orderItem.Quantity;
				orderItem.UnitPriceDiscountVolumeShowedGBP__c = ((orderItem.UnitPriceDiscountVolumeShowed__c * rateGBP) / rateOrder) * orderItem.Quantity;
			}

			if (peOrderItem.Product2.Type_licence__c != 'N.A.') {
				if (peOrderItem.Product2.Type_licence__c == 'Small Campus' || peOrderItem.Product2.Type_licence__c == 'Large Campus') {
					order.Type_licence__c = 'Campus';
				} else if (peOrderItem.Product2.Type_licence__c == 'Extension support et mise à jour ( 1 an )') {
					order.Type_licence__c = 'Support et maintenance ( 1 an )';
				} else {
					order.Type_licence__c = peOrderItem.Product2.Type_licence__c;
				}
			}
		}
	}

	public static void UpdateDiscountsFromCustomOrder(Order order, List<OrderItem> orderItemsToUpdate, Account account) {
		List<String> pricebookEntriesIds = new List<String> ();
		for (OrderItem orderItem : orderItemsToUpdate) {
			pricebookEntriesIds.add(orderItem.PricebookEntryId);
		}

		Set<String> pricebookIds = new Set<String> ();
		Set<String> productIds = new Set<String> ();
		Set<Decimal> quantities = new Set<Decimal> ();

		List<String> orderIds = new List<String> ();

		List<PricebookEntry> listPricebookEntries = [select Id, Product2.Id, Product2.Type_licence__c, Pricebook2.Id, CurrencyIsoCode, UnitPrice from PricebookEntry WHERE Id in :pricebookEntriesIds];
		Map<Id, PricebookEntry> pricebookEntries = new Map<Id, PricebookEntry> (listPricebookEntries);

		for (OrderItem orderItem : orderItemsToUpdate) {
			PricebookEntry peOrderItem = pricebookEntries.get(orderItem.PricebookEntryId);

			pricebookIds.add(peOrderItem.Pricebook2.Id);
			productIds.add(peOrderItem.Product2.Id);
			quantities.add(orderItem.Quantity);
			orderIds.add(orderItem.OrderId);
		}

		AyPrice__DiscountDetail__c[] discountDetails = [select Price_After_Discount__c, AyPrice__Range_From__c, AyPrice__Range_To__c, AyPrice__Price_Book_Id__c, AyPrice__Product_Id__c from AyPrice__DiscountDetail__c where AyPrice__Product_Id__c in :productIds and AyPrice__Price_Book_Id__c in :pricebookIds and AyPrice__Range_From__c in :quantities and AyPrice__Range_To__c in :quantities];

		AyPrice__DiscountDetail__c[] discountDetailsMax = [select Price_After_Discount__c, AyPrice__Product_Id__c, AyPrice__Price_Book_Id__c, AyPrice__Range_From__c from AyPrice__DiscountDetail__c where AyPrice__Product_Id__c in :productIds and AyPrice__Price_Book_Id__c in :pricebookIds and AyPrice__Range_From__c = 30];

		Map<Date, Map<String, Decimal>> ratesByDateAndCurrency = new Map<Date, Map<String, Decimal>> ();
		for (Currencies_Exchange_Rates__c exchangeRate :[SELECT Rate__c, Day__c, CurrencyIsoCode FROM Currencies_Exchange_Rates__c WHERE Day__c = :order.EffectiveDate]) {
			if (ratesByDateAndCurrency.containsKey(exchangeRate.Day__c)) {
				ratesByDateAndCurrency.get(exchangeRate.Day__c).put(exchangeRate.CurrencyIsoCode, exchangeRate.Rate__c);
			} else {
				Map<String, Decimal> ratesByCurrency = new Map<String, Decimal> ();
				ratesByCurrency.put(exchangeRate.CurrencyIsoCode, exchangeRate.Rate__c);
				ratesByDateAndCurrency.put(exchangeRate.Day__c, ratesByCurrency);
			}
		}

		for (OrderItem orderItem : orderItemsToUpdate) {
			updateOrderItem(orderItem, account, order, discountDetails, discountDetailsMax, ratesByDateAndCurrency, pricebookEntries);

			orderItem.recalculateFormulas();
		}
	}

	public static void UpdateDiscounts(Boolean fromTrigger, List<OrderItem> orderItemsToUpdate, List<String> pricebookEntriesIds) {
		Set<String> pricebookIds = new Set<String> ();
		Set<String> productIds = new Set<String> ();
		Set<Decimal> quantities = new Set<Decimal> ();

		List<String> orderIds = new List<String> ();

		System.debug('[OrderItemDiscount] pricebookEntriesIds : ' + pricebookEntriesIds);
		List<PricebookEntry> listPricebookEntries = [select Id, Product2.Id, Product2.Type_licence__c, Pricebook2.Id, CurrencyIsoCode, UnitPrice from PricebookEntry WHERE Id in :pricebookEntriesIds];
		Map<Id, PricebookEntry> pricebookEntries = new Map<Id, PricebookEntry> (listPricebookEntries);
		System.debug('[OrderItemDiscount] listPricebookEntries :' + listPricebookEntries);

		System.debug('[OrderItemDiscount] orderItemsToUpdate :' + orderItemsToUpdate);
		for (OrderItem orderItem : orderItemsToUpdate) {
			PricebookEntry peOrderItem = pricebookEntries.get(orderItem.PricebookEntryId);
			System.debug('[OrderItemDiscount] peOrderItem : ' + peOrderItem);

			pricebookIds.add(peOrderItem.Pricebook2.Id);
			productIds.add(peOrderItem.Product2.Id);
			quantities.add(orderItem.Quantity);
			orderIds.add(orderItem.OrderId);
		}

		AyPrice__DiscountDetail__c[] discountDetails = [select Price_After_Discount__c, AyPrice__Range_From__c, AyPrice__Range_To__c, AyPrice__Price_Book_Id__c, AyPrice__Product_Id__c from AyPrice__DiscountDetail__c where AyPrice__Product_Id__c in :productIds and AyPrice__Price_Book_Id__c in :pricebookIds and AyPrice__Range_From__c in :quantities and AyPrice__Range_To__c in :quantities];

		AyPrice__DiscountDetail__c[] discountDetailsMax = [select Price_After_Discount__c, AyPrice__Product_Id__c, AyPrice__Price_Book_Id__c, AyPrice__Range_From__c from AyPrice__DiscountDetail__c where AyPrice__Product_Id__c in :productIds and AyPrice__Price_Book_Id__c in :pricebookIds and AyPrice__Range_From__c = 30];

		Map<String, Order> ordersToUpdate = new Map<String, Order> ();
		Map<String, String> accountIdByOrderId = new Map<String, String> ();
		List<Date> datesOrders = new List<Date> ();
		for (Order order :[select Discount_Manuel__c, Discount_Client_Activated__c, Discount_Coupon_Activated__c, Discount_Manuel_Activated__c, CurrencyIsoCode, EffectiveDate, Type_licence__c, Id, AccountId, Ref_du_coupon__c, HasDiscount__c, HasCD__c, Account.Type, Editor_Auto__c, MontantModule__c, MontantSolution__c, MontantFormation__c, MontantExpertise__c, MontantShipping__c, MontantSupport__c from Order where Id in :orderIds]) {
			ordersToUpdate.put(order.Id, order);
			accountIdByOrderId.put(order.Id, order.AccountId);
			datesOrders.add(order.EffectiveDate);
		}

		Map<Date, Map<String, Decimal>> ratesByDateAndCurrency = new Map<Date, Map<String, Decimal>> ();
		for (Currencies_Exchange_Rates__c exchangeRate :[SELECT Rate__c, Day__c, CurrencyIsoCode FROM Currencies_Exchange_Rates__c WHERE Day__c in :datesOrders]) {
			if (ratesByDateAndCurrency.containsKey(exchangeRate.Day__c)) {
				ratesByDateAndCurrency.get(exchangeRate.Day__c).put(exchangeRate.CurrencyIsoCode, exchangeRate.Rate__c);
			} else {
				Map<String, Decimal> ratesByCurrency = new Map<String, Decimal> ();
				ratesByCurrency.put(exchangeRate.CurrencyIsoCode, exchangeRate.Rate__c);
				ratesByDateAndCurrency.put(exchangeRate.Day__c, ratesByCurrency);
			}
		}

		Map<String, Account> accountByOrderId = new Map<String, Account> ();
		for (Account account :[select Id, Discount_global__c, Type from Account where Id in :accountIdByOrderId.values() limit 1]) {
			accountByOrderId.put(account.Id, account);
		}

		for (OrderItem orderItem : orderItemsToUpdate) {
			Order order = ordersToUpdate.get(orderItem.OrderId);
			Account account = accountByOrderId.get(accountIdByOrderId.get(order.Id));

			System.debug('[orderItemDiscount] orderItem :' + orderItem);
			updateOrderItem(orderItem, account, order, discountDetails, discountDetailsMax, ratesByDateAndCurrency, pricebookEntries);
		}

		update ordersToUpdate.values();

		if (fromTrigger == false) {
			update orderItemsToUpdate;
		}
	}
}