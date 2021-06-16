@RestResource(urlMapping='/NpsManager/*')
global class WS001_NpsManager {
    
    @HttpGet
    global static String doGet() {
        RestRequest req = RestContext.request;
        String numKey = req.requestURI.substring(
        req.requestURI.lastIndexOf('/')+1);
        
        
        List<Flexera_Key__c> KeysLead = [SELECT Id, Lead__r.Email, Contact__r.Email FROM Flexera_Key__c WHERE Name = :numKey ];
        if (KeysLead.size() >0) {
            
            if(KeysLead[0].Contact__r.Email == null) {
                return KeysLead[0].Lead__r.Email;
            }
            else if (KeysLead[0].Contact__r.Email != null) {
                return KeysLead[0].Contact__r.Email;
            }  
        } 
        
        return '';
       
       
    }   
}