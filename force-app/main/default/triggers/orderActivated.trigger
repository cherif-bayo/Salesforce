trigger orderActivated on Order(before update) {
	private static String PROVENANCE_SHAREIT = 'ShareIt';
	private static String DEFAULT_CURRENCY_ISOCODE = 'EUR';
	private static Decimal CURRENCY_EUR_RATE = 1.00;

	for (Order order : Trigger.new) {
		String oldProvenance = Trigger.oldMap.get(order.Id).Provenance__c;
		String newProvenance = order.Provenance__c;

		Decimal oldNbProduct = Trigger.oldMap.get(order.Id).NbOrderItems__c;
		Decimal newNbProduct = order.NbOrderItems__c;

		Decimal oldAmount = Trigger.oldMap.get(order.Id).TotalAmountAfterDiscountShowed__c;
		Decimal newAmount = order.TotalAmountAfterDiscountShowed__c;

		Boolean OrderFraisShareItChanged = false;

		Decimal rateEUR = CURRENCY_EUR_RATE;

		if (newProvenance == PROVENANCE_SHAREIT && oldProvenance != PROVENANCE_SHAREIT) {
			Currencies_Exchange_Rates__c[] currs = [SELECT Rate__c, CurrencyIsoCode FROM Currencies_Exchange_Rates__c WHERE CurrencyIsoCode = :order.CurrencyIsoCode AND Day__c <= :order.EffectiveDate ORDER BY Day__c DESC limit 1];
			Map<String, Currencies_Exchange_Rates__c> currsByIsoCode = new Map<String, Currencies_Exchange_Rates__c> ();
			for (Currencies_Exchange_Rates__c curr : currs) {
				currsByIsoCode.put(curr.CurrencyIsoCode, curr);
			}

			Decimal rateOrder = CURRENCY_EUR_RATE;
			if (order.CurrencyIsoCode != DEFAULT_CURRENCY_ISOCODE) {
				rateOrder = currsByIsoCode.get(order.CurrencyIsoCode).Rate__c;
			}

			Decimal priceFraisShareIt = (0.75 * rateOrder) / rateEUR;

			Integer nbOrderProducts = Integer.valueof(order.NbOrderItems__c);

			order.Frais_ShareIt__c = priceFraisShareIt * nbOrderProducts + 0.049 * order.TotalAmountAfterDiscount__c;

			OrderFraisShareItChanged = true;
		} else if (newProvenance != PROVENANCE_SHAREIT) {
			order.Frais_ShareIt__c = 0;
		}

		if (oldNbProduct != newNbProduct && newProvenance == PROVENANCE_SHAREIT && OrderFraisShareItChanged == false || oldAmount != newAmount) {
			Currencies_Exchange_Rates__c[] currs = [SELECT Rate__c, CurrencyIsoCode FROM Currencies_Exchange_Rates__c WHERE CurrencyIsoCode = :order.CurrencyIsoCode AND Day__c <= :order.EffectiveDate ORDER BY Day__c DESC limit 1];
			Map<String, Currencies_Exchange_Rates__c> currsByIsoCode = new Map<String, Currencies_Exchange_Rates__c> ();
			for (Currencies_Exchange_Rates__c curr : currs) {
				currsByIsoCode.put(curr.CurrencyIsoCode, curr);
			}

			System.debug('[orderActivated] currsByIsoCode=' +currsByIsoCode);

			Decimal rateOrder = CURRENCY_EUR_RATE;
			if (order.CurrencyIsoCode != DEFAULT_CURRENCY_ISOCODE) {
				rateOrder = currsByIsoCode.get(order.CurrencyIsoCode).Rate__c;
			}

			Decimal priceFraisShareIt = (0.75 * rateOrder) / rateEUR;

			Integer nbOrderProducts = Integer.valueof(order.NbOrderItems__c);

			order.Frais_ShareIt__c = priceFraisShareIt * nbOrderProducts + 0.049 * order.TotalAmountAfterDiscount__c;
		}
	}
}