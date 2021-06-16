public class ZipFacturesController {
	private static Integer MAX_SIZE_FACTURES_PER_PAGE = Integer.ValueOf([SELECT VALUE_LIMIT__c FROM ZipFactureQueryLimit__c LIMIT 1].VALUE_LIMIT__c);

	public String zipFileName { get; set; }
	public String zipContent { get; set; }
	public List<ContentVersion> files { get; set; }
	public Boolean filesShown { get; set; }
	public Order emptyOrder { get; set; }
	public String company { get; set; }
	public String origin { get; set; }

	private Integer offsetFactures;
	private Integer maxSizeFactures;

	public Boolean GetRenderPrevious() {
		return OffsetFactures > 0;
	}
	public Boolean GetRenderNext() {
		return(OffsetFactures + MAX_SIZE_FACTURES_PER_PAGE) < MaxSizeFactures;
	}
	public Integer GetCurrentPage() {
		return OffsetFactures / MAX_SIZE_FACTURES_PER_PAGE + 1;
	}
	public Integer GetMaxPage() {
		if (math.mod(maxSizeFactures, MAX_SIZE_FACTURES_PER_PAGE) > 0) {
			return maxSizeFactures / MAX_SIZE_FACTURES_PER_PAGE + 1;
		} else {
			return(maxSizeFactures / MAX_SIZE_FACTURES_PER_PAGE);
		}
	}

	public class FileWrapper {
		public String content { get; set; }
		public String title { get; set; }
		public String filename { get; set; }
	}

	public ZipFacturesController() {
		emptyOrder = new Order();
		offsetFactures = 0;
		emptyOrder.EffectiveDate = Date.today().toStartOfMonth().addDays(- 1).toStartOfMonth(); // Premier jour du mois précédent
		emptyOrder.EndDate = Date.today().toStartOfMonth().addDays(- 1); // Dernier du jour mois précédent
		company = ParametersForOrders.FR_COMPANY; //default company
		origin = ParametersForOrders.ORIGIN_PURCHASE_ORDER; // Default Origin
		files = new List<ContentVersion> ();
		String currentPageParam = ApexPages.currentPage().getParameters().get('page');
		if (currentPageParam != null) {
			Show();
		}
	}

	public PageReference uploadZip() {
		if (String.isEmpty(zipFileName) || String.isBlank(zipFileName)) {
			zipFileName = 'factures.zip';
		} else {
			zipFileName.replace('.', '');
			zipFileName += '.zip';
		}

		// Creation d'une version de fichier
		if (zipContent != null) {
			ContentVersion v = new ContentVersion();
			v.versionData = EncodingUtil.base64Decode(zipContent);
			v.title = zipFileName;
			v.PathOnClient = zipFileName;
			v.ContentLocation = 'S';
			v.IsMajorVersion = true;
			insert v;

			zipFileName = null;
			zipContent = null;

			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, 'Fichier enregistré avec succés.'));
			PageReference returnPage = new PageReference('/' + v.Id);
			returnPage.setRedirect(true);

			return returnPage;
		}

		return null;
	}

	public void Show() {
		System.debug('company = ' + company + ' origin = ' + origin);
		MaxSizeFactures = [select count() from Facture__c where AddinSoftCompany__c = :company and Commande_lie__r.Provenance__c= :origin and Date__c >= :emptyOrder.EffectiveDate and Date__c <= :emptyOrder.EndDate];
		showFiles();
	}

	public void testFiles() {
		if (files.size() > 0) {
			FileWrapper fileWrapper = ZipFacturesController.getFileWrapper(files[0].Id);
			zipContent = fileWrapper.content;
			uploadZip();
		}
	}

	public void showFiles() {
		files.clear();
		Facture__c[] factures;

		System.debug('company = ' + company+ '  origin='+origin);
		factures = [select Id, Commande_lie__c from Facture__c where AddinSoftCompany__c = :company and Commande_lie__r.Provenance__c= :origin and Date__c >= :emptyOrder.EffectiveDate and Date__c <= :emptyOrder.EndDate LIMIT :MAX_SIZE_FACTURES_PER_PAGE OFFSET :offsetFactures];
		System.debug(' factures ='+factures);

		// Listes des Ids de factures à afficher dans la page (en fonction des dates debut/fin et de la pagination)
		Map<Id, Facture__c> facturesByIds = new Map<Id, Facture__c> ();
		for (Facture__c facture : factures) facturesByIds.put(facture.Id, facture);
		Set<Id> facturesIds = facturesByIds.keySet();
		System.debug('[ZipFacturesController#showFiles] facturesIds :' + facturesIds);

		if (facturesIds.size() > 0) {
			// Listes des Ids de documents dont la dernière version sera affichée dans la page (en fonction des dates debut/fin et de la pagination)
			Set<Id> ContentDocumentIds = new Set<Id> ();
			List<ContentDocumentLink> filesLinks = [Select ContentDocumentId from ContentDocumentLink where LinkedEntityId in :facturesIds];
			for (ContentDocumentLink fileLink : filesLinks) ContentDocumentIds.add(fileLink.ContentDocumentId);
			System.debug('[ZipFacturesController#showFiles] ContentDocumentIds :' + ContentDocumentIds);

			// Listes des dernières versions des documents associés aux factures
			List<ContentVersion> contentsversions = [Select title, VersionNumber, createdDate, ContentModifiedDate from ContentVersion where ContentDocumentId in :ContentDocumentIds and IsLatest = true];
			files.addAll(contentsversions);
			System.debug('[ZipFacturesController#showFiles] files :' + files);
		}

		if (files.size() > 0) {
			filesShown = true;
			zipFileName = 'Factures';
			zipFileName += '-' + emptyOrder.EffectiveDate.format().replace('/', '');
			zipFileName += '-' + emptyOrder.EndDate.format().replace('/', '');
			zipFileName += '-' + GetCurrentPage();
		} else {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Aucune facture trouvée entre ces deux dates.'));
		}
	}

	public List<SelectOption> getCompanies() {
		List<SelectOption> options = new List<SelectOption> ();
		options.add(new SelectOption(ParametersForOrders.FR_COMPANY, 'Addinsoft'));
		options.add(new SelectOption(ParametersForOrders.US_COMPANY, 'Addinsoft Inc'));

		return options;
	}

	public List<SelectOption> getOrigins() {
		List<SelectOption> options = new List<SelectOption> ();
		options.add(new SelectOption(ParametersForOrders.ORIGIN_STRIPE, 'Stripe'));
		options.add(new SelectOption(ParametersForOrders.ORIGIN_PURCHASE_ORDER, 'Bons de Commande'));

		return options;
	}

	@RemoteAction
	public static FileWrapper getFileWrapper(String fileId) {

		ContentVersion file = [select title, FileExtension, versionData from ContentVersion where Id = :fileId and IsLatest = true];
		FileWrapper fileWrapper = new FileWrapper();
		fileWrapper.content = EncodingUtil.base64Encode(file.versionData);
		fileWrapper.title = file.title;
		fileWrapper.filename = file.title.replace(' ', '') + '-' + fileId + '.' + file.FileExtension;
		System.debug('[ZipFacturesController#getFileWrapper] fileWrapper :' + fileWrapper);

		return fileWrapper;
	}


	public PageReference Next() {
		offsetFactures += MAX_SIZE_FACTURES_PER_PAGE;
		showFiles();

		return null;
	}

	public PageReference Previous() {
		offsetFactures -= MAX_SIZE_FACTURES_PER_PAGE;
		if (offsetFactures< 0) offsetFactures = 0;
		showFiles();

		return null;
	}
}