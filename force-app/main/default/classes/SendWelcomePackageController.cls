/**
 * Send Welcome Package controller
 */
public class SendWelcomePackageController{
	
	@TestVisible private static String PLAQUETTES_FOLDER_ID_SANDBOX = '00l26000000GCCu'; //SANDBOX
	@TestVisible private static String PLAQUETTES_FOLDER_ID = '00l240000011Tfz'; //PRODUCTION

	private static String PLAQUETTES_TEMPLATE_EMAIL_NAME = 'Plaquette';
	private static String DEFAULT_SOLUTION = 'Généraliste';
	private static Map<String, String> leadDomainToPlaquetteDomain = new Map<String, String>{'Enseignant/chercheur' => 'Academic', 'Professionnel' => 'Company'};

	private Contact contact;
	private Lead lead;
	private Boolean isContact;

	public Plaquette__c Plaquette{get; set;}
	public Document PlaquetteDocument {get; set;}
	public Boolean NoError {get; set;}
	public Boolean NoErrorPlaquette {get; set;}
	public Boolean EmailIsDemo {get; set;}

	/**
	 * [SendWelcomePackageController description]
	 * @return [description]
	 */
	public SendWelcomePackageController(){
		String contact_id = ApexPages.currentPage().getParameters().get('contact_id');
	
		String domain;
		String langue;
		
		this.Plaquette = new Plaquette__c();
		this.Plaquette.Solution__c = DEFAULT_SOLUTION;
		
		if(contact_id == null){
			String lead_id = ApexPages.currentPage().getParameters().get('lead_id');
			
			if(lead_id != null){
				this.lead = [SELECT Id, Email, Langue__c, Domain__c FROM Lead WHERE Id = :lead_id];
				
				domain = leadDomainToPlaquetteDomain.containsKey(this.lead.Domain__c) ? leadDomainToPlaquetteDomain.get(this.lead.Domain__c) : this.lead.Domain__c;
				
				langue = this.lead.Langue__c;
			
				this.isContact = false;
				
				this.NoError = true;
			}else{
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Une erreur est survenue. Aucun contact id ni lead id trouvé.'));
			}
		}else{
			this.contact = [SELECT Id, Email, Langue__c, Domaine_Utilisateur__c FROM Contact WHERE Id = :contact_id];
			
			Account[] personAccount = [SELECT Id, Domaine_Utilisateur__c FROM Account WHERE PersonContactId = :contact_id LIMIT 1];
			
			if(personAccount.size() == 1){
				domain = personAccount[0].Domaine_Utilisateur__c;
			}else{
				domain = this.contact.Domaine_Utilisateur__c;
			}
			
			langue = this.contact.Langue__c;                   
			
			Order[] lastOrder;
			if(personAccount.size() == 1){
				lastOrder = [SELECT Id, (SELECT Product2.Name FROM OrderItems WHERE Product2.Family = 'Solution' LIMIT 1) FROM Order WHERE Contact_Lie__c = :this.contact.Id OR Client_Final__c = :this.contact.Id OR AccountId = :personAccount[0].Id ORDER BY CreatedDate DESC LIMIT 1];     
			}else{
				lastOrder = [SELECT Id, (SELECT Product2.Name FROM OrderItems WHERE Product2.Family = 'Solution' LIMIT 1) FROM Order WHERE Contact_Lie__c = :this.contact.Id OR Client_Final__c = :this.contact.Id ORDER BY CreatedDate DESC LIMIT 1];     
			}

			if(lastOrder.size() == 1 && lastOrder[0].OrderItems.size() == 1){
				Schema.DescribeFieldResult fieldResultSolution = Plaquette__c.Solution__c.getDescribe();
				List<Schema.PicklistEntry> pleSolution = fieldResultSolution.getPicklistValues();
				Set<String> solutionValues = new Set<String>();
				for( Schema.PicklistEntry f : pleSolution){
					solutionValues.add(f.getLabel());
				}

				String orderSolution = lastOrder[0].OrderItems[0].Product2.Name;
				if(orderSolution.Contains(orderSolution)){
					this.Plaquette.Solution__c = orderSolution;
				}
			}
			
			this.isContact = true;
			this.NoError = true;
		}
		
		if(this.NoError == true){  
			
			Schema.DescribeFieldResult fieldResult = Plaquette__c.Domaine__c.getDescribe();
			List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
			Set<String> domaineValues = new Set<String>();
			for( Schema.PicklistEntry f : ple){
				domaineValues.add(f.getLabel());
			}
			String domaineUtilisateur = domain;
			if(domaineValues.Contains(domaineUtilisateur)){
				this.Plaquette.Domaine__c = domaineUtilisateur;
			}
				
			this.Plaquette.Langue__c = langue;   
		}
	}
	
	/**
	 * [UpdatePlaquette description]
	 */
	public void UpdatePlaquette(){
		Plaquette__c[] plaquetteFound = [SELECT Currency__c, Sujet_Email__c, Texte_Email__c, Html_Email__c, Texte_Email_Demo__c, Html_Email_Demo__c, Nom_Fichier__c FROM Plaquette__c WHERE Solution__c = :this.Plaquette.Solution__c AND Domaine__c = :this.Plaquette.Domaine__c AND Langue__c = :this.Plaquette.Langue__c AND Currency__c = :this.Plaquette.Currency__c LIMIT 1];
		if(plaquetteFound.size() == 1){        
			Document[] plaquetteDocument = [SELECT Id, Name, Body, ContentType FROM Document WHERE FolderId = :PLAQUETTES_FOLDER_ID AND Name = :plaquetteFound[0].Nom_Fichier__c LIMIT 1];
			
			if(plaquetteDocument.size() == 1){
				this.PlaquetteDocument = plaquetteDocument[0];    
		
				this.NoErrorPlaquette = true;
			}else{
				this.NoErrorPlaquette = false;
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Aucun fichier de plaquette trouvé correspondant au nom du fichier précisé pour ces critères.'));
			}
			
			this.Plaquette.Sujet_Email__c = plaquetteFound[0].Sujet_Email__c;
			if(this.Plaquette.isDemo__c == true){
				this.Plaquette.Texte_Email_Demo__c = plaquetteFound[0].Texte_Email_Demo__c;
				this.Plaquette.Html_Email_Demo__c = plaquetteFound[0].Html_Email_Demo__c;
				this.EmailIsDemo = true;
			}else {
				this.Plaquette.Texte_Email__c = plaquetteFound[0].Texte_Email__c;
				this.Plaquette.Html_Email__c = plaquetteFound[0].Html_Email__c;
				this.EmailIsDemo = false;
			}
			
		}else{
			this.NoErrorPlaquette = false;
		
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Aucune description de plaquette trouvée correspondant à ces critères.'));
		}
	}
	
	/**
	 * [Cancel description]
	 * @return [description]
	 */
	public PageReference Cancel(){
		PageReference pref = new PageReference('/' + (this.isContact ? this.contact.Id  : this.lead.Id));
		pref.setRedirect(true);

		return pref;
	}
	
	/**
	 * [Send description]
	 * @return [description]
	 */
	public PageReference Send(){
		String emailAddress;

		if(this.isContact == true){
			emailAddress = this.contact.Email;
		}else{
			emailAddress = this.lead.Email;        
		}
	
		List<EmailMessageWrapper> listEmailMessageWrapper = new List<EmailMessageWrapper>();
					
		Map<String, String> mapSubjectParams = new Map<String, String> {};
		Map<String, String> mapBodyParams = new Map<String, String> {};
		if(this.Plaquette.isDemo__c == true){
			Map<String, String> mapBodyParam = new Map<String, String> {
				'{!Text}' => this.Plaquette.Texte_Email_Demo__c,
				'{!Html}' => this.Plaquette.Html_Email_Demo__c
			};
			mapBodyParams = mapBodyParam;
		}else{
			Map<String, String> mapBodyParam = new Map<String, String> {
				'{!Text}' => this.Plaquette.Texte_Email__c,
				'{!Html}' => this.Plaquette.Html_Email__c
			};
			mapBodyParams = mapBodyParam;
		}
	
		String subject = this.Plaquette.Sujet_Email__c;
		
		EmailMessageWrapper wrap = new EmailMessageWrapper('sales@xlstat.com', emailAddress, null, null, subject, mapSubjectParams, null, mapBodyParams);
		
		wrap.EmailAttachments = new List<Messaging.EmailFileAttachment>();
		Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
		efa.setFileName(this.PlaquetteDocument.Name);
		efa.setBody(this.PlaquetteDocument.Body);
		efa.setContentType(this.PlaquetteDocument.ContentType);
		wrap.EmailAttachments.add(efa);

		listEmailMessageWrapper.add(wrap);
		
		String templateName = PLAQUETTES_TEMPLATE_EMAIL_NAME;
		UtilityClass utilityClass = new UtilityClass(listEmailMessageWrapper, templateName);
		
		List<Email__c> emailsToInsert = new List<Email__c>();
		List<Messaging.SendEmailResult> results = utilityClass.sendEmail(listEmailMessageWrapper);
		
		Boolean sendEmailError = false;
		for(Integer i = 0; i < results.size(); i++){
			Messaging.SendEmailResult result = results[i];
			if(result.isSuccess()){
				Email__c email = new Email__c();
				email.Address__c = emailAddress;
				if(this.isContact == true){
					email.Contact__c = this.contact.Id;
				}else{
					email.Lead__c = this.lead.Id;
				}

				email.Type__c = 'Welcome Package';
				email.Subject__c = subject;
				email.Attachment_Id__c = this.PlaquetteDOcument.Id;
				emailsToInsert.add(email);

			}else{
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Une erreur est survenue lors de l\'envoi de l\'email.'));
				sendEmailError = true;
				
				break;
			}
		}
		
		insert emailsToInsert;
		
		if(sendEmailError == true) return null;
		
		PageReference pageRef = new PageReference('/' + (this.isContact ? this.contact.Id  : this.lead.Id));    
		pageRef.setRedirect(true);

		return pageRef;
	}    
}