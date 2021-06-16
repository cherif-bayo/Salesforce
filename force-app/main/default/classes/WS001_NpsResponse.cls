@RestResource(urlMapping='/NpsResponse/*')
global class WS001_NpsResponse {
    
    @HttpPost
    global static String doPost(String email, Integer note, Boolean consentment, Boolean alreadyContacted, String xlstatVersion, String userComments, String keyNumber, String userLanguage) {
       
	   Flexera_Key__c[] Keys = [SELECT Id, Order__c, Account__c, Montant_commande__c, Contact__c, UserName__c, Date_limite__c, Date_relance__c, Domaine_Cmd__c, Domaine_utilisateur__c, Name FROM Flexera_Key__c WHERE Name = :keyNumber];
	   
       Reponse_Nps__c ntpresp = new Reponse_Nps__c();
           
           ntpresp.email__c = email;
           ntpresp.Nps_Note__c = note;
           ntpresp.Nps_Consentment__c = consentment;
           // Check if we already contacted the user
           ntpresp.Already_Contacted__c = alreadyContacted;
           ntpresp.Xlstat_Version__c = xlstatVersion;
           ntpresp.User_Comments__c = userComments;
           ntpresp.User_Key_Number__c = keynumber;
           ntpresp.User_Language__c = userLanguage;
    
           if (keys.size() > 0) {
             ntpresp.ContactName__c = keys[0].UserName__c;
           }
        
       insert ntpresp;
           
       return ntpresp.Id; 
    }   
}