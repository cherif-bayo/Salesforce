public class FlexeraGenerateExtensionCampus{
    private String orderId;
    private String keyId;

    public List<WrapperKey> WrapperKeys {get; set;}

    public class WrapperKey{
        public Flexera_Key__c Key {get; set;}
        public Boolean IsSelected {get; set;}
    }

    public FlexeraGenerateExtensionCampus(){
        this.orderId = ApexPages.currentPage().getParameters().get('order_id');
        this.WrapperKeys = new List<WrapperKey>();
        
        if(this.orderId != null){
            Order order = [SELECT AccountId FROM Order WHERE Id = :orderId];
            
            for(Flexera_Key__c key : [SELECT Id, Contact__r.Name, Is_Network__c, Has_Student_Ext__c, Name, Campaign__c, Order__c, Order__r.OrderNumber, Contact__c, Date_limite__c, Domaine_utilisateur__c, Expiration__c, Modules__c, Nb_activations__c, Nb_activations_allowed__c, Quantity__c, Type_client__c, Type_licence__c, XLSTAT_Options__c, XLSTAT_Solution__c, Version__r.Name, Entitlement_Id__c FROM Flexera_Key__c WHERE Order__r.AccountId = :order.AccountId AND Domaine_Utilisateur__c = 'Campus' AND Has_Student_Ext__c = false]){
                WrapperKey wpKey = new WrapperKey();
                wpKey.Key = key;
                wpKey.IsSelected = false;
                
                this.WrapperKeys.add(wpKey);
            }
        }
    }

    public PageReference Generate(){    
        Flexera_Key__c selectedKey;
        Integer nbSelectedKeys = 0;
        for(WrapperKey wpKey : this.WrapperKeys){
            if(wpKey.IsSelected == true){
                selectedKey = wpKey.Key;
                nbSelectedKeys++;
            }
        }
        
        if(nbSelectedKeys != 1){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Vous ne devez sélectionner qu\'une seule clé.'));
            return null;
        }
        
        Flexera_Key__c keyExtension = selectedKey.clone(false, true);
        keyExtension.Has_Student_Ext__c = true;
        keyExtension.Is_Network__c = false;
        
        Contact contactKey = [SELECT Id, FirstName, LastName, Name, Email, MailingCountryCode FROM Contact WHERE Id = :keyExtension.Contact__c];
        
        FlexeraController.ResultGenerateKey resultGenerateKey = FlexeraController.Generate(1, keyExtension, contactKey);
                
        if(resultGenerateKey.Status == true){
            insert resultGenerateKey.GeneratedKeys;
            
            PageReference pageRef = Page.FlexeraKeyRead;
            pageRef.getParameters().put('id', resultGenerateKey.GeneratedKeys[0].Id);
            pageRef.setRedirect(true);
            
            return pageRef;
        }else{
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Une erreur est survenue pendant la génération de la clef depuis Flexera.'));
        }
        
        return null;
    }
    
    public PageReference Cancel(){
        return new PageReference('/' + this.orderId);
    }
}