@RestResource(urlMapping='/LeadQualification/*')
global class WS001_LeadQualification {
    
    @HttpPost
    global static Lead doPost(String numoKey, Integer score, String analysesFrequentes, String solutionPreconisee, Date dateActivationTrial) {
        System.debug('[WS001_LeadQualification] Modification du dernier lead avec numoKey = '+numoKey);
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;                
        List<Lead> leads = [SELECT Id FROM Lead WHERE numoKey__c = :numoKey order by createdDate Desc limit 1];
        if (leads.size() >0) {
            leads[0].score__c = score;
            leads[0].AnalysesFrequentes__c 	= analysesFrequentes;   
            leads[0].solutionPreconisee__c 	= solutionPreconisee;
            leads[0].dateActivationTrial__c	= dateActivationTrial;
            update leads[0];       
            return leads[0];
        }        
        return null;
    }   
}