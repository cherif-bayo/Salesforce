public with sharing class FactureDistribSendEmailReportExtension
{
    private ApexPages.StandardController standardController;
    
    private Facture_Distributeur__c facture;
    
    private Map<String, Id> contactIdByEmail;
    
    public List<SelectOption> Emails {get; set;}
    public String Email {get; set;}
    
    public String GetFactureId(){return this.facture.Id;}
    
    public String Subject {get; set;}
    public String Body {get; set;}    
    public String HTML {get; set;}
    public Boolean IsValid {get; set;}
    
    private String addValueToTableColumn(String value, String classStyle){
        return '<td class="' + classStyle  +'">' + value + '</td>';
    }
    
    public FactureDistribSendEmailReportExtension(ApexPages.StandardController standardController)
    {
        this.standardController = standardController;
        this.facture = [select Id, Montant_total_de_la_facture__c, Deduction__c, Montant_libre__c, Montant_commandes_selectionnees__c, CurrencyIsoCode, GenerateFactureEN__c, Compte_lie__c, PeriodeEN__c, Periode__c from Facture_Distributeur__c where Id = :standardController.getId() limit 1];
        
        Order[] orders = [SELECT Id, OrderNumber, R_f_Bon_de_commande__c, EffectiveDate, AccountPro__r.Name, TotalAmountAfterDiscountEUR__c, TotalAmountAfterDiscountGBP__c, TotalAmountAfterDiscountUSD__c, TotalAmountAfterDiscountJPY__c, TotalAmountVolumeEUR__c, TotalAmountVolumeUSD__c, TotalAmountVolumeJPY__c, TotalAmountVolumeGBP__c FROM Order WHERE Ref_Facture_distributeur__c = :this.facture.Id];
        Map<Id, Order> ordersByIds = new Map<Id, Order>(orders);
        
        if(orders.size() > 0){
            this.IsValid = true;
            
            this.contactIdByEmail = new Map<String, Id>();
            this.Emails = new List<SelectOption>();
            for(Contact contact : [SELECT Email FROM Contact WHERE AccountId = :this.facture.Compte_Lie__c]){
                this.Emails.add(new SelectOption(contact.Email, contact.Email));
                this.contactIdByEmail.put(contact.Email, contact.Id);
            }
            
            if(this.Emails.size() > 0){
                if(this.facture.GenerateFactureEN__c){
                    // Specify the subject line for your email address.
                    this.Subject = 'XLSTAT Orders report ' + this.facture.PeriodeEN__c;
                    
                    // Specify the text content of the email.
                    this.Body = 'Dear Sirs,\n\nPlease find below the list of your XLSTAT orders for the period ' + this.facture.PeriodeEN__c + '.\nSo that we can send you the invoice please confirm the total amount calculated on our side.\nMany thanks.\n\nRegards,\nThe XLSTAT sales team';
                }else{
                    // Specify the subject line for your email address.
                    this.Subject = 'XLSTAT Rapport de commandes ' + this.facture.Periode__c;
                    
                    // Specify the text content of the email.
                    this.Body = 'Bonjour,\n\nVeuillez trouver ci-dessous la liste de vos ventes XLSTAT pour la période ' + this.facture.Periode__c + '.\nAfin que nous puissions vous envoyer votre facture, merci de nous confirmer le montant total calculé sur notre système.\nMerci.\n\nCordialement,\nL\'équipe de ventes d\'XLSTAT';
                }
                
                this.HTML = '<style type="text/css">table#orders{border-collapse: collapse;font-family: Arial,Helvetica,sans-serif;font-size:12px;}table#orders th{background-color: #eee;border: 1px solid #fff;border-top-color:#eee;text-align:left;}table#orders th:first-child{border-left-color:#eee;}table#orders th:last-child{border-right-color:#eee;}table#orders td{border: 1px solid #eee;}table#orders td, table#orders th{padding: 8px;vertical-align:middle;}table#orders td.align-right{text-align: right;}table#orders td.border-none{border: none;}table#orders td.bold{font-weight: bold;}</style><br/><table id="orders"><tr>';
                if(this.facture.GenerateFactureEN__c){
                    this.HTML += '<th>Order number</th><th>Purchase-order reference</th><th>Date of purchase</th><th>End-user</th><th>Keys</th><th>Total amount</th><th>Total amount (after discount)</th></tr>';
                }else{
                    this.HTML += '<th>Numéro de commande</th><th>Réf. Bon de commande</th><th>Date d\'achat</th><th>Client final</th><th>Clés</th><th>Montant total</th><th>Montant total (Apres remises)</th></tr>';                
                }
                
                String styleClass = '';
                String styleClassAlignRight = 'align-right';
                String styleBorderNone = 'border-none';
                String styleClassBold = 'bold';
                for(Order order : orders){
                    this.HTML += '<tr>';
                    this.HTML += this.addValueToTableColumn(order.OrderNumber, styleClass);
                    String refBonDeCommande = order.R_f_Bon_de_commande__c == null ? '' : order.R_f_Bon_de_commande__c;
                    this.HTML += this.addValueToTableColumn(refBonDeCommande, styleClass);
                    this.HTML += this.addValueToTableColumn(order.EffectiveDate.format(), styleClass);
                    String accountPro = order.AccountPro__r.Name == null ? '' : order.AccountPro__r.Name;
                    this.HTML += this.addValueToTableColumn(accountPro, styleClass);
                    this.HTML += '<td>&nbsp;</td>';
                    Decimal amountVolume;
                    String amountVolumeStr;
                    if(this.facture.CurrencyIsoCode == 'EUR'){
                        amountVolume= order.TotalAmountVolumeEUR__c;
                    }else if(this.facture.CurrencyIsoCode == 'USD'){
                        amountVolume= order.TotalAmountVolumeUSD__c;
                    }else if(this.facture.CurrencyIsoCode == 'JPY'){
                        amountVolume= order.TotalAmountVolumeJPY__c;
                    }else if(this.facture.CurrencyIsoCode == 'GBP'){
                        amountVolume= order.TotalAmountVolumeGBP__c;
                    }
                    if(amountVolume == null) amountVolume = 0;
                    amountVolumeStr= String.valueOf(amountVolume.setScale(2));
                    amountVolumeStr+= ' ' + this.facture.CurrencyIsoCode;
                    this.HTML += this.addValueToTableColumn(amountVolumeStr, styleClassAlignRight);
                    Decimal amount;
                    String amountStr;
                    if(this.facture.CurrencyIsoCode == 'EUR') amount = order.TotalAmountAfterDiscountEUR__c;
                    else if(this.facture.CurrencyIsoCode == 'USD') amount = order.TotalAmountAfterDiscountUSD__c;
                    else if(this.facture.CurrencyIsoCode == 'JPY') amount = order.TotalAmountAfterDiscountJPY__c;
                    else if(this.facture.CurrencyIsoCode == 'GBP') amount = order.TotalAmountAfterDiscountGBP__c;
                    
                    amountStr = String.valueOf(amount.setScale(2));
                    amountStr += ' ' + this.facture.CurrencyIsoCode;
                    this.HTML += this.addValueToTableColumn(amountStr, styleClassAlignRight);
                    this.HTML += '</tr>';
                } 
                
                if(this.facture.Montant_libre__c > 0 || this.facture.Deduction__c > 0){
                    String ordersAmount = this.facture.GenerateFactureEN__c ? 'Orders amount' : 'Montant total des commandes';
                    this.HTML  += '<tr><td colspan="6" class="' + styleClassAlignRight + ' ' + styleBorderNone + ' ' + styleClassBold + '">' + ordersAmount + '</td>';
                    this.HTML  += this.addValueToTableColumn(String.valueof(this.facture.Montant_commandes_selectionnees__c.setScale(2)) + ' ' + this.facture.CurrencyIsoCode, styleClassAlignRight) + '</tr>';
                }
                if(this.facture.Montant_libre__c > 0){
                    String supplements = this.facture.GenerateFactureEN__c ? 'Supplements' : 'Suppléments';
                    this.HTML += '<tr><td colspan="6" class="' + styleClassAlignRight + ' ' + styleBorderNone + ' ' + styleClassBold + '">' + supplements + '</td>';
                    this.HTML += this.addValueToTableColumn(String.valueof(this.facture.Montant_libre__c.setScale(2)) + ' ' + this.facture.CurrencyIsoCode, styleClassAlignRight) +'</tr>';
                }
                if(this.facture.Deduction__c > 0){
                    String deductions = this.facture.GenerateFactureEN__c ? 'Deductions' : 'Déductions';
                    this.HTML += '<tr><td colspan="6" class="' + styleClassAlignRight + ' ' + styleBorderNone + ' ' + styleClassBold + '">' + deductions + '</td>';
                    this.HTML += this.addValueToTableColumn(String.valueof(this.facture.Deduction__c.setScale(2)) + ' ' + this.facture.CurrencyIsoCode, styleClassAlignRight) + '</tr>';
                }
                String totalAmount = this.facture.GenerateFactureEN__c ? 'Total amount' : 'Montant total';
                this.HTML += '<tr><td colspan="6" class="' + styleClassAlignRight + ' ' + styleBorderNone + ' ' + styleClassBold + '">' + totalAmount + '</td>';
                this.HTML += this.addValueToTableColumn(String.valueof(this.facture.Montant_total_de_la_facture__c.setScale(2)) + ' ' + this.facture.CurrencyIsoCode, styleClassAlignRight);
                this.HTML += '</tr>';
                this.HTML += '</table>';
            }else{
                IsValid = false;ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Aucun contact lié au distributeur.'));                
            }
        }else{
            IsValid = false;ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Aucune commande rattachée à la facture.'));
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
            this.Body = this.Body.replaceAll('\n', '<br/>');
            mail.setHtmlBody(this.Body + '<br/>' + this.HTML);
            
            // Send the email you have created.
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            
            Email__c email = new Email__c();
            email.Facture_distributeur__c = this.facture.Id;
            email.Contact__c = this.contactIdByEmail.get(this.Email);
            email.Subject__c = subject;
            email.Type__c = 'Vérification';
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