public with sharing class HelperCryptlexMetadataXlstat extends HelperCryptlexMetaData {
    public static final String CRYPTLEX_PRODUCT_CODE = '44affc53-2fc9-4942-a8bb-5f87214c8f0a';

    public override CryptlexMetaData getMetaDataForTrial() {
        CryptlexMetaData md = new CryptlexMetaData();
        md.access = 2359298; //Premium+LG+3DPlot = 2^21+2^18+2^1 = 2 359 298
        md.scope = 0;
        md.domain = Cryptlex.DOMAIN_TRIAL;
        md.productId = CRYPTLEX_PRODUCT_CODE;

        return md;
    }

    public override Long getAccess(List<String> productsToConvert) {
        Long access = 0;
        List<String> products = new List<String> ();

        // Convertie les noms de procuits avec les textes de l'enum (qui ne peuvent contenir des tirets et des chiffres)
        for (string p : productsToConvert) {
            if (Cryptlex.accessEnumTextFromProductName.keySet().contains(p)) products.add(Cryptlex.accessEnumTextFromProductName.get(p));
            else products.add(p);
        }

        System.debug('[HelperCryptlexMetaData] Liste des produits : ' + products);
        List<Cryptlex.ACCESS> accesses = Cryptlex.ACCESS.values();
        for (Cryptlex.ACCESS ac : accesses) {
            System.debug('[' + access + ']  ' + ac.name() + ' vs ' + products);
            if (products.contains(ac.name())) access += 1;
            access <<= 1;
        }
        access >>= 1;
        System.debug('[HelperCryptlexMetaData] Access : ' + access);

        return access;
    }

    public override List<String> getProducts(LicenseKey key) {
        Long access = key.metadata.access;
        List<String> products = new List<String> ();

        System.debug('[HelperCryptlexMetaData] Access : ' + access);

        List<Cryptlex.ACCESSINVERSE> accesses = Cryptlex.ACCESSINVERSE.values();
        for (Cryptlex.ACCESSINVERSE ac : accesses) {
            System.debug('[' + products + ']  ' + (access & 1));
            if ((access & 1) == 1) {
                if (Cryptlex.productNameFromAccessEnumText.keySet().contains(ac.name())) products.add(Cryptlex.productNameFromAccessEnumText.get(ac.name()));
                else products.add(ac.name());
            }
            access >>= 1;
        }
        System.debug('[HelperCryptlexMetaData] Liste des produits : ' + products);

        return products;
    }

    public override String getProductId() {
        return CRYPTLEX_PRODUCT_CODE;
    }

    // Changement du scope cryptlex user/poste pour les licences réseaux
    private Integer getScope(String licenseType) {
        Integer scope = Cryptlex.SCOPE_USER;
        if (CAMPUS_LICENCE_TYPES.contains(licenseType)) scope = Cryptlex.SCOPE_STATION;
        return scope;
    }

    // Recherche du domaine cryptlex à partir des infos de la clé
    private Integer getCryptlexDomain(String salesforceDomain, String licenseType) {
        Integer domain = cryptlex.DOMAIN_NULL;
        if (salesforceDomainToCryptlex.containsKey(salesforceDomain)) {
            domain = salesforceDomainToCryptlex.get(salesforceDomain);
        } else if (salesforceTypeToCryptlexDomain.containsKey(licenseType)) {
            domain = salesforceTypeToCryptlexDomain.get(licenseType);
        }
        return domain;
    }
}