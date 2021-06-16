/**
 * Created by RCOR on 16/10/2020.
 */

public with sharing class HelperCryptlexMetadataSimpleAccess extends HelperCryptlexMetaData {

    private static Software__c software;
    public static final Long SIMPLE_ACCESS = 1;


    public HelperCryptlexMetadataSimpleAccess(Software__c sofware) {
        software = sofware;
    }

    public override CryptlexMetaData getMetaDataForTrial() {
        CryptlexMetaData md = new CryptlexMetaData();
        md.access = SIMPLE_ACCESS;
        md.scope = 0;
        md.domain = Cryptlex.DOMAIN_TRIAL;
        md.productId = getProductId();
        return md;
    }

    public override Long getAccess(List<String> productsToConvert) {
        return SIMPLE_ACCESS;
    }

    public override String getProductId() {
        return software.ProductId__c;
    }

    public override List<String> getProducts(LicenseKey key) {
        return new List<String>{ new SoftwareService().getSoftwareNameFromCryptlexProductId(key.productId) };
    }
}