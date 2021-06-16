/**
* Gestion des téléchargements de la version d'essai sur le site xlstat.com
* Cette deuxième version permet de générer une clé flexera pour la version d'essai
* Elle gère également l'envoi d'un mail avec la clé
*/
global class WS004_SOAP_Telechargements_v2 {
	public static String CODE_OK = '00';
    public static String CODE_ERREUR_FLEXERA = '01';
    public static String CODE_ERREUR_DEJA_CLIENT = '02';
    public static String CODE_ERREUR_DEJA_PROSPECT = '03';
    public static String CODE_ERREUR_SF = '04';
    
    global class Person {
        webservice String  firstName;
        webservice String  lastName;
        webservice String  email;
        webservice String  phone;  
        webservice String  position;              
        webservice String  company;   
        webservice String  locale;
        webservice String  countryCode;        
        webservice String  domainCode;  
	}
    
    global class Download {
    	webservice DateTime dateDownload;
    	webservice String   osDownload;    
	}
    
    global class Result{
        webservice Boolean status;
        webservice String  message;
        webservice String  errorCode;
        webservice String  flexeraKey;
    }    

    webservice static Result createTelechargement(Person person, Download download) {

        System.debug('WS004_SOAP_Telechargements#createTelechargement : Appel WS pour un nouveau Téléchargement : Person='+ person + ' Download=' + download);   
        Result result    = new Result();
        result.status    = true; 
        result.message	 = '';       
        result.errorCode = '';
        
        try {            
            Contact[] contacts = [SELECT Id, Piste_date_dernier_t_l_chargement__c, Piste_premier_telechargement__c, LeadSource, Piste_Source_site__c FROM Contact WHERE Email = :person.email];
            if (contacts.size() > 0){//If the email exists in contacts
                CL004_HelperContacts.updateContactWithDateDownload (contacts[0], download.dateDownload);
                Telechargement__c telechargement = CL004_HelperDownloads.createDownloadWithContactId (download.dateDownload, contacts[0].Id);

                System.debug('CL004_Telechargements#create : Contact updated '+contacts[0].Id);    
                result.status = false;
                result.message = 'Customer ' + person.email + ' already existing as contact. Contact updated and Download created id='+telechargement.Id;  
                result.errorCode = CODE_ERREUR_DEJA_CLIENT;  
            } else { // no existing contact with the person email
				Lead lead;
                
                // If lead exists with this email
                Lead[] leads = [SELECT FirstName, LastName, Email, LeadSource, Date_derniere_recommendation__c, Nombre_de_recommandations__c, Nombre_recommand__c, Date_dernier_telechargement__c, Date_premier_telechargement__c, Nombre_de_telechargements__c FROM Lead WHERE Email = :person.email];                
                if(leads.size() > 0){     
                    lead = leads[0];
                    CL004_HelperLeads.updateLead (lead, download.dateDownload, person.firstName, person.lastName, person.domainCode); 

                    System.debug('CL004_Telechargements#create : Lead updated '+ lead.Id);    
                    result.status = false;
                    result.message = 'Customer ' + person.email + ' already existing as lead. Lead updated.';            
                    result.errorCode = CODE_ERREUR_DEJA_PROSPECT;  
                } else { //no existing lead with person email                          
                    Flexera_Key__c key;
					lead = CL004_HelperLeads.createLeadNotInserted(download.dateDownload, person.firstName, person.lastName, 
                                  person.email, person.phone, person.countryCode, person.company,
                                  person.locale, person.domainCode, person.position);                      
                    String domainUserTrial = Parameters.getString('Trial_Domain_User');
                    List<Flexera_Key__c> availableKeys = [SELECT Id,Name  FROM Flexera_Key__c WHERE isInStock__c = True and Domaine_utilisateur__c = :domainUserTrial order by createddate asc];  
                    if (availableKeys.size()>0) {
                       key = availableKeys[0];   
                    } else {
                       key = CL004_TrialKeyGeneration.GenerateTrialKeyInFlexera();  
                    }
                    if (key != null) {
                        key.isInStock__c = false;
                        lead.numoKey__c = key.name;
                        insert lead;     
                        CL004_SendEmail.sendEmailWithKey(lead.Id,person.countryCode);
                        key.Lead__c = lead.Id;
                        if (key.Id == null) {
                        	insert key;
                        } else {
                            update key;
                        }                        
                        result.errorCode = CODE_OK;
                    } else {
                        insert lead;
                        result.errorCode = CODE_ERREUR_FLEXERA;
                    }   
                    System.debug('CL004_Telechargements#create : Lead created '+lead.Id);                               
                    result.message = 'Customer ' + person.email + ' inserted as Lead id='+lead.Id;                    
                }                	            
                Telechargement__c telechargement = CL004_HelperDownloads.createDownloadWithLeadId (download.dateDownload, lead.Id);                
                result.message += ' Download inserted in Salesforce id=' + telechargement.Id;                  
            }                        
        }catch(Exception e){
            result.status = false;
            result.errorCode = CODE_ERREUR_SF;
            result.message = e.getMessage();
        }    
        return result;
    }   
}