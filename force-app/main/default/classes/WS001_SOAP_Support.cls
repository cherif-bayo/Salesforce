global class WS001_SOAP_Support {
	private final static String LEAD_SOURCE = 'Ticket Support';

	global class Ticket {
		webservice String email;
		webservice String subject;
		webservice String message;
		webservice String lang;
		webservice String numoKey;
		webservice List<String> labels;
		webservice String xlstatversion;
		webservice String excelversion;
		webservice String excelDetailedversion;
		webservice String source;
	}

	global class Attachment {
		webservice String filename;
		webservice String mimetype;
		webservice String content;
	}

	webservice static String createTicket(Ticket ticket) {
		System.debug('[WS001_SOAP_Support#createTicket : Appel WS pour un nouveau Ticket : Ticket=' + ticket);

		// Creation du ticket
		Case aCase = new Case(subject = ticket.subject,
		                      Origin = ticket.source,
		                      Description = ticket.message,
		                      language__c = ticket.lang,
		                      custom_excel__c = ticket.excelversion,
		                      custom_excel_number__c = ticket.excelDetailedversion,
		                      custom_xlstat_version__c = ticket.xlstatversion);
		try {

			// Rattachement à un contact ou lead existant avec l' email du ticket
			if (ticket.email != null && ticket.email.length() > 0) {
				Contact[] contacts = [SELECT AccountId FROM Contact WHERE Email = :ticket.email];
				if (contacts.size() > 0) { //If the email exists in contacts
					aCase.ContactId = contacts[0].Id;
					aCase.AccountId = contacts[0].AccountId;
				} else { // no existing contact with email of ticket
					Lead[] leads = [SELECT Id FROM Lead WHERE Email = :ticket.email];
					if (leads.size() > 0) { //If the email exists in leads
						aCase.lead__c = leads[0].Id;
					} else { // No existing contact or lead with email adress
						Lead lead = new Lead(
						                     email = ticket.email,
						                     lastName = ticket.email.substringBefore('@'),
						                     Company = ticket.email.substringAfter('@'),
						                     LeadSource = LEAD_SOURCE
						);
						insert lead;
						aCase.lead__c = lead.Id;
					}
				}
			}

			// Assignation du ticket à la file support si possible
			List<Group> supportQueue = [select Id from Group where Type = 'Queue' AND DeveloperNAME = 'Support_511843'];
			if (supportQueue.size() > 0) aCase.ownerId = supportQueue[0].Id;

			// recherche de la clé
			List<Flexera_Key__c> keys = [SELECT Id from Flexera_Key__c where Name = :ticket.numoKey];
			if (keys.size() > 0) aCase.Cle_flexera__c = keys[0].Id;

			insert aCase;

			// Recuperation du caseNumber
			aCase = [Select CaseNumber from Case where Id = :aCase.Id];

			return aCase.CaseNumber;
		} catch(Exception e) {
			System.debug('[WS001_SOAP_Support#createTicket] Erreur : ' + e.getMessage() + ':' + e.getStackTraceString());
			insert new WS_Error__c(ErrorMessage__c = e.getMessage() + ':' + e.getStackTraceString(), WebserviceName__c = 'WS001_SOAP_Support-createTicket');
			return '-1';
		}
	}

	webservice static String createAttachmentForTicket(Attachment attachment, String caseNumber) {
		try {
			// Recuperation du case
			List<Case> cases = [Select Id from Case where caseNumber = :caseNumber];
			if (cases.size() > 0) {
				// Creation du contenu
				ContentVersion v = new ContentVersion();
				v.versionData = EncodingUtil.base64Decode(attachment.content);
				v.title = attachment.filename;
				v.PathOnClient = attachment.filename;
				v.ContentLocation = 'S';
				v.IsMajorVersion = true;
				insert v;

				// Recuperation du file généré à l'insertion de la version
				Id docId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :v.Id].ContentDocumentId;

				// Association du fichier PDF à l'object facture et au file
				ContentDocumentLink cdl = new ContentDocumentLink();
				cdl.ContentDocumentId = docId;
				cdl.LinkedEntityId = cases[0].Id;
				cdl.ShareType = 'I';
				insert cdl;

				return v.Id;
			}
			System.debug('[WS001_SOAP_Support#createAttachmentForTicket] Pas de case trouvé');
			return '-1';
		} catch(Exception e) {
			System.debug('[WS001_SOAP_Support#createAttachmentForTicket] Erreur : ' + e.getMessage() + ':' + e.getStackTraceString());
			insert new WS_Error__c(ErrorMessage__c = e.getMessage() + ':' + e.getStackTraceString(), WebserviceName__c = 'WS001_SOAP_Support-createAttachment');
			return '-2';
		}
	}
}