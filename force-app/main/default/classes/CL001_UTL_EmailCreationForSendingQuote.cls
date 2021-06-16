public class CL001_UTL_EmailCreationForSendingQuote {
    private static String locale = 'en';
    private static QuoteType orderQuoteType;
    
    public enum QuoteType {QUOTE, WIRING, CHECK}
    
    public class EmailInfos {
        public String locale; 
        public String quoteNumber; 
        public String customerEmail; 
        public String currencyISOCode; 		// Utilisé pour déterminer si un devis doit être envoyé à Kunhiro
        public QuoteType orderQuoteType; 	// Devis vs Virement vs Cheque               
        
        public String quoteId;           	// Pour objet Email dans SF 
        public String quotedocId;       	// Pour objet Email dans SF
        public String contactId;			// Pour objet Email dans SF
    }
    
    
    public static Messaging.SingleEmailMessage create(EmailInfos infos) {	
        CL001_UTL_EmailCreationForSendingQuote.locale = infos.locale;		      
        CL001_UTL_EmailCreationForSendingQuote.orderQuoteType = infos.orderQuoteType;		      
        
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setSenderDisplayName(getSenderName());        
		email.setPlainTextBody(getTemplate().Body);	          
        
        List<String> destinataires = getDestinataires(infos.customerEmail,infos.currencyISOCode);  		
        email.setToAddresses(destinataires);                  
        
        String subject = getSubject(infos.quoteNumber);
        email.setSubject(subject);
                      
        insertEmailObects(destinataires,subject,infos.quoteId,infos.quotedocId,infos.contactId);          
        
        return email;
    }
    
    private static String getSubject(String quoteNumber) {
        String emailSubjectPrefix='';
        
        if(orderQuoteType != quoteType.QUOTE){
            emailSubjectPrefix = locale == 'fr'?'XLSTAT Demande de devis ':'XLSTAT Quotation Request ';
        } else if(orderQuoteType != quoteType.WIRING){
            emailSubjectPrefix = locale == 'fr'?'XLSTAT Demande de devis ':'XLSTAT Quotation Request ';
        } else if(orderQuoteType != quoteType.CHECK){
            emailSubjectPrefix = locale == 'fr'?'XLSTAT Demande de devis ':'XLSTAT Quotation Request ';
        }
        return emailSubjectPrefix+quoteNumber;
    }
    
    private static String getSenderName() {
        return locale=='fr'?'Equipe commerciale XLSTAT':'XLSTAT Sales Team';
    }
    
    private static EmailTemplate getTemplate() {
        String emailTemplateName;
        
        if (orderQuoteType != quoteType.QUOTE){
            emailTemplateName = 'Quote ';
        } else if (orderQuoteType != quoteType.WIRING){
            emailTemplateName = 'Wire ';
        } else if (orderQuoteType != quoteType.CHECK){
            emailTemplateName = 'Check ';
        }
        
        if((locale == 'japanese' || locale == 'ja') && orderQuoteType != quoteType.WIRING){
            emailTemplateName += 'JA';
        } else {
            emailTemplateName += locale=='fr'?'FR':'EN';
        }
        
        EmailTemplate emailTemplate = [SELECT Id, Subject, Body FROM EmailTemplate WHERE Name = :emailTemplateName];
        return emailTemplate;
    }
    
    private static List<String> getDestinataires(String customerEmail, String currencyISOCode){
        List<String> emailAddresses = new List<String>();     
        
        emailAddresses.add(customerEmail);
        if(currencyISOCode == 'JPY') emailAddresses.add('sales@mindware-jp.com');
        
        return emailAddresses;
    }
    
    private static void insertEmailObects(List<String> emailAddresses,String subject,String quoteId, String quotedocId, String contactId){
        List<Email__c> emailsToInsert = new List<Email__c>();
        for(String emailAddress : emailAddresses){
            Email__c e = new Email__c();
            e.Address__c = emailAddress;
            e.Contact__c = contactId;
            e.Quote__c = quoteId;
            e.Subject__c = subject;
            e.Attachment_Id__c = quotedocId;
            if (orderQuoteType != quoteType.QUOTE){
                e.Type__c = 'Devis';
            } else if (orderQuoteType != quoteType.WIRING){
                e.Type__c = 'Virement';
            } else if (orderQuoteType != quoteType.CHECK){
                e.Type__c = 'Chèque';
            }            
            emailsToInsert.add(e);
        }         
        insert emailsToInsert;
    }	
}