public class SendEmailMyAccountFixDuplicateExtension {
	private Contact contact;
    
    public Boolean EmailSent {get; set;}
    public Boolean Status {get; set;}

    public SendEmailMyAccountFixDuplicateExtension(ApexPages.StandardController stdController) {
        this.contact = (Contact)stdController.getRecord();
        this.EmailSent = false;  
        this.Status = true;
	}
    
    public PageReference SendEmail(){   
        Contact c = [select Id, Name, Langue__c, Code_MyAccount__c,Email from Contact where Id = :this.contact.Id limit 1];
                
        Map<String, String> mapSubjectParams = new Map<String, String> {};
        
        Map<String, String> mapBodyParams = new Map<String, String> {
            '{!ContactName}' => c.Name,
            '{!CodeMyAccount}' => c.Code_MyAccount__c
        };
        
        String subject = c.Langue__c == 'FR' ? 'Création de votre compte XLSTAT' : 'Create a My XLSTAT account';
                   
        List<EmailMessageWrapper> listEmailMessageWrapper = new List<EmailMessageWrapper>();           
        listEmailMessageWrapper.add(new EmailMessageWrapper('sales@xlstat.com', c.Email, null, null, subject, mapSubjectParams, null, mapBodyParams));
        
        String templateName = 'MyXLSTAT DUPLICATE US';
        if(c.Langue__c == 'FR'){
            templateName = 'MyXLSTAT DUPLICATE FR';
        }
                    
        UtilityClass utilityClass = new UtilityClass(listEmailMessageWrapper, templateName);
        List<Messaging.SendEmailResult> results = utilityClass.sendEmail(listEmailMessageWrapper);
        this.EmailSent = true;
        List<Email__c> emailsToInsert = new List<Email__c>();
        for(Integer i = 0; i < results.size(); i++){
            Messaging.SendEmailResult result = results[i];
            if(!result.isSuccess()){
                this.EmailSent = false;
                this.Status = false;
            }else{
                Email__c email = new Email__c();
                email.Address__c = c.Email;
                email.Contact__c = c.Id;
                email.Type__c = 'My XLSTAT';
                email.Subject__c = subject;
                emailsToInsert.add(email);                     
            }
        }
                    
        insert emailsToInsert;
            
        if(Apexpages.currentPage() != null){
            if(this.EmailSent == true){
            PageReference pageRef = new PageREference('/' + c.Id);
             pageRef.setRedirect(true);
             return pageRef;
             }
        }else{
        if(Apexpages.currentPage() != null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Problème d\'envoie du mail my xlstat.'));
            }
        }
        
        return null;
    } 
}