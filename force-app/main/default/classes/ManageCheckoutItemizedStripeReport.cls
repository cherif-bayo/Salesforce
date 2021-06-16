public class ManageCheckoutItemizedStripeReport {

	private static Map<String, String> fieldNameByHeaderName = new Map<String, String> {
		'balance_transaction_id' => 'balance_transaction_id__c',
		'created_utc' => 'created_utc__c',
		'currency' => 'currency__c',
		'gross' => 'gross__c',
		'fee' => 'fee__c',
		'net' => 'net__c',
		'reporting_category' => 'reporting_category__c',
		'description' => 'description__c',
		'customer_facing_amount' => 'customer_facing_amount__c',
		'customer_facing_currency' => 'customer_facing_currency__c',
		'charge_id' => 'charge_id__c',
		/***/
		'customer_id'=> 'customer_id__c',
		'customer_email'=> 'customer_email__c',
		'charge_created_utc'=> 'charge_created_utc__c',
		'source_id'=> 'source_id__c'
	};

	private static List<String> dateFields = new List<String> { 'created_utc__c' };
	private static List<String> numberFields = new List<String> { 'gross__c', 'fee__c', 'net__c', 'customer_facing_amount__c' };

	public static void createConciliations(String payoutId, String csvPayload) {
		List<String> conciliationsLines = csvPayload.split('\n');
		System.debug('[ManageCheckoutItemizedStripeReport] conciliationsLines=' + conciliationsLines);

		// Get Header with all columns
		string[] csvFieldNames = conciliationsLines[0].replaceAll('"', '').split(',');
		System.debug('[ManageCheckoutItemizedStripeReport] csvFieldNames=' + csvFieldNames);

		Map<String, Integer> fieldNameByNumber = new Map<String, Integer> ();
		for (Integer i = 0; i<csvFieldNames.size(); i++) {
			fieldNameByNumber.put(csvFieldNames[i], i);
		}
		System.debug('[ManageCheckoutItemizedStripeReport] fieldNameByNumber=' + fieldNameByNumber);

		List<StripeReconciliation__c> conciliations = new List<StripeReconciliation__c> ();
		for (Integer i = 1; i<conciliationsLines.size(); i++) {
			StripeReconciliation__c concil = new StripeReconciliation__c(Stripe_Payouts__c = payoutId);
			string[] csvRecordData = conciliationsLines[i].replaceAll('"', '').split(',');
			System.debug('[ManageCheckoutItemizedStripeReport] csvRecordData=' + csvRecordData);
			for (String fieldName : csvFieldNames) {
				Integer fieldNumber = fieldNameByNumber.get(fieldName);
				if ( fieldNumber < csvRecordData.size()) { 
					String fieldValue = csvRecordData[fieldNumber];
					if (fieldNameByHeaderName.get(fieldName) != null && fieldValue.length()>0) setValueWithCorrectType(concil, fieldNameByHeaderName.get(fieldName), fieldValue);
				} else {
					System.debug('[ManageCheckoutItemizedStripeReport] fieldNumber=' + fieldNumber + ' csvRecordData.size()'+ csvRecordData.size());
				}
			}
			conciliations.add(concil);

			if (Math.mod(i, 100) == 0) {
				insert conciliations;
				conciliations.clear();
			}
		}
        insert conciliations;
	}

	private static void setValueWithCorrectType(StripeReconciliation__c concil,   String fieldName, String fieldValue) {
		System.debug('[ManageCheckoutItemizedStripeReport] fieldName=' + fieldName + '   fieldValue='+fieldValue);

		if (numberFields.contains(fieldName)) {
			concil.put(fieldName, Decimal.valueOf(fieldValue));
		} else if (dateFields.contains(fieldName)) {
			concil.put(fieldName, Datetime.valueOfGmt(fieldValue));
		} else {
			concil.put(fieldName, fieldValue);
		}
	}
}