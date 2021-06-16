@isTest
public class Test_TaxamoFacade  {
	
	@IsTest
	public static void testMain() {

		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('jsonTaxamoMock');
		mock.setStatusCode(200);
		mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
		Test.setMock(HttpCalloutMock.class, mock);
		
		TaxamoFacade.TaxamoServiceParams p = new TaxamoFacade.TaxamoServiceParams();
		p.currency_code = 'EUR';
		p.billing_country_code = 'MQ';
		TaxamoFacade.TaxamoInvoiceAddress pi = new TaxamoFacade.TaxamoInvoiceAddress();
		pi.building_number = '5';
		pi.street_name = 'rue de preignac';
		pi.postal_code = '33800';
		pi.city = 'bordeaux';
		pi.country = 'FR';
		p.invoice_address = pi;
		TaxamoFacade.TaxamoProductLineItem pli = new TaxamoFacade.TaxamoProductLineItem();
		pli.custom_id = 'ee';
		pli.description = 'desc';
		pli.product_code = 'xlstat';
		pli.product_type = 'software';
		pli.quantity = 1;
		pli.unit_price = 15;
		TaxamoFacade.TaxamoProductLineItem[] plis = new TaxamoFacade.TaxamoProductLineItem[1];
		plis[0] = pli;
		p.transaction_lines = plis;

		TaxamoFacade.getTaxamoJsonResponse(p,true);
	}
}