global class TaxamoTransaction {

	@InvocableMethod(label = 'Create a transaction in Taxamo' description = 'Record a new transaction in the big book Taxamo')
	global static void createTaxamoTransaction(List<Order> orders) {
		System.debug ('[TaxamoTransaction]  createTaxamoTransaction orderNumbers='+orders);

		List<String> orderNumbers = new List<String>();
		for (Order o :orders) orderNumbers.add(o.orderNumber);

		List<Order> ordersWithId = [select Id from Order where OrderNumber in :orderNumbers];
		System.debug ('[TaxamoTransaction]  createTaxamoTransaction ordersWithId='+ordersWithId);		

		for (Order o :ordersWithId) System.enqueueJob(new OrderLineItemTaxes(o.Id, true)); //true => archived
	}
}