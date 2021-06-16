public virtual class  HelperCryptlexMetaData {

	protected  Map<String, Integer> salesforceDomainToCryptlex = new Map<String, Integer> {
		'Company' => Cryptlex.DOMAIN_COMPANY,
		'Academic' => Cryptlex.DOMAIN_ACADEMIC,
		'Student' => Cryptlex.DOMAIN_STUDENT,
		'Editeur' => Cryptlex.DOMAIN_EDITOR
	};

	protected  Map<String, Integer> salesforceTypeToCryptlexDomain = new Map<String, Integer> {
		'Large Campus' => Cryptlex.DOMAIN_LARGE_CAMPUS,
		'Small Campus' => Cryptlex.DOMAIN_SMALL_CAMPUS,
		'Classroom' => Cryptlex.DOMAIN_CLASSROOM
	};

	public static List<String> CAMPUS_LICENCE_TYPES = new List<String> { 'Small Campus', 'Large Campus', 'Classroom' };

	public virtual String getProductId() {
		return null;
	}

	public virtual CryptlexMetaData getMetaDataFromMap(Map<String, String> mapMetadata) {
		CryptlexMetaData md = new CryptlexMetaData();
		md.domain = Integer.valueOf(mapMetadata.get('DOMAIN'));
		md.access = Long.valueOf(mapMetadata.get('ACCESS'));
		if (mapMetadata.containsKey('SCOPE')) md.scope = Integer.valueOf(mapMetadata.get('SCOPE'));
		if (mapMetadata.keySet().contains('ENDUPD')) md.endUp = Date.valueOf(mapMetadata.get('ENDUPD'));
		md.productId = getProductId();
		return md;
	}

	public virtual  CryptlexMetaData getMetaDataForNetwork(String domain, String licenseType, List<String> products) {
		CryptlexMetaData md = new CryptlexMetaData();
		md.access = getAccess(products);
		md.domain = getCryptlexDomain(domain, licenseType);
		md.productId = getProductId();
		return md;
	}

	public virtual  CryptlexMetaData getMetaDataForPerpetual(String domain, String licenseType, List<String> products, Date dateFinSupport) {
		CryptlexMetaData md = new CryptlexMetaData();
		md.access = getAccess(products);
		md.scope = getScope(licenseType);
		md.domain = getCryptlexDomain(domain, licenseType);
		md.endUp = dateFinSupport;
		md.productId = getProductId();
		return md;
	}

	public virtual CryptlexMetaData getMetaDataForAnnual(String domain, String licenseType, List<String> products) {
		CryptlexMetaData md = new CryptlexMetaData();
		md.access = getAccess(products);
		md.scope = getScope(licenseType);
		md.domain = getCryptlexDomain(domain, licenseType);
		md.productId = getProductId();
		return md;
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

	public virtual CryptlexMetaData getMetaDataForTrial() {
		return null;
	}

	public virtual Long getAccess(List<String> productsToConvert) {
		return 1;
	}

	public virtual List<String> getProducts(LicenseKey key) {
		return null;
	}
}