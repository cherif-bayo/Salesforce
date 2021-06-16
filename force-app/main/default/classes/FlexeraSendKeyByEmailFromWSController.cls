public without sharing class FlexeraSendKeyByEmailFromWSController{
    public static String STATCON_ACCOUNT_ID = '0012400000D3NyB';
    private static String STATCON_SH_ACCOUNT_ID = '0012400000McLO8';
    private static String MINDWARE_ACCOUNT_ID = '0012400000D3NsA';
    private static String MINDWARE_SH_ACCOUNT_ID = '0012400000ER4mV';

    private static String COUNTRY_FRANCE = 'FR';
    private static String LANGUAGE_FRANCE = 'FR';
    private static String LANGUAGE_OTHER = 'EN';
    private static String TEMPLATE_NAME_START = 'Licence key';
    private static String ANNUAL_TYPE = 'Annual';
    private static String EXPIRING_TYPE = 'Expiring';

    private List<EmailMessageWrapper> listEmailMessageWrapper;
    private Flexera_Key__c flexeraKey;
    private UtilityClassV2 utilityClass;
    private Map<String, Texte_Email__c> textesEmailByCode;

    public String FlexeraKeyId {get; set;}
    public List<Contact> contact {get;set;}
    public String LicenceKey {get;set;}
    public String LicenceModules {get;set;}
    public String LicenceNbUsers {get;set;}
    public String LicenceType {get;set;}
    public String OrderId {get;set;}
    public Boolean EmailSent{get;set;}
    public String RemarqueEmail {get; set;}
    public String ContactName{get;set;}
    public Boolean HasPreview {get; set;}
    /*public String AccountName {get; set;}
    public String HTAmount {get; set;}
    public String ShareItFee {get; set;}
    public String AmountStatcon {get; set;}*/
    public Order order {get; set;}
    public Messaging.EmailFileAttachment invoice {get; set;}

    public String HtmlBody{get; set;}

    private Map<String, String> mapBodyParams;
    private Map<String, String> mapSubjectParams;
    private Boolean isAnnual;
    private Boolean isFR;
    /*public Boolean getIsAnnualFR(){
        return isAnnual && isFr;
    }
    public Boolean getIsPerpetualFR(){
        return !isAnnual && isFr;
    }
    public Boolean getIsAnnualEN(){
        return isAnnual && !isFR;
    }
    public Boolean getIsPerpetualEN(){
        return !isAnnual && !isFr;
    }*/
    //public Boolean getHasRemarque(){ return this.RemarqueEmail != null; }
    public List<WrapperContact> WpContacts {get;set;}
    public String subject{
        get{
            if(this.subject == null){
                if(this.isFR){
                    this.subject = 'Licence XLSTAT';
                }else{
                    this.subject = 'XLSTAT License';
                }
            }
            return this.subject;
        }
        set;
    }

    private Boolean isUpdate;

    public FlexeraSendKeyByEmailFromWSController(Boolean isUpdate){ this.isUpdate = isUpdate; }

    public String OtherContactEmail {get; set;}

    public String ResellerAccountId {get; set;}

    public Boolean Send() {
        listEmailMessageWrapper = new List<EmailMessageWrapper>();
        WpContacts = new List<WrapperContact>();

        this.textesEmailByCode = new Map<String, Texte_Email__c>();
        List<Texte_Email__c> textes = [SELECT Code__c, Texte__c FROM Texte_Email__c];
        for (Texte_Email__c t :textes) textesEmailByCode.put(t.Code__c,t);

        this.flexeraKey = [SELECT Software__c, SoftwareCode__c, Is_Network__c, Expiration_Label_FR__c, Expiration_Label_EN__c, Has_Student_Ext__c, Name, Campaign__c, Order__c, Contact__c, Date_limite__c, Domaine_utilisateur__c, Expiration__c, Modules__c, Nb_activations__c, Nb_activations_allowed__c, Quantity__c, Type_client__c, Type_licence__c, XLSTAT_Options__c, XLSTAT_Solution__c, Version__c, Entitlement_Id__c FROM Flexera_Key__c WHERE Id = :this.FlexeraKeyId LIMIT 1];

        this.OrderId = this.flexeraKey.Order__c;
        System.debug('>>>> FlexeraSendKeyByEmailFromWSController - Send - this.flexeraKey = '+this.flexeraKey);
        System.debug('>>>> FlexeraSendKeyByEmailFromWSController - Send - this.OrderId = '+this.OrderId);

        this.order = [SELECT Id, AccountId, R_f_Bon_de_commande__c, Provenance__c, Remarque_Email__c, Type_licence__c, TotalAmountAfterDiscountShowed__c, Frais_ShareIt__c, Amount_Statcon__c FROM Order WHERE Id = :this.OrderId LIMIT 1];
        this.RemarqueEmail = order.Remarque_Email__c;

        List<String> contactsIds = new List<String>();
        contactsIds.add(this.flexeraKey.Contact__c);
        this.contact = [SELECT Name, Email, Second_mail__c, Langue__c, AccountId, Code_MyAccount__c, Compte_MyAccount_cree__c FROM Contact WHERE Id IN :contactsIds];
        this.ContactName = this.contact[0].Name;

        Contact[] contactsAccount = [SELECT Name, Email, Second_mail__c, Langue__c, Code_MyAccount__c, Compte_MyAccount_cree__c FROM Contact WHERE AccountId = :order.AccountId];

        List<Id> accountsIds = new List<Id>();
        for(Contact contact : this.contact){
            accountsIds.add(contact.AccountId);
        }
        Account[] accounts = [SELECT Id, IsPersonAccount, Name FROM Account WHERE Id IN :accountsIds];
        Map<Id, Account> mapAccounts = new Map<Id, Account>(accounts);

        for(Contact contact : this.contact){
            WrapperContact wpContact = new WrapperContact();
            wpContact.contact = contact;
            wpContact.ContactEmail = contact.Email;
            wpContact.contactsAccount = contactsAccount;
            wpContact.account = mapAccounts.get(contact.AccountId);
            WpContacts.add(wpContact);
        }

        if(order.R_f_Bon_de_commande__c != null && order.Provenance__c == 'Bon de commande'){
            if(this.contact[0].Langue__c == COUNTRY_FRANCE){ this.subject = 'Licence XLSTAT. Commande: ' + order.R_f_Bon_de_commande__c; }
            else{ this.subject = 'XLSTAT License. Order: ' + order.R_f_Bon_de_commande__c; }
        }

        this.isAnnual = this.flexeraKey.Expiration__c == EXPIRING_TYPE;
        this.isFR = this.contact[0].Langue__c == COUNTRY_FRANCE;

        this.LicenceKey = flexeraKey.Name;
        this.LicenceModules = flexeraKey.Modules__c;
        if(this.flexeraKey.Type_licence__c == 'Large Campus'){
            if(this.isFR){
                if(this.flexeraKey.Has_Student_Ext__c){ this.LicenceNbUsers = 'Campus, extension étudiante'; }
                else{ this.LicenceNbUsers = 'Campus, illimitée'; }
            }else{
                if(this.flexeraKey.Has_Student_Ext__c){ this.LicenceNbUsers = 'Campus, student extension'; }
                else{ this.LicenceNbUsers = 'Campus, unlimited'; }
            }
        }else if(this.flexeraKey.Type_licence__c == 'Small Campus'){
            if(this.isFR){
                if(this.flexeraKey.Has_Student_Ext__c){ this.LicenceNbUsers = 'Campus, extension étudiante'; }
                else{ this.LicenceNbUsers = 'Campus, jusqu\'à 500 utilisateurs'; }
            }else{
                if(this.flexeraKey.Has_Student_Ext__c){ this.LicenceNbUsers = 'Campus, student extension'; }
                else{ this.LicenceNbUsers = 'Campus, up to 500'; }
            }
        }else if(this.flexeraKey.Type_licence__c == 'Classroom'){
            if(this.isFR){
                if(this.flexeraKey.Has_Student_Ext__c){ this.LicenceNbUsers = 'Campus, extension étudiante'; }
                else{ this.LicenceNbUsers = 'Campus, jusqu\'à 60 utilisateurs'; }
            }else{
                if(this.flexeraKey.Has_Student_Ext__c){ this.LicenceNbUsers = 'Campus, student extension'; }
                else{ this.LicenceNbUsers = 'Campus, up to 60'; }
            }
        }else{
            this.LicenceNbUsers = String.valueOf(flexeraKey.Quantity__c);
        }
        if(this.isFR){
            this.LicenceType = flexeraKey.Expiration_Label_FR__c;
        }else{
            this.LicenceType = flexeraKey.Expiration_Label_EN__c;
        }

        this.HasPreview = false;
        this.mapSubjectParams = new Map<String, String> {
        };

        this.mapBodyParams = new Map<String, String> {
                '{!LicenceKey}' => this.LicenceKey,
                '{!LicenceModules}' => this.LicenceModules,
                '{!LicenceNbUsers}' => this.LicenceNbUsers,
                '{!LicenceType}' => this.LicenceType,
                '{!RemarqueEmail}' => this.RemarqueEmail
        };
        this.EmailSent = true;
        List<Email__c> emailsToInsert = new List<Email__c>();
        for(WrapperContact wpContact : this.WpContacts){
            mapBodyParams.put('{!ContactName}', wpContact.contact.Name);
            if(wpContact.contact.Compte_MyAccount_cree__c == false){
                mapBodyParams.put('{!CodeMyAccount}', wpContact.contact.Code_MyAccount__c);
                if(!Test.isRunningTest()){
                    if(this.isFR){
                        mapBodyParams.put('{!MyAccountDescription}', textesEmailByCode.get('FRNCD').Texte__c);
                        mapBodyParams.put('{!MyAccountButton}', textesEmailByCode.get('FRNCB').Texte__c);
                        mapBodyParams.put('{!MyAccountButtonLink}', textesEmailByCode.get('FRNCL').Texte__c);
                    }else{
                        mapBodyParams.put('{!MyAccountDescription}', textesEmailByCode.get('ENNCD').Texte__c);
                        mapBodyParams.put('{!MyAccountButton}', textesEmailByCode.get('ENNCB').Texte__c);
                        mapBodyParams.put('{!MyAccountButtonLink}', textesEmailByCode.get('ENNCL').Texte__c);
                    }
                }
            }else{
                mapBodyParams.put('{!CodeMyAccount}', '');
                if(!Test.isRunningTest()){
                    if(this.isFR){
                        mapBodyParams.put('{!MyAccountDescription}', textesEmailByCode.get('FRCD').Texte__c);
                        mapBodyParams.put('{!MyAccountButton}', textesEmailByCode.get('FRCB').Texte__c);
                        mapBodyParams.put('{!MyAccountButtonLink}', textesEmailByCode.get('FRCL').Texte__c);
                    }else{
                        mapBodyParams.put('{!MyAccountDescription}', textesEmailByCode.get('ENCD').Texte__c);
                        mapBodyParams.put('{!MyAccountButton}', textesEmailByCode.get('ENCB').Texte__c);
                        mapBodyParams.put('{!MyAccountButtonLink}', textesEmailByCode.get('ENCL').Texte__c);
                    }
                }
            }

            EmailMessageWrapper ew = new EmailMessageWrapper('sales@xlstat.com', wpContact.ContactEmail, null, null, this.subject, mapSubjectParams, null, mapBodyParams);
            if (invoice != null) ew.EmailAttachments = new List<Messaging.EmailFileAttachment>{invoice};
            listEmailMessageWrapper.add(ew);

            if(this.OtherContactEmail != null){ listEmailMessageWrapper.add(new EmailMessageWrapper('sales@xlstat.com', this.OtherContactEmail, null, null, this.subject, mapSubjectParams, null, mapBodyParams)); }
        }

        if(listEmailMessageWrapper.size() > 0){
            String templateName = TEMPLATE_NAME_START + ' ';
            if(this.isUpdate == true){ templateName += 'Update' + ' '; }else{
                if(flexeraKey.Is_Network__c == true){ templateName += 'Network' + ' '; }else{
                    templateName += flexeraKey.Expiration_Label_EN__c + ' ';
                }
            }
            if(this.isFR){
                templateName += LANGUAGE_FRANCE;
            }else{
                templateName += LANGUAGE_OTHER;
            }
            if(this.RemarqueEmail != null){ templateName += ' Remarque'; }

            this.utilityClass = new UtilityClassV2(listEmailMessageWrapper, templateName, OrderId);
            if (!Test.isRunningTest()) { this.HtmlBody = utilityClass.HtmlBody.remove(utilityClass.HtmlBody.left(utilityClass.HtmlBody.indexOf('leftpadding="0">') + 'leftpadding="0">'.length())).left(utilityClass.HtmlBody.indexOf('</body>')); }

            this.HasPreview = true;

            List<Messaging.SendEmailResult> results = this.utilityClass.sendEmail(listEmailMessageWrapper);
            for(Integer i = 0; i < this.WpContacts.size(); i++){
                Messaging.SendEmailResult result = results[i];
                if(!result.isSuccess()){ this.EmailSent = false; }
                else{
                    Email__c email = new Email__c();
                    email.Address__c = this.WpContacts[i].ContactEmail;
                    email.Contact__c = this.WpContacts[i].contact.Id;
                    email.Nalpeiron_Key__c = this.LicenceKey;
                    email.Order__c = this.OrderId;
                    email.Type__c = 'Creation';
                    email.Subject__c = this.subject;
                    emailsToInsert.add(email);
                }
            }

            if(this.ResellerAccountId != null){
                Contact[] contactReseller = [SELECT Id, Email, Account.Name FROM Contact WHERE AccountId = :this.ResellerAccountId];
                if(contactReseller.size() > 0){
                    this.mapSubjectParams = new Map<String, String> {};
                    this.mapBodyParams = new Map<String, String> {
                            '{!LicenceKey}' => this.LicenceKey,
                            '{!LicenceModules}' => this.LicenceModules,
                            '{!LicenceNbUsers}' => this.LicenceNbUsers,
                            '{!LicenceType}' => this.LicenceType,
                            '{!RemarqueEmail}' => this.RemarqueEmail != null ? this.RemarqueEmail : '',
                            '{!ContactName}' => WpContacts[0].contact.Name,
                            '{!ContactEmail}' => WpContacts[0].ContactEmail,
                            '{!HTAmount}' => String.valueOf(this.order.TotalAmountAfterDiscountShowed__c),
                            '{!ShareItFee}' => String.valueOf(this.order.Frais_ShareIt__c),
                            '{!AmountStatcon}' => String.valueOf(this.order.Amount_Statcon__c)
                    };

                    templateName = 'Statcon';
                    if(mapAccounts.get(contact[0].AccountId).IsPersonAccount == false){ mapBodyParams.put('{!AccountName}', mapAccounts.get(contact[0].AccountId).Name); }
                    else{ templateName += ' person account'; }

                    this.listEmailMessageWrapper.clear();
                    this.listEmailMessageWrapper.add(new EmailMessageWrapper('sales@xlstat.com', contactReseller[0].Email, null, null, null, mapSubjectParams, null, mapBodyParams));
                    this.utilityClass = new UtilityClassV2(this.listEmailMessageWrapper, templateName, OrderId);

                    results = this.utilityClass.sendEmail(listEmailMessageWrapper);

                    for(Integer i = 0; i < results.size(); i++){
                        Messaging.SendEmailResult result = results[i];
                        if(!result.isSuccess()){ this.EmailSent = false; }
                        else{
                            Email__c email = new Email__c();
                            email.Address__c = contactReseller[0].Email;
                            email.Contact__c = contactReseller[0].Id;
                            email.Nalpeiron_Key__c = this.LicenceKey;
                            email.Order__c = this.OrderId;
                            email.Type__c = this.order.AccountId == STATCON_ACCOUNT_ID || this.order.AccountId == STATCON_SH_ACCOUNT_ID ? 'Statcon Creation' : 'Mindware Creation';
                            email.Subject__c = this.subject;
                            emailsToInsert.add(email);
                        }
                    }
                }
            }
            insert emailsToInsert;
        }else{ this.EmailSent = false; }
        return this.EmailSent;
    }

    public class WrapperContact{
        public Contact contact {get;set;}
        public String ContactEmail{get;set;}
        public Account account {get;set;}
        public List<SelectOption> ContactsAccountEmails{
            get{
                List<SelectOption> options = new List<SelectOption>();
                options.add(new SelectOption(this.contact.Email, this.contact.Email));
                if(this.contact.Second_mail__c != null){ options.add(new SelectOption(this.contact.Second_mail__c, this.contact.Second_mail__c)); }
                for(Contact c : this.contactsAccount){
                    if(c.Id != this.contact.Id && c.Email != null){ options.add(new SelectOption(c.Email, c.Email)); }
                }
                return options;
            }
        }
        public List<Contact> contactsAccount {get;set;}
    }
}