public class OrderUnpaidEmailController{
    public List<RelanceWithDependencies> relancesWithDependencies {get; set;}

    public OrderUnpaidEmailController(){
        this.relancesWithDependencies = new List<RelanceWithDependencies>();
        
        Paiement__c[] paiements;
        if(Test.isRunningTest()){
            paiements = [SELECT Retard_de_paiement__c, Commande_Lie__c, Date_de_paiement_estime__c FROM Paiement__c WHERE Retard_de_paiement__c <= 0 AND Commande_Lie__r.Facturation_NoRelance__c = false AND Commande_Lie__r.Account.Type != 'Distributeur' AND Commande_Lie__r.En_cours_de_paiement__c = false];
        }else{
            paiements = [SELECT Retard_de_paiement__c, Commande_Lie__c, Date_de_paiement_estime__c FROM Paiement__c WHERE Retard_de_paiement__c < 0 AND Commande_Lie__r.Facturation_NoRelance__c = false AND Commande_Lie__r.Account.Type != 'Distributeur' AND Commande_Lie__r.En_cours_de_paiement__c = false];
        }
    
        Map<Decimal, Relance__c> relancesByNbDays = new Map<Decimal, Relance__c>();
        List<Decimal> relancesNbDaysSorted = new List<Decimal>();
        
        for(Relance__c relance : [SELECT Nb_Days__c, Template_Email__c, Order_Status__c, Name FROM Relance__c]){
            relancesByNbDays.put(relance.Nb_Days__c, relance);
            relancesNbDaysSorted.add(relance.Nb_Days__c);
        }
        
        relancesNbDaysSorted.sort();
        
        List<Id> ordersIds = new List<Id>();
        for(Paiement__c paiement : paiements){
            ordersIds.add(paiement.Commande_Lie__c);
        }
        Map<Id, Order> ordersByIds = new Map<Id, Order>([SELECT Id, OrderNumber, Account.Type, Contact_Email__c, Contact_li_langue__c, Facturation_Statut__c, Facturation_Date_1ere_relance__c, Facturation_Date_2eme_relance__c, Facturation_Date_3eme_relance__c, Facturation_MailContact__c FROM Order WHERE Id in :ordersIds]);
        
        Map<Id, Facture__c> facturesByOrderId = new Map<Id, Facture__c>();
        for(Facture__c facture : [SELECT Commande_lie__c, TotalAmountAfterTVAWithCurrency__c, Date__c, Name FROM Facture__c WHERE Commande_lie__c IN :ordersIds ORDER BY CreatedDate DESC]){
            if(facturesByOrderId.containsKey(facture.Commande_lie__c) == false){
                facturesByOrderId.put(facture.Commande_lie__c, facture);
            }
        }
        
        for(Paiement__c paiement : paiements){
            Decimal retardPaiement = Math.abs(paiement.Retard_de_paiement__c);
            
            Relance__c relanceToApply = null;
            Integer indexRelance = 1;
            for(Decimal relanceNbDay : relancesNbDaysSorted){
                if(retardPaiement >= relanceNbDay && retardPaiement < relanceNbDay + 1){
                    relanceToApply = relancesByNbDays.get(relanceNbDay);
                    break;
                }else{
                    indexRelance++;
                }
            }
            
            if(relanceToApply != null && facturesByOrderId.containsKey(paiement.Commande_Lie__c)){
                Order orderPaiement = ordersByIds.get(paiement.Commande_Lie__c);
                
                Boolean isFR = orderPaiement.Contact_li_langue__c == 'FR';
                String templateName = relanceToApply.Template_Email__c;
                
                Map<String, String> mapSubjectParams = new Map<String, String> {
                };
                
                System.debug(orderPaiement.Id);
                System.debug(facturesByOrderId);
                Facture__c facturePaiement = facturesByOrderId.get(orderPaiement.Id);
                Converter.Locale localeDate;
                if(isFR){
                    localeDate = Converter.Locale.FR;
                }else{
                    localeDate = Converter.Locale.US;
                }
                System.debug(facturePaiement);
                String dateFacture = Converter.DateToLocaleDate(facturePaiement.Date__c, localeDate);
                String datePaiementEstimated = Converter.DateToLocaleDate(paiement.Date_de_paiement_estime__c, localeDate);
                
                String subject;
                if(isFR){
                    templateName += ' FR';
                    subject = 'XLSTAT – Facture impayée ' + 'n°' + facturePaiement.Name;
                }else{
                    templateName += ' US';
                    subject = 'XLSTAT – Unpaid invoice ' + '#' + facturePaiement.Name;
                }
                
                Map<String, String> mapBodyParams = new Map<String, String> {
                    '{!FactureDate}' => dateFacture,
                    '{!FactureAmount}' => facturePaiement.TotalAmountAfterTVAWithCurrency__c,
                    '{!FactureId}' => facturePaiement.Name,
                    '{!FactureDateEnd}' => datePaiementEstimated 
                };
                
                List<EmailMessageWrapper> listEmailMessageWrapper = new List<EmailMessageWrapper>();
                List<String> emails = new List<String>();
                listEmailMessageWrapper.add(new EmailMessageWrapper('sales@xlstat.com', orderPaiement.Contact_Email__c, null, null, subject, mapSubjectParams, null, mapBodyParams));
                emails.add(orderPaiement.Contact_Email__c);
                if(orderPaiement.Account.Type == 'Revendeur' && orderPaiement.Facturation_MailContact__c != null){
                    listEmailMessageWrapper.add(new EmailMessageWrapper('sales@xlstat.com', orderPaiement.Facturation_MailContact__c, null, null, subject, mapSubjectParams, null, mapBodyParams));
                    emails.add(orderPaiement.Facturation_MailContact__c);
                }
                
                UtilityClass utilityClass = new UtilityClass(listEmailMessageWrapper, templateName);
                
                RelanceWithDependencies relanceWithDependencies = new RelanceWithDependencies();
                relanceWithDependencies.UtilityClass = utilityClass;
                relanceWithDependencies.Order = orderPaiement;
                relanceWithDependencies.Relance = relanceToApply;
                relanceWithDependencies.IndexRelance = indexRelance;
                relanceWithDependencies.Emails = emails;
                
                this.relancesWithDependencies.add(relanceWithDependencies);
            }
        }
    }
    
    public void Send(){
        Boolean successSendEmail = true;
        for(RelanceWithDependencies relanceWithDependencies : this.relancesWithDependencies){        
            successSendEmail = true;
            List<Messaging.SendEmailResult> results = relanceWithDependencies.UtilityClass.sendEmail(null);
            for(Integer i = 0; i < results.size(); i++){
                Messaging.SendEmailResult result = results[i];
                if(result.isSuccess() == false){
                    successSendEmail = false;
                    break;
                }
            }
            
            if(successSendEmail == true){
                relanceWithDependencies.Order.Facturation_Statut__c = relanceWithDependencies.Relance.Order_Status__c;
                if(relanceWithDependencies.IndexRelance == 1){
                    relanceWithDependencies.Order.Facturation_Date_1ere_relance__c = DateTime.now();
                }else if(relanceWithDependencies.IndexRelance == 2){
                    relanceWithDependencies.Order.Facturation_Date_2eme_relance__c = DateTime.now();
                }else if(relanceWithDependencies.IndexRelance == 3){
                    relanceWithDependencies.Order.Facturation_Date_3eme_relance__c = DateTime.now();
                }
                
                update relanceWithDependencies.Order;
            }
        }
        
        if(successSendEmail){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Tous les emails de relance ont été envoyés avec succés.'));
        }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Certains emails de relance n\'ont pas pû être envoyés.'));
        }
    }
    
    private class RelanceWithDependencies{
        public Order Order {get; set;}
        public Relance__c Relance {get; set;}
        public UtilityClass UtilityClass {get; set;}
        public List<String> Emails {get; set;}
        public Integer IndexRelance {get; set;}
    }
}