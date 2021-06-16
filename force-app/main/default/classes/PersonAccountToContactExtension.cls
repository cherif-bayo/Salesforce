public class PersonAccountToContactExtension{
    public Account PersonAccount {get; set;}
    public Account ProAccount {get; set;}
    public Order order {get; set;}
    
    public PersonAccountToContactExtension(ApexPages.StandardController stdController) {
        this.PersonAccount = (Account)stdController.getRecord();
        this.PersonAccount = [SELECT No_support__pc, Second_mail__pc, ShareIt_Auto__pc, Systeme_d_exploitation__pc, Website_Auto__pc, XLSTAT_365__pc, Piste_source_site__pc, Piste_nombre_recommand__pc, Piste_nombre_de_recommandations__pc, Piste_premier_telechargement__pc, Piste_date_dernier_recommand__pc, Piste_date_derni_re_recommandation__pc, Piste_date_cr_ation__pc, Piste_nombre_de_t_l_chargements__pc, Piste_date_dernier_t_l_chargement__pc, Date_creation_compte_MyAccount__pc, Compte_MyAccount_cree__pc, Acces_MyAccount__pc, PersonContactId, IsPersonAccount, PersonAssistantName, PersonAssistantPhone, PersonBirthdate, CurrencyIsoCode, PersonDepartment, PersonDoNotCall, PersonEmail, PersonHasOptedOutOfEmail, Fax, PersonHasOptedOutOfFax, PersonHomePhone, PersonLeadSource, PersonMobilePhone, FirstName, LastName, Salutation, PersonOtherPhone, Phone, PersonTitle, Description, Ancien_email__pc, Domaine_utilisateur__c, Import_auto__c, Langue__pc, No_mailling__pc, Organisation__pc, Pays__pc, Remarques__c, Revendeur__pc  FROM Account WHERE Id = :this.PersonAccount.Id limit 1];
        this.order = [SELECT AccountId, Status FROM Order limit 1];
    }
    
    public PageReference Convert(){
        this.ProAccount = [SELECT Id, IsPersonAccount FROM Account WHERE Id = :this.order.AccountId];
    
        if(ProAccount != null){
            if(!ProAccount.IsPersonAccount){
                if(PersonAccount.IsPersonAccount){
                    Opportunity[] accountOpportunities = [SELECT AccountId FROM Opportunity WHERE AccountId = :PersonAccount.Id];
                    Order[] accountOrders = [SELECT AccountId, Status FROM Order WHERE AccountId = :PersonAccount.Id];
                    Map<String, List<Order>> ordersByStatus = new Map<String, List<Order>>();
                    for(Order order : accountOrders){
                        if(ordersByStatus.containsKey(order.Status)){
                            ordersByStatus.get(order.Status).add(order);
                        }else{
                            List<Order> orders =new List<Order>();
                            orders.add(order);
                            ordersByStatus.put(order.Status, orders);
                        }
                    }                                      
                    
                    Opportunity[] contactOpportunitiesClientFinal = [SELECT Client_Final__c FROM Opportunity WHERE Client_Final__c = :PersonAccount.PersonContactId];
                    Order[] contactOrdersClientFinal = [SELECT Client_Final__c FROM Order WHERE Client_Final__c = :PersonAccount.PersonContactId];
                    
                    Opportunity[] contactOpportunitiesContactLie = [SELECT Contact_Lie__c FROM Opportunity WHERE Contact_Lie__c = :PersonAccount.PersonContactId];
                    Order[] contactOrdersContactLie = [SELECT Contact_Lie__c FROM Order WHERE Contact_Lie__c = :PersonAccount.PersonContactId];
                    
                    Flexera_Key__c[] contactFlexeraKeys = [SELECT Contact__c, Account__c FROM Flexera_Key__c WHERE Contact__c = :PersonAccount.PersonContactId];
                    
                    Email__c[] contactEmails = [SELECT Contact__c, Order__c, Address__c, Type__c FROM Email__c WHERE Contact__c = :PersonAccount.PersonContactId];
                    
                    Telechargement__c[] telechargements = [SELECT Contact__c FROM Telechargement__c WHERE Contact__c = :PersonAccount.PersonContactId];
                    
                    XLSTAT_365_Activation__c[] activations = [SELECT Contact__c FROM XLSTAT_365_Activation__c WHERE Contact__c = :PersonAccount.PersonContactId];                                       
                    
                    Contact contact = new Contact();
                    contact.AccountId = ProAccount.Id;
                    contact.AssistantName = this.PersonAccount.PersonAssistantName;
                    contact.AssistantPhone = this.PersonAccount.PersonAssistantPhone;
                    contact.Birthdate = this.PersonAccount.PersonBirthdate;
                    contact.CurrencyIsoCode = this.PersonAccount.CurrencyIsoCode; 
                    contact.Department = this.PersonAccount.PersonDepartment; 
                    contact.DoNotCall = this.PersonAccount.PersonDoNotCall;
                    contact.Email = this.PersonAccount.PersonEmail;
                    contact.HasOptedOutOfEmail = this.PersonAccount.PersonHasOptedOutOfEmail;
                    contact.Fax = this.PersonAccount.Fax;
                    contact.HasOptedOutOfFax = this.PersonAccount.PersonHasOptedOutOfFax;
                    contact.HomePhone = this.PersonAccount.PersonHomePhone;
                    contact.LeadSource = this.PersonAccount.PersonLeadSource;
                    contact.MobilePhone = this.PersonAccount.PersonMobilePhone;
                    contact.Salutation = this.PersonAccount.Salutation;
                    contact.FirstName = this.PersonAccount.FirstName;
                    contact.LastName = this.PersonAccount.LastName;
                    contact.Salutation = this.PersonAccount.Salutation;
                    contact.OtherPhone = this.PersonAccount.PersonOtherPhone;
                    contact.Phone = this.PersonAccount.Phone;
                    contact.Title = this.PersonAccount.PersonTitle;
                    contact.Description = this.PersonAccount.Description;
                    contact.Ancien_email__c = this.PersonAccount.Ancien_email__pc;
                    contact.Domaine_utilisateur__c = this.PersonAccount.Domaine_utilisateur__c;
                    contact.Import_auto__c = this.PersonAccount.Import_auto__c;
                    contact.Langue__c = this.PersonAccount.Langue__pc;
                    contact.No_mailling__c = this.PersonAccount.No_mailling__pc;
                    contact.Organisation__c = this.PersonAccount.Organisation__pc; 
                    contact.Pays__c = this.PersonAccount.Pays__pc;
                    contact.Remarques__c = this.PersonAccount.Remarques__c;
                    contact.Revendeur__c = this.PersonAccount.Revendeur__pc;
                    contact.Acces_MyAccount__c = this.PersonAccount.Acces_MyAccount__pc;
                    contact.Compte_MyAccount_cree__c = this.PersonAccount.Compte_MyAccount_cree__pc;
                    contact.Date_creation_compte_MyAccount__c = this.PersonAccount.Date_creation_compte_MyAccount__pc;
                    contact.Piste_date_dernier_t_l_chargement__c = this.PersonAccount.Piste_date_dernier_t_l_chargement__pc;
                    contact.Piste_nombre_de_t_l_chargements__c = this.PersonAccount.Piste_nombre_de_t_l_chargements__pc;  
                    contact.Piste_date_cr_ation__c = this.PersonAccount.Piste_date_cr_ation__pc;  
                    contact.Piste_date_derni_re_recommandation__c = this.PersonAccount.Piste_date_derni_re_recommandation__pc;  
                    contact.Piste_date_dernier_recommand__c = this.PersonAccount.Piste_date_dernier_recommand__pc;     
                    contact.Piste_premier_telechargement__c = this.PersonAccount.Piste_premier_telechargement__pc;       
                    contact.Piste_nombre_de_recommandations__c = this.PersonAccount.Piste_nombre_de_recommandations__pc;       
                    contact.Piste_nombre_recommand__c = this.PersonAccount.Piste_nombre_recommand__pc;  
                    contact.Piste_source_site__c = this.PersonAccount.Piste_source_site__pc; 
                    contact.Revendeur__c = this.PersonAccount.Revendeur__pc; 
                    contact.XLSTAT_365__c = this.PersonAccount.XLSTAT_365__pc;       
                    contact.Website_Auto__c = this.PersonAccount.Website_Auto__pc;
                    contact.Systeme_d_exploitation__c = this.PersonAccount.Systeme_d_exploitation__pc;
                    contact.ShareIt_Auto__c = this.PersonAccount.ShareIt_Auto__pc;
                    contact.Second_mail__c = this.PersonAccount.Second_mail__pc;
                    contact.No_support__c = this.PersonAccount.No_support__pc;
                    
                    insert contact;
                    
                    for(Opportunity opportunity : accountOpportunities){
                        opportunity.AccountId = ProAccount.Id;
                        opportunity.Contact_lie__c = contact.Id;                        
                    }
                    List<Order> ordersToUpdate = new List<Order>();
                    for(List<Order> orders : ordersByStatus.values()){
                        for(Order order : orders){
                            order.AccountId = ProAccount.Id;
                            order.Contact_Lie__c = contact.Id;
                            order.Status = 'Version préliminaire';
                            
                            ordersToUpdate.add(order);
                        }
                    }
                    update accountOpportunities;
                    update ordersToUpdate;
                    ordersToUpdate.clear();
                    for(String status : ordersByStatus.keySet()){
                        for(Order order : ordersByStatus.get(status)){
                            order.Status = status;
                            ordersToUpdate.add(order);
                        }
                    }
                    
                    update ordersToUpdate;
                    
                    for(Opportunity opportunity : contactOpportunitiesClientFinal){
                        opportunity.Client_Final__c = contact.Id;
                    }
                    for(Order order : contactOrdersClientFinal){
                        order.Client_Final__c = contact.Id;
                    }
                    update contactOpportunitiesClientFinal;
                    update contactOrdersClientFinal;
                    
                    for(Opportunity opportunity : contactOpportunitiesContactLie){
                        opportunity.Contact_Lie__c = contact.Id;
                    }
                    for(Order order : contactOrdersContactLie){
                        order.Contact_Lie__c = contact.Id;
                    }
                    update contactOpportunitiesContactLie;
                    update contactOrdersContactLie;                   
                    
                    for(Flexera_Key__c flexeraKey : contactFlexeraKeys){
                        flexeraKey.Contact__c = contact.Id;
                        flexeraKey.Account__c = ProAccount.Id;
                    }
                    update contactFlexeraKeys;
                    
                    for(Email__c email : contactEmails){
                        email.Contact__c = contact.Id;
                    }
                    update contactEmails;
                    
                    for(Telechargement__c telechargement : telechargements){
                        telechargement.Contact__c = contact.Id;
                    }
                    update telechargements;                  
                    
                    for(XLSTAT_365_Activation__c activation : activations){
                        activation.Contact__c = contact.Id;
                    }
                    update activations;
                    
                    //TODO delete old personaccount;
                    
                    PageReference pageRef = new PageReference('/' + contact.Id);
                    pageRef.setRedirect(true);
                    return pageRef;
                }else{
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'The account to convert is not a person account.'));
                }
            }else{
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'The selected account is not a pro account.'));
            }
        }else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please the linked pro account first.'));
        }
        
        return null;
    }
}