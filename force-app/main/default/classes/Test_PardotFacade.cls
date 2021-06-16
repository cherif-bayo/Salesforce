@isTest
private class Test_PardotFacade {

	@isTest
	private static void test_upsertProspectsWithListAssociated() {
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('PardotWebServiceMock');
		mock.setStatusCode(200);
		mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
		Test.setMock(HttpCalloutMock.class, mock);

		String listId = 'test';

		List<Pardot.Prospect> prospects = new List<Pardot.Prospect> ();
		Pardot.Prospect p = new Pardot.Prospect();
		p.fid = 'test';
		p.first_name = 'test';
		p.last_name = 'test';
		p.email = 'test';
		p.Montant_Panier = 42;
		p.Produit_Panier = 'test';
		p.Devise_Panier = 'test';
		prospects.add(p);

		PardotFacade.upsertProspectsWithListAssociated(prospects, listId);
	}
}