public class OrderRenewExtension {
    private final static String VALUE_BON = 'BON';
    private final static String VALUE_SHAREIT = 'SHAREIT';        
    private final static String KEY_EXPIRING = 'Expiring';  

    private final Order order;
    
    public Boolean GenerateKeys {get; set;}
    public Order NewOrder {get; private set;}
    public String Provenance {get; set;}
    
    public List<SelectOption> getProvenances() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption(VALUE_BON,'Bon de commande'));
        options.add(new SelectOption(VALUE_SHAREIT,'ShareIt'));
        return options;
    }
    
    public Boolean getRenderRefBonCommande(){
        return this.Provenance == VALUE_BON;
    }
    public Boolean getRenderRefShareIt(){
        return this.Provenance == VALUE_SHAREIT;
    }    

    public OrderRenewExtension (ApexPages.StandardController standardController){
        Id currentOrderId = standardController.getId();
        this.order = [SELECT CurrencyIsoCode, Pricebook2Id, (SELECT Contact__r.FirstName, Contact__r.LastName, Contact__r.Email, Contact__r.MailingCountryCode, 
                                                             Name, Order__c, Expiration__c, Nb_activations_allowed__c, Domaine_utilisateur__c, Type_licence__c, 
                                                             Date_Limite__c, XLSTAT_Solution__c, XLSTAT_Options__c, Account__c,Entitlement_Id__c FROM Cles_Flexera__r), 
                      (SELECT OrderId FROM OrderItems), AccountId, Contact_Lie__c, Client_Final__c, BillingCity, BillingPostalCode, BillingCountryCode, 
                      BillingStreet, BillingStateCode, Provenance_d_affiliation__c, Provenance_du_site_web__c, Discount_Coupon_Activated__c, 
                      Discount_Manuel_Activated__c, Discount_Client_Activated__c, Discount_Manuel__c FROM Order WHERE Id = :currentOrderId];
        
        this.NewOrder = new Order();
        this.NewOrder.AccountId = this.order.AccountId;
        this.NewOrder.Contact_Lie__c = this.order.Contact_Lie__c;
        this.NewOrder.Client_Final__c = this.order.Client_Final__c;
        this.NewOrder.BillingCity = this.order.BillingCity;
        this.NewOrder.BillingPostalCode = this.order.BillingPostalCode;
        this.NewOrder.BillingCountryCode = this.order.BillingCountryCode;
        this.NewOrder.BillingStreet = this.order.BillingStreet;    
        this.NewOrder.BillingStateCode = this.order.BillingStateCode;    
        this.NewOrder.Provenance_d_affiliation__c = this.order.Provenance_d_affiliation__c;    
        this.NewOrder.Provenance_du_site_web__c = this.order.Provenance_du_site_web__c;    
        this.NewOrder.Discount_Coupon_Activated__c = this.order.Discount_Coupon_Activated__c;  
        this.NewOrder.Discount_Manuel_Activated__c = this.order.Discount_Manuel_Activated__c;  
        this.NewOrder.Discount_Client_Activated__c = this.order.Discount_Client_Activated__c;  
        this.NewOrder.Discount_Manuel__c = this.order.Discount_Manuel__c;
        this.NewOrder.Pricebook2Id = this.order.Pricebook2Id;
        this.NewOrder.EffectiveDate = Date.today();
        this.NewOrder.Status = 'Version préliminaire';
        this.NewOrder.CurrencyIsoCode = this.order.CurrencyIsoCode;
        this.NewOrder.CustomOriginalOrder__c = currentOrderId;
        this.GenerateKeys = true;
        this.Provenance = VALUE_BON;                                                                     
    }
    
    public PageReference CustomRenew(){
        Boolean allKeysGenerated = true;
        List<Flexera_Key__c> newKeys = new List<Flexera_Key__c>();
        if(this.GenerateKeys == true){
            for(Flexera_Key__c key : this.order.Cles_Flexera__r){
                sObject originalSObject = (sObject) key;
                List<sObject> originalSObjects = new List<sObject>{originalSObject};
                List<sObject> clonedSObjects = SObjectAllFieldCloner.cloneObjects(originalSobjects, originalSobject.getsObjectType());                
                Flexera_Key__c newKey = (Flexera_Key__c)clonedSObjects.get(0);
                newKey.Date_Limite__c = Date.today().addYears(1);
                
                if(key.Expiration__c == KEY_EXPIRING){                
                    FlexeraController.ResultGenerateKey resultGenerateKey = FlexeraController.Generate(1, newKey, key.Contact__r.FirstName, key.Contact__r.LastName, key.Contact__r.Email, key.Contact__r.MailingCountryCode, null);
                    
                    if(resultGenerateKey.Status == true){
                        for(Flexera_Key__c generatedKey : resultGenerateKey.GeneratedKeys){
                            newKeys.add(generatedKey);
                        }
                    }else{
                        allKeysGenerated = false;
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Une erreur est survenue pendant la génération de la clef: '+key.Name+'+ depuis Flexera.'));
                        break;
                    }
                }else{
                    Boolean resultUpdate = FlexeraController.UpdateKey(key, newKey);
                    
                    if(resultUpdate == true){
                        newKeys.add(newKey);
                    }else{
                        allKeysGenerated = false;
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Une erreur est survenue pendant la mise à jour de la clef: '+key.Name+'+ depuis Flexera.'));
                        break;
                    }
                }
            }
        }
            
        if(allKeysGenerated == true){
            String provenanceValue;
            for(SelectOption selectOption : this.getProvenances()){
                if(selectOption.getValue() == this.Provenance){
                    provenanceValue = selectOption.getLabel();
                    break;
                }
            }
            this.NewOrder.Provenance__c = provenanceValue;
            
            insert this.NewOrder;
            
            List<OrderItem> newOrderItems = new List<OrderItem>();
            for(OrderItem orderItem : this.order.OrderItems){
                sObject originalSObject = (sObject) orderItem;
                List<sObject> originalSObjects = new List<sObject>{originalSObject};
                List<sObject> clonedSObjects = SObjectAllFieldCloner.cloneObjects(originalSobjects, originalSobject.getsObjectType());                
                OrderItem newOrderItem = (OrderItem)clonedSObjects.get(0);
    
                newOrderItem.OrderId = this.NewOrder.Id;
                
                newOrderItems.add(newOrderItem);
            }
            insert newOrderItems;
        
            for(Flexera_Key__c newKey : newKeys){
                newKey.Order__c = this.NewOrder.Id;
            }
            insert newKeys;
        
            PageReference pageRef = new PageReference('/' + this.NewOrder.Id);
            pageRef.setRedirect(true);
            return pageRef;
        }
        
        return null;
    }
}