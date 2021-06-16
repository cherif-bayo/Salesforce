global class WS003_SOAP_Telechargements {
    
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
    	webservice Date    dateDownload;    
	}
    
    global class Result{
        webservice Boolean status;
        webservice String  message;
    }    

    webservice static Result createTelechargement(Person person, Download download) {

        System.debug('WS003_SOAP_Telechargements#createTelechargement : Appel WS pour un nouveau Téléchargement : Person='+ person + ' et Download=' + download);   
        Result result = new Result();
        result.status   = true; 
        result.message	= '';       
        
        try {            
            Contact[] contacts = [SELECT Id, Piste_date_dernier_t_l_chargement__c, Piste_premier_telechargement__c, LeadSource, Piste_Source_site__c FROM Contact WHERE Email = :person.email];
            if (contacts.size() > 0){//If the email exists in contacts
                CL003_HelperContacts.updateContactWithDateDownload (contacts[0], download.dateDownload);
                Telechargement__c telechargement = CL003_HelperDownloads.createDownloadWithContactId (download.dateDownload, contacts[0].Id);

                System.debug('CL003_Telechargements#create : Contact updated '+contacts[0].Id);    
                result.message = 'Customer ' + person.email + ' already existing as contact. Contact updated and Download created id='+telechargement.Id;    
            } else { // no existing contact with the person email
				Lead lead;
                
                // If lead exists with this email
                Lead[] leads = [SELECT FirstName, LastName, Email, LeadSource, Date_derniere_recommendation__c, Nombre_de_recommandations__c, Nombre_recommand__c, Date_dernier_telechargement__c, Date_premier_telechargement__c, Nombre_de_telechargements__c FROM Lead WHERE Email = :person.email];                
                if(leads.size() > 0){     
                    lead = leads[0];
                    CL003_HelperLeads.updateLead (lead, download.dateDownload, person.firstName, person.lastName, person.domainCode); 

                    System.debug('CL003_Telechargements#create : Lead updated '+ lead.Id);    
                    result.message = 'Customer ' + person.email + ' already existing as lead. Lead updated.';            
                    
                } else { //no existing lead with person email
                    lead = CL003_HelperLeads.createLead(download.dateDownload, person.firstName, person.lastName, 
                                  person.email, person.phone, person.countryCode, person.company,
                                  person.locale, person.domainCode, person.position);   

                    System.debug('CL003_Telechargements#create : Lead created '+lead.Id);    
                    result.message = 'Customer ' + person.email + ' inserted as Lead id='+lead.Id;                    
                }
                
                Telechargement__c telechargement = CL003_HelperDownloads.createDownloadWithLeadId (download.dateDownload, lead.Id);                
                result.message += 'Download inserted in Salesforce id=' + telechargement.Id;                
            }
        }catch(Exception e){
            result.status = false;
            result.message = e.getMessage();
        }
    
        return result;
    }   
}