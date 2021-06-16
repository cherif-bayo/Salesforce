/**
* Gestion des téléchargements de la version d'essai sur le site xlstat.com
* Cette deuxième version permet de générer une clé flexera pour la version d'essai
* Elle gère également l'envoi d'un mail avec la clé
*/
global class WS004_SOAP_Telechargements_v3 {
    public static String CODE_OK = '00';
    public static String CODE_ERREUR_FLEXERA = '01';
    public static String CODE_ERREUR_DEJA_CLIENT = '02';
    public static String CODE_ERREUR_DEJA_PROSPECT = '03';
    public static String CODE_ERREUR_SF = '04';
    
    global class Person {
        webService String firstName;
        webService String lastName;
        webService String email;
        webService String phone;
        webService String position;
        webService String company;
        webService String locale;
        webService String countryCode;
        webService String domainCode;
        webService Boolean HasOptedOutOfPhone;
        webService Boolean HasOptedOutOfEmail;
    }
    
    global class Download {
        webService Datetime dateDownload;
        webService String osDownload;
        webService String source;
    }
    
    global class Result {
        webService Boolean status;
        webService String message;
        webService String errorCode;
        webService String flexeraKey;
    }
    
    webService static Boolean isEmailAuthorized(String email) {
        return true;
    }
    
    webService static Result createTelechargement(Person person, Download download) {
        
        System.debug('WS004_SOAP_Telechargements#createTelechargement : Appel WS pour un nouveau Téléchargement : Person=' + person + ' Download=' + download);
        Result result = new Result();
        result.status = true;
        result.message = '';
        result.errorCode = '';
        
        try {
            Lead lead;
            // If lead exists with this email
            Lead[] leads = [SELECT numoKey__c, FirstName, LastName, Email, LeadSource, Date_derniere_recommendation__c, Nombre_de_recommandations__c, Nombre_recommand__c, Date_dernier_telechargement__c, Date_premier_telechargement__c, Nombre_de_telechargements__c FROM Lead WHERE Email = :person.email];
            if (leads.size() > 0) {
                lead = leads[0];
                Flexera_Key__c[] keys = [SELECT Lead__c, Expiration__c, Is_Less_Than_Deadline__c FROM Flexera_Key__c WHERE Lead__c = :lead.Id ORDER BY CreatedDate DESC ];
                if (keys.size() > 0 && keys[0].Is_Less_Than_Deadline__c == false) {
                    CL004_HelperLeads_v2.sendEmailWithoutKey(lead.Id, person.locale, lead.Email);
                    // update object result for symfony
                    result.errorCode = CODE_ERREUR_DEJA_CLIENT;
                    result.status = true;
                    // syestem trace
                    System.debug('CL004_Telechargements#create : email sent for lead ' + lead.Id);
                } else {
                    CL004_HelperLeads_v2.updateLeadWithoutDML(lead, download.dateDownload, person.firstName, person.lastName, person.domainCode, download.source, person.HasOptedOutOfPhone, person.HasOptedOutOfEmail);
                    String keyName = CL004_HelperLeads_v2.createTrialKeyAndSendEmail(lead, person.countryCode);
                    manageResultAndLead(keyName, lead, result);
                    update lead;
                    System.debug('CL004_Telechargements#create : Lead updated ' + lead.Id);
                }
            } else { //no existing lead with person email
                lead = CL004_HelperLeads_v2.createLeadWithoutDML(download.dateDownload, person.firstName, person.lastName,
                                                                 person.email, person.phone, person.countryCode, person.company,
                                                                 person.locale, person.domainCode, person.position, download.source, 
                                                                 person.HasOptedOutOfPhone, person.HasOptedOutOfEmail);
                String keyName = CL004_HelperLeads_v2.createTrialKeyAndSendEmail(lead, person.countryCode);
                manageResultAndLead(keyName, lead, result);
                System.debug('CL004_Telechargements#create : Lead created ' + lead.Id);
                result.message = 'Customer ' + person.email + ' inserted as Lead id=' + lead.Id;
            }
            Telechargement__c telechargement = CL004_HelperDownloads_v2.createDownloadWithLeadId(download.dateDownload, download.osDownload, lead.Id);
            result.message += ' Download inserted in Salesforce id=' + telechargement.Id;
        } catch(Exception e) {
            System.debug('>>>> Exception e = '+e.getMessage()+' - '+e.getStackTraceString());
            result.status = false;
            result.errorCode = CODE_ERREUR_SF;
            result.message = e.getMessage();
        }
        return result;
    }
    
    public static void manageResultAndLead(String keyname, Lead lead, Result result) {
        System.debug('>>>> WS4_v3 - manageResultAndLead - result = '+result);
        if (keyname != '') {
            result.errorCode = CODE_OK;
            result.flexeraKey = keyname;
        } else {
            upsert lead;
            result.status = false;
            result.errorCode = CODE_ERREUR_FLEXERA;
        }
    }
}