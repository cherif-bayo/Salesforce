public class AddOrderToDistribFacture{
    private Facture_distributeur__c facture;

    public class WrapperOrder{
        public Boolean IsChecked {get; set;}
        public Order Order {get; set;}
    }
    public List<WrapperOrder> WrapperOrders { get; set; }
    Public String IdFacture {get; set;}
    
    public void Initialize(){
        Facture_distributeur__c[] factures = [SELECT Id, Compte_lie__c FROM Facture_distributeur__c WHERE Id = :this.IdFacture limit 1];
            
        if(factures.size() > 0){
            this.facture = factures[0];
        }
        
        if(this.facture != null){
            this.WrapperOrders = new List<WrapperOrder>();
            for(Order order : [SELECT Id, OrderNumber, EffectiveDate, Status, Ref_Facture_distributeur__c, Client_final__r.Id, Client_final__r.Name, Client_final_email__c, TotalAmountAfterDiscountWithCurrency__c, Provenance__c FROM Order WHERE AccountId = :facture.Compte_lie__c AND Status != 'Payée' AND Ref_Facture_distributeur__c = null ORDER BY EffectiveDate DESC]){
                WrapperOrder wrapperOrder = new WrapperOrder();
                wrapperOrder.Order = order;
                wrapperOrder.IsChecked = true;
                this.WrapperOrders.add(wrapperOrder);
            }
        }else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Une erreur s\'est produite. Veuillez contacter votre super collègue Martin !'));
        }
    }

    public AddOrderToDistribFacture(){        
        this.IdFacture = ApexPages.currentPage().getParameters().get('id');
        
        if(this.IdFacture != null){
            this.Initialize();
        }
    }
    
    public PageReference AddOrders(){
        List<Order> ordersToUpdate = new List<Order>();
    
        for(WrapperOrder wrapperOrder : this.WrapperOrders){
            if(wrapperOrder.IsChecked){
                wrapperOrder.Order.Ref_Facture_distributeur__c = this.facture.Id;
                
                ordersToUpdate.add(wrapperOrder.Order);
            }
        }
        
		System.debug('[AddOrderToDistribFacture] AddOrders ordersToUpdate='+ordersToUpdate);
        if(ordersToUpdate.size() > 0){            
			try {
				update ordersToUpdate;
        
				PageReference pageRef = new PageREference('/' + this.facture.Id);
				pageRef.setRedirect(true);
				return pageRef;
			} catch (Exception e) { ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));}
        }else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Vous n\'avez sélectionné aucune commande à ajouter.'));
        }
        
        return null;
    }
    
    public void SelectAlll(){
        for(WrapperOrder wrapperOrder : this.WrapperOrders){
            wrapperOrder.IsChecked = true;
        }
    }
    
    public void DeSelectAlll(){
        for(WrapperOrder wrapperOrder : this.WrapperOrders){
            wrapperOrder.IsChecked = false;
        }
    }
    
    public PageReference Cancel(){
        PageReference pageRef = new PageREference('/' + this.facture.Id);
        pageRef.setRedirect(true);
        return pageRef;
    }
}