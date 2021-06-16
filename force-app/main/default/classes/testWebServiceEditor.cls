@isTest
private class testWebServiceEditor {

	static testMethod void testMain() {
		WebServiceEditor.Customer customer = new WebServiceEditor.Customer();
		customer.countryISOCode = 'US';
		customer.email = Label.emailAdmin;
		customer.firstName = 'martin';
		customer.lastName = 'lezer';
		customer.institution = 'Addinsoft';
		customer.isStudent = false;

		WebServiceEditor.ResultAddOrder result = WebServiceEditor.AddOrder('0012400000ESNbO', '01t24000002quGD', customer); //DEV: 0012600000LJI2N
		if (result.state) {
			Test.startTest();
			Test.setMock(WebServiceMock.class, new FlexeraWebServiceMockImpl());
			WebServiceEditor.ResultGenerateLicense result2 = WebServiceEditor.GenerateLicense('0012400000ESNbO', result.customerId, result.orderId);
			Test.stopTest();

			System.AssertEquals('Test', result2.nalpeironKey);
		}
	}
}