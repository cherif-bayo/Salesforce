public class SendEmailPersonAccountMyAccountExtension{    
    private Account account;
    
    public Boolean EmailSent {get; set;}
    public Boolean Status {get; set;}

    public SendEmailPersonAccountMyAccountExtension(ApexPages.StandardController stdController) {
        this.account = (Account)stdController.getRecord();
        this.EmailSent = false;  
        this.Status = true;
    }
    
    public PageReference SendEmail(){   
        Account c = [select Id, Name, Langue__pc, Code_MyAccount__pc,PersonEmail, IsPersonAccount, PersonContactId from Account where Id = :this.account.Id limit 1];
                
        if(c.IsPersonAccount){
            Map<String, String> mapSubjectParams = new Map<String, String> {};
            
            Map<String, String> mapBodyParams = new Map<String, String> {
                '{!ContactName}' => c.Name,
                '{!CodeMyAccount}' => c.Code_MyAccount__pc
            };
            
            String subject = c.Langue__pc == 'FR' ? 'Création de votre compte XLSTAT' : 'Create a My XLSTAT account';
                       
            List<EmailMessageWrapper> listEmailMessageWrapper = new List<EmailMessageWrapper>();           
            listEmailMessageWrapper.add(new EmailMessageWrapper('sales@xlstat.com', c.PersonEmail, null, null, subject, mapSubjectParams, null, mapBodyParams));
            
            String templateName = 'MyXLSTAT US';
            if(c.Langue__pc == 'FR'){
                templateName = 'MyXLSTAT FR';
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
                    email.Address__c = c.PersonEmail;
                    email.Contact__c = c.PersonContactId;
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
        }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Le compte sélectionné n\'est pas un compte personnel.'));
        }
        
        return null;
    }
}