/**
 * Created by LBEA on 06/10/2020.
 */

global with sharing class WS004_SOAP_Telechargements_v4 {
    public static String CODE_OK = '00';
    public static String CODE_ERREUR_GESTIONNAIRE_CLES = '01';
    public static String CODE_ERREUR_DEJA_PROSPECT = '02';
    public static String CODE_ERREUR_SF = '04';
    public static String XLSTAT_CODE = System.Label.XlstatCode;
    public static String XLRISK_CODE = System.Label.XlriskCode;
    public static String XLOPTIM_CODE = System.Label.XloptimCode;
    public static String ZENPLOT_CODE = System.Label.ZenplotCode;

    public static Person person;
    public static Download download;			

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
        webService String softwareCode; // 00 -> XLSTAT, 01 -> XLRISK etc...
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
        WS004_SOAP_Telechargements_v4.person = person;
        WS004_SOAP_Telechargements_v4.download = download;

        System.debug('WS004_SOAP_Telechargements#createTelechargement : Appel WS pour un nouveau Téléchargement : Person=' + person + ' Download=' + download);
        Result result = new Result();
        result.status = true;
        result.message = '';
        result.errorCode = '';

        try {
            Lead lead;
            Lead[] leads = [
                    SELECT numoKey__c, FirstName, LastName, Software__c, Email, LeadSource, Date_derniere_recommendation__c, Nombre_de_recommandations__c, Nombre_recommand__c, Date_dernier_telechargement__c, Date_premier_telechargement__c, Nombre_de_telechargements__c
                    FROM Lead WHERE Email = :person.email
            ];
            if (leads.size() > 0) { // If lead exists with this email
                lead = leads[0];
                Flexera_Key__c[] keys = [
                        SELECT Lead__c, Expiration__c
                        FROM Flexera_Key__c WHERE Lead__c = :lead.Id AND SoftwareCode__c = :download.softwareCode AND Is_Less_Than_Deadline__c = FALSE
                ];
                if (keys.size() > 0) { // key exists and still valid for this product
                    CL004_HelperLeads_v2.sendEmailWithoutKey(lead.Id, person.locale, lead.Email, download.softwareCode);
                    result.errorCode = CODE_ERREUR_DEJA_PROSPECT;
                    result.status = true;
                    System.debug('CL004_Telechargements#create : rejected email sent for lead ' + lead.Id);
                    return result;
                }
            } else { // no existing lead with person email
                lead = new Lead();
                result.message = 'Customer ' + person.email + ' inserted as Lead';
                System.debug('CL004_Telechargements#create : Lead being created ' + lead);
            }
            populateLead(lead);
            String keyName = createTrialKeyAndSendEmail(lead, person.countryCode, download.softwareCode);
            manageResultAndLead(keyName, result);
        } catch(Exception e) {
            result.status = false;
            result.errorCode = CODE_ERREUR_SF;
            result.message = e.getMessage();
            System.debug('CL004_Telechargements#create : Exception ' + e.getMessage());
            System.debug('CL004_Telechargements#create : Exception ' + e.getStackTraceString());
        }
        System.debug('>>>> Result = '+result);
        return result;
    }

    private static void manageResultAndLead(String keyName, Result result) {
        System.debug('>>>> WS4_v4 - manageResultAndLead - result = '+result);
        if (! String.isBlank(keyName)) {
            result.errorCode = CODE_OK;
            result.flexeraKey = keyName;
        } else {
            result.status = false;
            result.errorCode = CODE_ERREUR_GESTIONNAIRE_CLES;
        }
    }

    private static void populateLead (Lead lead) {
        lead.FirstName = person.firstName.abbreviate(CL003_Constants.MAX_LENGTH_FIRST_NAME);
        lead.LastName = person.lastName.abbreviate(CL003_Constants.MAX_LENGTH_LAST_NAME);
        lead.Email = person.email;
        lead.Phone = person.phone;
        lead.CountryCode = person.countryCode;
        lead.Position__c = person.position;
        lead.Company = person.company == '' ? CL003_Constants.DEFAULT_COMPANY : person.company;
        lead.Langue__c = CL003_Constants.phpLocaleToSFLocale.containsKey(person.locale) ? CL003_Constants.phpLocaleToSFLocale.get(person.locale) : person.locale;
        lead.Domain__c = CL003_Constants.domainCodeToDomain.containsKey(person.domainCode) ? CL003_Constants.domainCodeToDomain.get(person.domainCode) : '';
        lead.LeadSource = download.source != null ? download.source : CL003_Constants.ORIGINE_DOWNLOAD;
        lead.HasOptedOutOfEmail = person.HasOptedOutOfEmail; // champ standard non utilisé par Emma
        lead.No_mailling__c = person.HasOptedOutOfEmail; // champ non standard utilisé par Emma
        lead.HasOptedOutOfPhone__c = person.HasOptedOutOfPhone;

        if (lead.Date_dernier_telechargement__c == null || lead.Date_dernier_telechargement__c < download.dateDownload) {
            lead.Date_dernier_telechargement__c = download.dateDownload;
        }

        if (lead.Date_premier_telechargement__c == null) {
            lead.Date_premier_telechargement__c = download.dateDownload;
        }

        String softwareName = new SoftwareService().getSoftwareNameFromCode(download.softwareCode);
        if (lead.Software__c == null) {
            lead.Software__c = softwareName;
        } else if (!lead.Software__c.contains(softwareName)) {
            lead.Software__c = lead.Software__c + ';' + softwareName;
        }
    }

    private static String createTrialKeyAndSendEmail(Lead lead, String countryCode, String softwareCode) {
        Flexera_Key__c key;
        System.debug('>>>> WS004_SOAP_T...v4 - createTrialKeyAndSendEmail - softwareCode = '+softwareCode);
        key = CL004_TrialKeyGeneration.GenerateTrialKeyInFlexera(softwareCode);
        System.debug('>>>> WS004_SOAP_T...v4 - createTrialKeyAndSendEmail - key = '+key);
        if (key != null) {
            lead.numoKey__c = key.Name;
            	if (softwareCode == XLSTAT_CODE) { 
                    lead.XlstatKey__c = key.Name;
            	} else if (softwareCode == XLRISK_CODE){
                    lead.XlriskKey__c = key.Name;
                } else if (softwareCode == XLOPTIM_CODE){
                    lead.XloptimKey__c = key.Name;
                } else if (softwareCode == ZENPLOT_CODE){
                    lead.ZenplotKey__c = key.Name;
                }
            upsert lead;
            try {
                if (softwareCode == XLSTAT_CODE) {
                    CL004_SendEmail.sendEmailWithKey(lead.Id, countryCode);
                } else {
                    CL004_SendEmail.sendEmailWithKey(lead, countryCode, softwareCode);
                }
                key.Lead__c = lead.Id;
                upsert key;
                return key.Name;
            } catch (Exception e) {
                System.debug('createTrialKeyAndSendEmail - Exception :'+e.getMessage());
            }
        }
        return '';
    }
}