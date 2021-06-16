global class WebServiceLeads{
    //Origins of the leads depending on the web service method called
    private static String ORIGINE_RECOMMEND = 'Recommandation';
    private static String ORIGINE_DOWNLOAD = 'Download';    
    
    //The default company to set to the leads (Company field of the Lead object in SF is required but we don't have the information)
    private static String DEFAULT_COMPANY = 'Default Company';
    
    private static Integer MAX_LENGTH_FIRST_NAME = 40;
    private static Integer MAX_LENGTH_LAST_NAME = 80;
    
    private static Map<String, String> customerLanguageToContactLanguage = new Map<String, String>{'en' => 'US', 'ja' => 'JP'};
    private static Map<String, String> domainCodeToDomain = new Map<String, String>{'stu' => 'Etudiant', 'edu' => 'Enseignant/chercheur', 'cmp' => 'Professionnel'};    
    
    private static String SOURCE_SITE_DEFAULT = 'Autre';
    private static Map<String, String> SOURCE_SITE_BY_VALUE = new Map<String, String>{
        'SE' => 'Moteur de recherche',
        'WAD' => 'Pub sur internet',
        'PAD' => 'Pub papier',
        'FC' => 'Ami ou collègue',
        'CG' => 'Conference',
        'AR' => 'Article',
        'EM' => 'Email',
        'OT' => 'Autre'
    };
    
    //Customer informations sent by the website to the web service methods
    global class Customer{
        webservice String firstName;
        webservice String lastName;
        webservice String email;
        webservice String language;
        webservice String currencyCode;
        webservice String countryCode;
        webservice String domainCode;
    }
    
    global class DownloadedFile{
        webservice String os;
        webservice String version;
        webservice String extension;
    }
    
    global class Result{
        webservice Boolean status;
        webservice String message;
    }
    
     private static String formatName(String name){
        String newName = name.toLowerCase();
        if(newName.indexof(' ') != -1){
            String[] newNames = newName.split(' ');
            for(Integer i = 0; i < newNames.size(); i++){
                newNames[i] = newNames[i].capitalize();
            }
            newName = String.join(newNames, ' ');
        }else{
            newName = newName.capitalize();
        }
        
        return newName;
    }
    
    //Associate email existance (true or false) in SF to each email sent as paremeter
    private static Map<String, Boolean> emailsAlreadyExist(String[] emails){
        Map<String, Boolean> emailExists = new Map<String, Boolean>();
        for(String email : emails){
            emailExists.put(email, false);
        }
        
        Contact[] contacts = [SELECT Email FROM Contact WHERE Email in :emails];
        for(Contact contact : contacts){
            emailExists.put(contact.Email, true);
        }
        
        return emailExists;
    }
    
    private static Map<String, Lead> leadsExistingByEmails(String[] emails){
        Map<String, Lead> leadsExisting = new Map<String, Lead>();
        
        Lead[] leads = [SELECT FirstName, LastName, Email, LeadSource, Date_derniere_recommendation__c, Nombre_de_recommandations__c, Nombre_recommand__c, Date_dernier_telechargement__c, Date_premier_telechargement__c, Nombre_de_telechargements__c FROM Lead WHERE Email in :emails];
        for(Lead lead : leads){
            leadsExisting.put(lead.Email, lead);
        }
        
        return leadsExisting;
    }
    
    //Create a lead SF object depending on the customer attributes and the origin of the lead
    private static Lead createLead(Customer customer, String origin){
        Lead lead = new Lead();
        lead.Salutation = null;
        lead.Company = DEFAULT_COMPANY;
        lead.firstName = customer.FirstName;
        lead.LastName = customer.LastName;
        lead.Email = customer.email;
        lead.LeadSource = origin;
        lead.CurrencyISOCode = customer.currencyCode;
        if(customerLanguageToContactLanguage.containsKey(customer.Language)){
            lead.Langue__c = customerLanguageToContactLanguage.get(customer.Language);
        }else{
            lead.Langue__c = customer.Language;
        }
        lead.CountryCode = customer.countryCode;
        lead.Domain__c = domainCodeToDomain.containsKey(customer.domainCode) ? domainCodeToDomain.get(customer.domainCode) : 'Autre';
        
        return lead;
    }
    
    //Add a lead after a user recommendation on the website
    webservice static Result AddFromRecommend(Customer customer, String[] emails){
        Result result = new Result();
        result.status = true; 
        result.message = '';   
        try{
            List<Lead> leadsToInsert = new List<Lead>();
            String e = customer.email;
            String[] customerEmail = new String[]{e};
            List<Contact> contactsToUpdate = new List<Contact>();
        
            //Check if the email of the user triggering the recommend is existing in SF
            //If not, add a lead to SF depending on the user attributes and the origin set to 'Recommandation'
            Boolean emailCustomerExists = emailsAlreadyExist(customerEmail).get(e);
            if(emailCustomerExists == false){
                Integer maxLengthFirstName = customer.firstName.length() > MAX_LENGTH_FIRST_NAME ? MAX_LENGTH_FIRST_NAME : customer.firstName.length();
            
                Map<String, Lead> leadsExisting = leadsExistingByEmails(customerEmail);
                Lead lead;
                
                if(leadsExisting.containsKey(e) == false){
                    customer.LastName = customer.Email.substringBefore('@');
                    
                    customer.firstName = formatName(customer.firstName).substring(0, maxLengthFirstName);
                    
                    lead = createLead(customer, ORIGINE_RECOMMEND);
                    lead.Date_derniere_recommendation__c = DateTime.now();
                    lead.Nombre_de_recommandations__c = 1;
                    
                    insert lead;
                    
                    result.message = 'Customer ' + customer.email + ' inserted as lead.';
                }else{
                    lead = leadsExisting.get(e);
                    
                    lead.Date_derniere_recommendation__c = DateTime.now();
                    lead.LeadSource = ORIGINE_RECOMMEND;
                    
                    Integer maxLengthLastName = customer.lastName.length() > MAX_LENGTH_LAST_NAME ? MAX_LENGTH_LAST_NAME : customer.lastName.length();  
                    
                    lead.FirstName = formatName(customer.firstName).substring(0, maxLengthFirstName);
                    lead.LastName = formatName(customer.lastName).substring(0, maxLengthLastName);  
                    
                    lead.Nombre_de_recommandations__c = lead.Nombre_de_recommandations__c + 1;
                    
                    update lead;
                    
                    result.message = 'Customer ' + e + ' already existing as lead. Lead updated.';
                }
            }else{
                Contact[] contact = [SELECT Id, Piste_date_derni_re_recommandation__c, Piste_Nombre_de_recommandations__c, LeadSource FROM Contact WHERE email = :e limit 1];
                
                if(contact.size() > 0){
                    contact[0].Piste_date_derni_re_recommandation__c = DateTime.now();
                    contact[0].LeadSource = ORIGINE_RECOMMEND;
                    if(contact[0].Piste_Nombre_de_recommandations__c == null){
                        contact[0].Piste_Nombre_de_recommandations__c = 0;
                    }
                    contact[0].Piste_Nombre_de_recommandations__c = contact[0].Piste_Nombre_de_recommandations__c + 1;
                    
                    result.message += 'Recommendation with contact id: ' + contact[0].Id + '.';
                    
                    contactsToUpdate.add(contact[0]);
                }
            }
            
            //Check if each email added by the user to the recommendation is existing in SF
            //For each email, if it's not existing in SF, add a new lead based on the user attributes, the email sent by the user and the origin set to 'Recommandation'
            Map<String, Boolean> emailsExist = emailsAlreadyExist(emails);
            Map<String, Lead> leadsExisting = leadsExistingByEmails(emails);
            for(String email : emails){
                Boolean emailExists = emailsExist.get(email);
                
                if(emailExists == false){
                    Lead lead;
                    
                    if(leadsExisting.containsKey(email) == false){
                        customer.lastName = email.substringBefore('@');
                        customer.email = email;
                        
                        lead = createLead(customer, ORIGINE_RECOMMEND);
                        lead.Date_dernier_recommand__c = DateTime.now();
                        lead.Nombre_recommand__c = 1;
                        
                        insert lead;
                        
                        result.message += email + ' inserted as lead.';
                    }else{
                        lead = leadsExisting.get(email);
                        
                        lead.Date_dernier_recommand__c = DateTime.now();
                        lead.LeadSource = ORIGINE_RECOMMEND;
                        lead.Nombre_recommand__c = lead.Nombre_recommand__c + 1;
                        
                        update lead;
                        
                        result.message += email + ' already existing as lead. Lead updated.';
                    }
                }else{
                    Contact[] contact = [SELECT Id, Piste_date_dernier_recommand__c, Piste_nombre_recommand__c, LeadSource FROM Contact WHERE email = :email limit 1];
                
                    if(contact.size() > 0){
                        contact[0].Piste_date_dernier_recommand__c = DateTime.now();
                        contact[0].LeadSource = ORIGINE_RECOMMEND;
                        if(contact[0].Piste_nombre_recommand__c == null){
                            contact[0].Piste_nombre_recommand__c = 0;
                        }
                        contact[0].Piste_nombre_recommand__c = contact[0].Piste_nombre_recommand__c + 1;
                        
                        result.message += 'Recommend with contact id: ' + contact[0].Id + '.';
                        
                        contactsToUpdate.add(contact[0]);
                    }
                }
            }
            
            insert leadsToInsert;
            
            update contactsToUpdate;
        }catch(Exception e){
            result.status = false;
            result.message = e.getMessage();
        }
        
        return result;
    }
    
    private static void addTelechargement(DownloadedFile file, String leadId, String contactId, DateTime dateDownload, String version){
        List<Systeme_d_exploitation_version__c> os_version;
        List<Systeme_d_exploitation_version_extension__c> extension;
        List<Systeme_d_exploitation__c> systeme = [SELECT Name FROM Systeme_d_exploitation__c WHERE Name = :file.OS];
        List<Version__c> versions;
        if(systeme.size() == 0){
            Systeme_d_exploitation__c os = new Systeme_d_exploitation__c();
            os.Name = file.OS;
            
            insert os;
            systeme.add(os);
        }
        os_version = [SELECT Name FROM Systeme_d_exploitation_version__c WHERE Name = :file.Version AND Systeme_d_exploitation__c = :systeme[0].Id];
        if(os_version.size() == 0){
            Systeme_d_exploitation_version__c vs = new Systeme_d_exploitation_version__c();
            vs.Name = file.Version;
            vs.Systeme_d_exploitation__c = systeme[0].Id;
            
            insert vs;
            os_version.add(vs);
        }
        extension = [SELECT Name FROM Systeme_d_exploitation_version_extension__c WHERE Name = :file.Extension AND Systeme_d_exploitation_version__c = :os_version[0].Id];
        if(extension.size() == 0){
            Systeme_d_exploitation_version_extension__c ext = new Systeme_d_exploitation_version_extension__c();
            ext.Name = file.Extension;
            ext.Systeme_d_exploitation_version__c = os_version[0].Id;
            
            insert ext;
            extension.add(ext);
        }
        if(version!= null){
            versions = [SELECT Id FROM Version__c WHERE Name = :version];
        }
        if(version == null || versions.size() == 0){
            versions = [SELECT Id FROM Version__c ORDER BY Date__c DESC LIMIT 1];
        }
        
        Telechargement__c telechargement = new Telechargement__c();
        if(leadId != null){
            telechargement.Lead__c = leadId;
        }
        if(contactId != null){
            telechargement.Contact__c = contactId;
        }
        if(dateDownload != null){
            telechargement.Date__c = dateDownload;
        }else{
            telechargement.Date__c = DateTime.now();
        }
        telechargement.Systeme_d_exploitation_version_extension__c = extension[0].Id;
        telechargement.XLSTAT_Version__c = versions[0].Id;
        
        insert telechargement;
    }
    
    //Add a lead from the Download form of the website
    webservice static Result AddFromDownload(Customer customer, String sourceSiteValue, DownloadedFile file, String version){
        Result result = new Result();
        result.status = true; 
        result.message = ''; 
        
        try{
            String customerEmail = customer.email;
            Contact[] contacts = [SELECT Email FROM Contact WHERE Email = :customerEmail];
            //Check if the customer email already exists in SF
            Boolean emailCustomerExists = contacts.size() > 0;
            //If the email doesn't exist, insert a new lead in SF based on the customer attributes and the origin set to 'Download'
            if(emailCustomerExists == false){
            
                Lead[] leads = [SELECT FirstName, LastName, Email, LeadSource, Date_derniere_recommendation__c, Nombre_de_recommandations__c, Nombre_recommand__c, Date_dernier_telechargement__c, Date_premier_telechargement__c, Nombre_de_telechargements__c FROM Lead WHERE Email = :customerEmail];
                Lead lead;
                
                if(leads.size() == 0){
                    Integer maxLengthFirstName = customer.firstName.length() > MAX_LENGTH_FIRST_NAME ? MAX_LENGTH_FIRST_NAME : customer.firstName.length();
                    Integer maxLengthLastName = customer.lastName.length() > MAX_LENGTH_LAST_NAME ? MAX_LENGTH_LAST_NAME : customer.lastName.length();  
                    
                    customer.firstName = formatName(customer.firstName).substring(0, maxLengthFirstName);
                    customer.lastName = formatName(customer.lastName).substring(0, maxLengthLastName);                    
                
                    lead = createLead(customer, ORIGINE_DOWNLOAD);
                    lead.Source_site__c = SOURCE_SITE_BY_VALUE.containsKey(sourceSiteValue) ? SOURCE_SITE_BY_VALUE.get(sourceSiteValue) : SOURCE_SITE_DEFAULT;
                    lead.Date_dernier_telechargement__c = DateTime.now();
                    lead.Date_premier_telechargement__c = DateTime.now();
                    
                    result.message = 'Customer ' + customerEmail + ' inserted as lead.';
                    
                    insert lead;
                }else{
                    lead = leads[0];
                    
                    lead.Date_dernier_telechargement__c = DateTime.now();
                    lead.LeadSource = ORIGINE_DOWNLOAD;
                    
                    Integer maxLengthFirstName = customer.firstName.length() > MAX_LENGTH_FIRST_NAME ? MAX_LENGTH_FIRST_NAME : customer.firstName.length();
                    Integer maxLengthLastName = customer.lastName.length() > MAX_LENGTH_LAST_NAME ? MAX_LENGTH_LAST_NAME : customer.lastName.length();  
                    
                    lead.FirstName = formatName(customer.firstName).substring(0, maxLengthFirstName);
                    lead.LastName = formatName(customer.lastName).substring(0, maxLengthLastName);
                    lead.Domain__c = domainCodeToDomain.containsKey(customer.domainCode) ? domainCodeToDomain.get(customer.domainCode) : 'Autre';  
                    
                    result.message = 'Customer ' + customerEmail + ' already existing as lead. Lead updated';
                    
                    update lead;
                }
                
                addTelechargement(file, lead.Id, null, null, version);
                
                result.message += 'Download inserted in Salesforce with lead id: ' + lead.Id + '.';
            }else{
                Contact[] contact = [SELECT Id, Piste_date_dernier_t_l_chargement__c, Piste_premier_telechargement__c, LeadSource, Piste_Source_site__c FROM Contact WHERE email = :customerEmail limit 1];
                
                if(contact.size() > 0){
                    addTelechargement(file, null, contact[0].Id, null, version);
                    DateTime dateTelechargement = DateTime.now();
                    contact[0].Piste_date_dernier_t_l_chargement__c = dateTelechargement;
                    if(contact[0].Piste_premier_telechargement__c == null){
                        contact[0].Piste_premier_telechargement__c = dateTelechargement;
                    }
                    contact[0].LeadSource = ORIGINE_DOWNLOAD;
                    contact[0].Piste_Source_site__c = SOURCE_SITE_BY_VALUE.containsKey(sourceSiteValue) ? SOURCE_SITE_BY_VALUE.get(sourceSiteValue) : SOURCE_SITE_DEFAULT;
                    
                    result.message += 'Download inserted in Salesforce with contact id: ' + contact[0].Id + '.';
                }
            }
        }catch(Exception e){
            result.status = false;
            result.message = e.getMessage();
        }
        
        return result;
    }
    
    webservice static Result AddFromDownloadWithDate(Customer customer, String sourceSiteValue, DownloadedFile file, String dateDownload, String version){
        Result result = new Result();
        result.status = true; 
        result.message = ''; 
        
        try{
            DateTime dateTimeDownload = DateTime.parse(dateDownload);
            String customerEmail = customer.email;
            Contact[] contacts = [SELECT Email FROM Contact WHERE Email = :customerEmail];
            //Check if the customer email already exists in SF
            Boolean emailCustomerExists = contacts.size() > 0;
            //If the email doesn't exist, insert a new lead in SF based on the customer attributes and the origin set to 'Download'
            if(emailCustomerExists == false){
            
                Lead[] leads = [SELECT FirstName, LastName, Email, LeadSource, Date_derniere_recommendation__c, Nombre_de_recommandations__c, Nombre_recommand__c, Date_dernier_telechargement__c, Date_premier_telechargement__c, Nombre_de_telechargements__c FROM Lead WHERE Email = :customerEmail];
                Lead lead;
                
                if(leads.size() == 0){
                    Integer maxLengthFirstName = customer.firstName.length() > MAX_LENGTH_FIRST_NAME ? MAX_LENGTH_FIRST_NAME : customer.firstName.length();
                    Integer maxLengthLastName = customer.lastName.length() > MAX_LENGTH_LAST_NAME ? MAX_LENGTH_LAST_NAME : customer.lastName.length();  
                    
                    customer.firstName = formatName(customer.firstName).substring(0, maxLengthFirstName);
                    customer.lastName = formatName(customer.lastName).substring(0, maxLengthLastName);                    
                
                    lead = createLead(customer, ORIGINE_DOWNLOAD);
                    lead.Source_site__c = SOURCE_SITE_BY_VALUE.containsKey(sourceSiteValue) ? SOURCE_SITE_BY_VALUE.get(sourceSiteValue) : SOURCE_SITE_DEFAULT;
                    if(lead.Date_dernier_telechargement__c != null){
                        if(lead.Date_dernier_telechargement__c < dateTimeDownload){
                            lead.Date_dernier_telechargement__c = dateTimeDownload;
                        }
                    }else{
                        lead.Date_dernier_telechargement__c = dateTimeDownload;
                    }
                    if(lead.Date_premier_telechargement__c != null){
                        if(lead.Date_premier_telechargement__c > dateTimeDownload){
                            lead.Date_premier_telechargement__c = dateTimeDownload;
                        }
                    }else{
                        lead.Date_premier_telechargement__c = dateTimeDownload;
                    }
                    
                    result.message = 'Customer ' + customerEmail + ' inserted as lead.';
                    
                    insert lead;
                }else{
                    lead = leads[0];
                    
                    if(lead.Date_dernier_telechargement__c != null){
                        if(lead.Date_dernier_telechargement__c < dateTimeDownload){
                            lead.Date_dernier_telechargement__c = dateTimeDownload;
                        }
                    }else{
                        lead.Date_dernier_telechargement__c = dateTimeDownload;
                    }
                    if(lead.Date_premier_telechargement__c == null){
                        lead.Date_premier_telechargement__c = dateTimeDownload;
                    }
                    lead.LeadSource = ORIGINE_DOWNLOAD;
                    
                    Integer maxLengthFirstName = customer.firstName.length() > MAX_LENGTH_FIRST_NAME ? MAX_LENGTH_FIRST_NAME : customer.firstName.length();
                    Integer maxLengthLastName = customer.lastName.length() > MAX_LENGTH_LAST_NAME ? MAX_LENGTH_LAST_NAME : customer.lastName.length();  
                    
                    lead.FirstName = formatName(customer.firstName).substring(0, maxLengthFirstName);
                    lead.LastName = formatName(customer.lastName).substring(0, maxLengthLastName);  
                    lead.Domain__c = domainCodeToDomain.containsKey(customer.domainCode) ? domainCodeToDomain.get(customer.domainCode) : 'Autre';
                    
                    result.message = 'Customer ' + customerEmail + ' already existing as lead. Lead updated';
                    
                    update lead;
                }
                
                addTelechargement(file, lead.Id, null, dateTimeDownload, version);
                
                result.message += 'Download inserted in Salesforce with lead id: ' + lead.Id + '.';
            }else{
                Contact[] contact = [SELECT Id, Piste_date_dernier_t_l_chargement__c, Piste_premier_telechargement__c, LeadSource, Piste_Source_site__c FROM Contact WHERE email = :customerEmail limit 1];
                
                if(contact.size() > 0){
                    addTelechargement(file, null, contact[0].Id, dateTimeDownload, version);
                    if(contact[0].Piste_date_dernier_t_l_chargement__c != null){
                        if(contact[0].Piste_date_dernier_t_l_chargement__c < dateTimeDownload){
                            contact[0].Piste_date_dernier_t_l_chargement__c = dateTimeDownload;
                        }
                    }else{
                        contact[0].Piste_date_dernier_t_l_chargement__c = dateTimeDownload;
                    }
                    if(contact[0].Piste_premier_telechargement__c == null){
                        contact[0].Piste_premier_telechargement__c = dateTimeDownload;
                    }
                    contact[0].LeadSource = ORIGINE_DOWNLOAD;
                    contact[0].Piste_Source_site__c = SOURCE_SITE_BY_VALUE.containsKey(sourceSiteValue) ? SOURCE_SITE_BY_VALUE.get(sourceSiteValue) : SOURCE_SITE_DEFAULT;
                    
                    result.message += 'Download inserted in Salesforce with contact id: ' + contact[0].Id + '.';
                }
            }
        }catch(Exception e){
            result.status = false;
            result.message = e.getMessage();
        }
        
        return result;
    }
}