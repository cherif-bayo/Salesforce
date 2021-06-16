@IsTest
public class Test_HelperCryptlexMetaData {

	private static Map<String, String> mapMetadata = new Map<String, String> {
		'DOMAIN' => '1',
		'ACCESS' => '6',
		'SCOPE' => '1',
		'USERID' => '5',
		'ENDUPD' => '2010-02-05'
	};

	@TestSetup
	private static void setup() {
		List<Software__c> softwares = new List<Software__c>{
				new Software__c(
						AccessType__c='Multiple', DevelopmentDone__c=true,
						Code__c='00',
						Name='XLSTAT',
						ProductId__c='44affc53-2fc9-4942-a8bb-5f87214c8f0a'
				),
				new Software__c(
						AccessType__c='Simple',
						Code__c='01',
						Name='XLRISK',
						ProductId__c='abb8ac81-f3a1-402a-a5e5-e90b444aa933'
				)
		};
		insert softwares;
	}

	@IsTest
	public static void testMain() {
		HelperCryptlexMetaData hcmd = new HelperCryptlexMetadataXlstat();
		CryptlexMetaData mdTrial = hcmd.getMetaDataForTrial();
		CryptlexMetaData mdNetwork = hcmd.getMetaDataForNetwork('domain', 'licenseType',new List<String> { 'product' });
		CryptlexMetaData mdPerpetuel = hcmd.getMetaDataForPerpetual('domain', 'licenseType',new List<String> { 'product' }, Date.today());
		CryptlexMetaData mdAnnual = hcmd.getMetaDataForAnnual('domain', 'licenseType', new List<String> { 'product' });

		System.assert(mdTrial != null);
		System.assert(mdNetwork != null);
		System.assert(mdPerpetuel != null);
		System.assert(mdAnnual != null);
	}

	@IsTest
	public static void testMainSimpleAccess() {
		List<Software__c> softwares = [SELECT Id, Name, Code__c, AccessType__c, ProductId__c, CurrencyIsoCode FROM Software__c];
		HelperCryptlexMetaData hcmd = new HelperCryptlexMetadataSimpleAccess(softwares[1]);
		CryptlexMetaData mdTrial = hcmd.getMetaDataForTrial();
		CryptlexMetaData mdNetwork = hcmd.getMetaDataForNetwork('domain', 'licenseType',new List<String> { 'product' });
		CryptlexMetaData mdPerpetuel = hcmd.getMetaDataForPerpetual('domain', 'licenseType',new List<String> { 'product' }, Date.today());
		CryptlexMetaData mdAnnual = hcmd.getMetaDataForAnnual('domain', 'licenseType', new List<String> { 'product' });

		System.assert(mdTrial != null);
		System.assert(mdNetwork != null);
		System.assert(mdPerpetuel != null);
		System.assert(mdAnnual != null);
	}

	@IsTest
	public static void testProducts() {
		LicenseKey key = new LicenseKey();
		CryptlexMetaData md = new CryptlexMetaData();
		md.access = 1;
		key.metadata = md;
		HelperCryptlexMetaData hcmd = new HelperCryptlexMetadataXlstat();
		List<String> products = hcmd.getProducts(key);
		System.assertEquals(1, products.size());
	}
}