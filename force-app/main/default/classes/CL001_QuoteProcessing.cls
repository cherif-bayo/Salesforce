public class CL001_QuoteProcessing implements Schedulable {
	public static String CODE_OK = '00';
	public static String CODE_ERREUR_QUOTE_NOT_FOUND = '01';

	private Quote quote;
	private String locale;
	private String customerEmail;
	private CL001_UTL_EmailCreationForSendingQuote.QuoteType orderQuoteType;

	public CL001_QuoteProcessing(String quoteId, String locale, String customerEmail, CL001_UTL_EmailCreationForSendingQuote.QuoteType orderQuoteType) {
		String status = CODE_OK;
		Quote[] quotes = [select Id, GenerateFactureEN__c, QuoteNumber, CurrencyISOCode, Opportunity.Client_Final__c, Opportunity.Contact_Lie__c from Quote where Id = :quoteId];

		System.debug('[CL001_QuoteProcessing#sendQuoteOrWireTransferOrChekOrder] quotes :' + quotes);
		if (quotes.size() > 0) {
			this.quote = quotes[0];
			this.locale = locale;
			this.orderQuoteType = orderQuoteType;
			this.customerEmail = customerEmail;
		}
	}

	public void execute(System.SchedulableContext ctx) {
		String status;

		// Creation du pdf : choix du compte bancaire à référencer
		PageReference pg;
		if (quote.currencyIsoCode == 'JPY') pg = new PageReference('/apex/quote_jp?id=' + quote.Id);
		else if (!quote.GenerateFactureEN__c) pg = new PageReference('/apex/quote_fr?id=' + quote.Id);
		else pg = new PageReference('/apex/quote_en?id=' + quote.Id);

		System.debug('[CL001_QuoteProcessing#sendQuote] PDF generation for quote : ' + quote.id);
		Blob b;
		if (Test.isRunningTest()) {
			b = blob.valueOf('Unit.Test');
		} else {
			b = pg.getContent();
		}

		// Creation du custom Sobject quoteDoc avec le devis en PDF             
		QuoteDocument quotedoc = new QuoteDocument();
		quotedoc.Document = b;
		quotedoc.QuoteId = quote.id;
		insert quotedoc;

		// Creation d'une pience jointe avec le devis en PDF
		Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
		efa.setFileName(getFileNameAttachment());
		efa.setBody(b);

		// Creation du mail de devis
		CL001_UTL_EmailCreationForSendingQuote.EmailInfos infos = new CL001_UTL_EmailCreationForSendingQuote.EmailInfos();
		infos.contactId = quote.Opportunity.Client_final__c == null ? quote.Opportunity.Contact_Lie__c : quote.Opportunity.Client_Final__c;
		infos.currencyISOCode = quote.currencyISOCode;
		infos.customerEmail = customerEmail;
		infos.locale = locale;
		infos.quotedocId = quotedoc.Id;
		infos.quoteId = quote.Id;
		infos.quoteNumber = quote.quoteNumber;
		infos.orderQuoteType = orderQuoteType;

		Messaging.SingleEmailMessage email = CL001_UTL_EmailCreationForSendingQuote.create(infos);
		email.setFileAttachments(new Messaging.EmailFileAttachment[] { efa });
		Messaging.SendEmailResult[] sendEmailResult = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });

		if (!sendEmailResult[0].success) {
			insert new WS_Error__c(Email__c = customerEmail, RecordId__c = quotedoc.Id, WebserviceName__c = 'email', Request__c = 'Le mail de devis pour ' + quote.QuoteNumber + ' n\'a pu être envoyé');
		}
	}

	private String getFileNameAttachment() {
		String fileName = locale == 'fr' ? 'XLSTAT_devis_' : 'XLSTAT_quote_';
		return fileName + quote.QuoteNumber + '.pdf';
	}

}