public class LeadToContactOrPersonAccountExtension{
    public Lead Lead {get; set;}
    public Order order {get; set;}
    
    public String ConversionType {get; set;}
    
    public static final String CONTACT_OPTION = 'CONTACT';
    public static final String ACCOUNT_OPTION = 'ACCOUNT';    
    
    public List<SelectOption> getConversionTypes() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption(CONTACT_OPTION,'Contact'));
        options.add(new SelectOption(ACCOUNT_OPTION,'Compte personnel'));
        return options;
    }
    
    public Boolean getIsContactConversion(){
        return this.ConversionType == CONTACT_OPTION;
    }
    
    public LeadToContactOrPersonAccountExtension(ApexPages.StandardController stdController) {
        this.Lead = [SELECT Id, DoNotCall, HasOptedOutOfEmail, Fax, HasOptedOutOfFax, Salutation, FirstName, LastName, Phone, Title, Systeme_d_exploitation__c, Date_premier_telechargement__c, LeadSource, CreatedDate, Email, Date_derniere_recommendation__c, Date_dernier_recommand__c, Date_dernier_telechargement__c, Nombre_de_recommandations__c, Nombre_de_telechargements__c, Nombre_recommand__c ,Source_site__c FROM Lead WHERE Id = :stdController.getId() limit 1];
        this.order = new Order();
    }
    
    public PageReference Convert(){
        Telechargement__c[] telechargements = [SELECT Lead__r.Email, Lead__c, Contact__c FROM Telechargement__c WHERE Lead__c = :this.Lead.Id];
        
        XLSTAT_365_Activation__c[] activationsXLSTAT365 = [SELECT Lead__r.Email, Lead__c, Contact__c FROM XLSTAT_365_Activation__c WHERE Lead__c = :this.Lead.Id];
                    
        if(this.getIsContactConversion()){
            Account proAccount = [SELECT Id, IsPersonAccount FROM Account WHERE Id = :this.order.AccountId];
            
            if(proAccount != null){
                if(!proAccount.IsPersonAccount){
                    Contact c = new Contact();
                    c.AccountId = proAccount.Id;
                    c.DoNotCall = this.Lead.DoNotCall;
                    c.Email = this.Lead.Email;
                    c.HasOptedOutOfEmail = this.Lead.HasOptedOutOfEmail;
                    c.Fax = this.Lead.Fax;
                    c.HasOptedOutOfFax = this.Lead.HasOptedOutOfFax;
                    c.LeadSource = this.Lead.LeadSource;
                    c.Salutation = this.Lead.Salutation;
                    c.FirstName = this.Lead.FirstName;
                    c.LastName = this.Lead.LastName;
                    c.Phone = this.Lead.Phone;
                    c.Title = this.Lead.Title;
                    c.Piste_date_cr_ation__c = this.Lead.CreatedDate;
                    c.Piste_date_derni_re_recommandation__c = this.Lead.Date_derniere_recommendation__c;
                    c.Piste_date_dernier_recommand__c = this.Lead.Date_dernier_recommand__c;
                    c.Piste_date_dernier_t_l_chargement__c = this.Lead.Date_dernier_telechargement__c;
                    c.Piste_premier_telechargement__c = this.Lead.Date_premier_telechargement__c;
                    c.Piste_nombre_de_recommandations__c = this.Lead.Nombre_de_recommandations__c;
                    c.Piste_nombre_de_t_l_chargements__c = this.Lead.Nombre_de_telechargements__c;
                    c.Piste_nombre_recommand__c = this.Lead.Nombre_recommand__c;
                    c.Piste_source_site__c = this.Lead.Source_site__c;
                    c.XLSTAT_365__c = activationsXLSTAT365.size() > 0;
                    c.Systeme_d_exploitation__c = this.Lead.Systeme_d_exploitation__c;
                    
                    insert c;
                    
                    for(Telechargement__c telechargement : telechargements){
                        telechargement.Contact__c = c.Id;
                        telechargement.Lead__c = null;
                    }
                    
                    update telechargements;
                    
                    for(XLSTAT_365_Activation__c activation : activationsXLSTAT365){
                        activation.Contact__c = c.Id;
                        activation.Lead__c = null;
                    }
                    
                    update activationsXLSTAT365;
                    
                    PageReference pageRef = new PageReference('/' + c.Id);
                    pageRef.setRedirect(true);
                    return pageRef;
                }else{
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'The selected account is not a pro account.'));
                }
            }else{
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please the linked pro account first.'));
            }
        }else{
            Account c = new Account();
            c.PersonDoNotCall = this.Lead.DoNotCall;
            c.PersonEmail = this.Lead.Email;
            c.PersonHasOptedOutOfEmail = this.Lead.HasOptedOutOfEmail;
            c.Fax = this.Lead.Fax;
            c.PersonHasOptedOutOfFax = this.Lead.HasOptedOutOfFax;
            c.PersonLeadSource = this.Lead.LeadSource;
            c.Salutation = this.Lead.Salutation;
            c.FirstName = this.Lead.FirstName;
            c.LastName = this.Lead.LastName;
            c.Phone = this.Lead.Phone;
            c.PersonTitle = this.Lead.Title;
            c.Piste_date_cr_ation__pc = this.Lead.CreatedDate;
            c.Piste_date_derni_re_recommandation__pc = this.Lead.Date_derniere_recommendation__c;
            c.Piste_date_dernier_recommand__pc = this.Lead.Date_dernier_recommand__c;
            c.Piste_date_dernier_t_l_chargement__pc = this.Lead.Date_dernier_telechargement__c;
            c.Piste_premier_telechargement__pc = this.Lead.Date_premier_telechargement__c;
            c.Piste_nombre_de_recommandations__pc = this.Lead.Nombre_de_recommandations__c;
            c.Piste_nombre_de_t_l_chargements__pc = this.Lead.Nombre_de_telechargements__c;
            c.Piste_nombre_recommand__pc = this.Lead.Nombre_recommand__c;
            c.Piste_source_site__pc = this.Lead.Source_site__c;
            c.XLSTAT_365__pc = activationsXLSTAT365.size() > 0;
            c.Systeme_d_exploitation__pc = this.Lead.Systeme_d_exploitation__c;
            
            insert c;
            
            c = [SELECT PersonContactId FROM Account WHERE Id = :c.Id LIMIT 1];
            
            for(Telechargement__c telechargement : telechargements){
                telechargement.Contact__c = c.PersonContactId;
                telechargement.Lead__c = null;
            }
            
            update telechargements;
            
            for(XLSTAT_365_Activation__c activation : activationsXLSTAT365){
                activation.Contact__c = c.PersonContactId;
                activation.Lead__c = null;
            }
            
            update activationsXLSTAT365;
            
            PageReference pageRef = new PageReference('/' + c.Id);
            pageRef.setRedirect(true);
            return pageRef;
        }
        
        return null;
    }
}