@isTest
public class TEST001_UTL_OrderProcessingAcad {

	@IsTest
	public static void casNominal() {

		Account acc = new Account(Name = 'testAccount');
		insert acc;

		String email = 'moi@xlstat.com';
		Boolean myAccount = false;

		CL001_UTL_OrderProcessingAcad.isSendingKeyAuthorized(email, acc.Id, myAccount);
	}

}