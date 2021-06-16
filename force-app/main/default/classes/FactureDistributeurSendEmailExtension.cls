public with sharing class FactureDistributeurSendEmailExtension
{
    private ApexPages.StandardController standardController;
    
    private Facture_Distributeur__c facture;
    
    private Map<String, Id> contactIdByEmail;
    
    public List<SelectOption> Emails {get; set;}
    public String Email {get; set;}
    
    public String GetFactureId(){
        return this.facture.Id;
    }
    
    public String GetAttachmentLink(){
        return 'servlet/servlet.FileDownload?file=' + this.attachment.Id;
    }
    public String GetAttachmentName(){
        return this.attachment.Name;
    }
    
    public String Subject {get; set;}
    public String Body {get; set;}
    private Attachment attachment;
    
    public Boolean IsValid {get; set;}
    
    public FactureDistributeurSendEmailExtension(ApexPages.StandardController standardController)
    {
        this.standardController = standardController;
        this.facture = [select Id, GenerateFactureEN__c, Compte_lie__c, PeriodeEN__c, Periode__c from Facture_Distributeur__c where Id = :standardController.getId() limit 1];
        
        this.IsValid = true;
        
        this.contactIdByEmail = new Map<String, Id>();
        this.Emails = new List<SelectOption>();
        for(Contact contact : [SELECT Email FROM Contact WHERE AccountId = :this.facture.Compte_Lie__c]){
            this.Emails.add(new SelectOption(contact.Email, contact.Email));
            this.contactIdByEmail.put(contact.Email, contact.Id);
        }
        
        if(this.Emails.size() > 0){
            Attachment[] attachments = [select Id, Name, Body from Attachment where ParentId = :this.facture.Id ORDER BY CreatedDate DESC limit 1];
            if(attachments.size() > 0){
                this.attachment = attachments[0];
            
                if(this.facture.GenerateFactureEN__c){
                    // Specify the subject line for your email address.
                    this.Subject = 'XLSTAT Invoice ' + this.facture.PeriodeEN__c;
                    
                    // Specify the text content of the email.
                    this.Body = 'Dear Sirs,\n\nPlease find enclosed our invoice for the period ' + this.facture.PeriodeEN__c + '.\n\nKind Regards,\nThe XLSTAT sales team';
                }else{
                    // Specify the subject line for your email address.
                    this.Subject = 'XLSTAT Facture ' + this.facture.Periode__c;
                    
                    // Specify the text content of the email.
                    this.Body = 'Bonjour,\n\nVeuillez trouver ci-jointe notre facture pour la période de ' + this.facture.Periode__c + '.\n\nCordialement,\nL\'équipe de ventes d\'XLSTAT';
                }
            }else{
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Aucun fichier de facture trouvé.'));
                this.IsValid = false;
            }
        }else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Aucun contact lié au distributeur.'));
            this.IsValid = false;
        }
    }
    
    public PageReference Send(){
        try{
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            String[] toAddresses = new String[] {this.Email}; 
              
            mail.setToAddresses(toAddresses);
            
            mail.setReplyTo('sales@xlstat.com');
            
            // Specify the name used as the display name.
            mail.setSenderDisplayName('XLSTAT Sales');
            
            mail.setSubject(this.Subject);
            mail.setPlainTextBody(this.Body);
            
            // Create the email attachment
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            efa.setFileName(this.attachment.Name);
            efa.setBody(this.attachment.Body);
    
            mail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
            
            // Send the email you have created.
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            
            Email__c email = new Email__c();
            email.Facture_distributeur__c = this.facture.Id;
            email.Contact__c = this.contactIdByEmail.get(this.Email);
            email.Subject__c = subject;
            email.Type__c = 'Facturation';
            email.Address__c = this.Email;
            
            insert email;
            
            PageReference pr = new PageReference('/' + this.facture.Id);
            pr.setRedirect(true);
            return pr;
        }catch(Exception ex){
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Erreur :' + ex.getMessage()));
        }
        
        return null;
    }
}