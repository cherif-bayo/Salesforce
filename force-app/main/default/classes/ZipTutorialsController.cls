public class ZipTutorialsController {

	public String zipFileName { get; set; }
	public String zipContent { get; set; }
	public List<ContentVersion> files { get; set; }
	public Boolean filesShown { get; set; }
	public Order emptyOrder { get; set; }
	public String lang { get; set; }

	public class FileWrapper {
		public String content { get; set; }
		public String title { get; set; }
		public String filename { get; set; }
	}

	public ZipTutorialsController() {
		lang = 'en_US';
		files = new List<ContentVersion> ();
		showFiles();
	}

	public PageReference uploadZip() {
		if (String.isEmpty(zipFileName) || String.isBlank(zipFileName)) {
			zipFileName = 'tutos.zip';
		} else {
			zipFileName.replace('.', '');
			zipFileName += '.zip';
		}

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

	public void testFiles() {
		if (files.size() > 0) {
			FileWrapper fileWrapper = ZipTutorialsController.getFileWrapper(files[0].Id);
			zipContent = fileWrapper.content;
			uploadZip();
		}
	}

	public void showFiles() {
		files.clear();
		String title = 'tuto_' + lang + '%';		
		System.debug('>>>'+title);

		// Listes des Ids de documents dont la dernière version sera affichée dans la page (en fonction des dates debut/fin et de la pagination)
		Set<Id> ContentDocumentIds = new Set<Id> ();
		List<ContentDocument> docs = [Select Id from ContentDocument where title like :title];
		for (ContentDocument doc : docs) ContentDocumentIds.add(doc.Id);

		System.debug('>>>'+docs);

		// Listes des dernières versions des documents associés aux factures
		List<ContentVersion> contentsversions = [Select title, VersionNumber, createdDate, ContentModifiedDate from ContentVersion where ContentDocumentId in :ContentDocumentIds and IsLatest = true];
		files.addAll(contentsversions);

		System.debug('>>>'+files);

		if (files.size() > 0) {
			filesShown = true;
		} else {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Pas de tutos dans cette langue'));
		}
	}

	public List<SelectOption> getLangs() {
		List<SelectOption> options = new List<SelectOption> ();
		options.add(new SelectOption('en_US', 'Anglais'));
		options.add(new SelectOption('fr', 'Français'));
		options.add(new SelectOption('es', 'Espagnol'));
		options.add(new SelectOption('de', 'Allemagne'));
		options.add(new SelectOption('ja', 'Japonais'));
		return options;
	}

	@RemoteAction
	public static FileWrapper getFileWrapper(String fileId) {
		ContentVersion file = [select title, FileExtension, versionData from ContentVersion where Id = :fileId and IsLatest = true];
		FileWrapper fileWrapper = new FileWrapper();
		fileWrapper.content = EncodingUtil.base64Encode(file.versionData);
		fileWrapper.title = file.title;
		fileWrapper.filename = file.title.replace(' ', '') + '-' + fileId + '.' + file.FileExtension;

		return fileWrapper;
	}
}