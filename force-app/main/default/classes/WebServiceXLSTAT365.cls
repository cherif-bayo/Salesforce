@RestResource(urlMapping='/XLSTAT365/*')
global class WebServiceXLSTAT365{
    private static Map<String, String> languageXLSTAT365ToLeadLanguage = new Map<String, String>{'en' => 'US', 'fr' => 'FR'};

    @HttpPost
    webservice static void createUser(String email, String versionName, String language){
        List<XLSTAT_365_Version__c> versions = [SELECT Id FROM XLSTAT_365_Version__c WHERE Name = :versionName];
        if(versions.size() == 0){
            XLSTAT_365_Version__c version = new XLSTAT_365_Version__c();
            version.Name = versionName;
            version.Date__c = Date.today();
            
            insert version;
            
            versions.add(version);
        }
        
        XLSTAT_365_Activation__c activation = new XLSTAT_365_Activation__c();
        activation.Date__c = DateTime.now();
        activation.XLSTAT_365_Activation_Version__c = versions[0].Id;
    
        List<Contact> contacts = [SELECT Id, XLSTAT_365__c FROM Contact WHERE email = :email];
    
        if(contacts.size() == 0){
            List<Lead> leads = [SELECT Id, IsXLSTAT365__c FROM Lead WHERE email = :email];
            String XlstatCloudVersion = System.Label.XlstatCloudVersion;
            
            if(leads.size() == 0){
                Lead lead = new Lead();
                lead.Email = email;
                lead.LastName = email;
                lead.Company = 'Default Company';
                lead.IsXLSTAT365__c = true;
                lead.LeadSource = XlstatCloudVersion;
                lead.Software__c = XlstatCloudVersion;
                lead.Langue__c = languageXLSTAT365ToLeadLanguage.get(language);
                
                insert lead;
                
                leads.add(lead);
            }else{
                leads[0].IsXLSTAT365__c = true;
            }
            
            activation.Lead__c = leads[0].Id;
        }else{
            contacts[0].XLSTAT_365__c = true;
            
            update contacts[0];
            
            activation.Contact__c = contacts[0].Id;
        }
        
        insert activation;
    }
}