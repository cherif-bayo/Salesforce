public class AvoirToOrderController{
    private String orderId;

    public Avoir__c Avoir {get; private set;}
    public Boolean NoError {get; private set;}

    public AvoirToOrderController() {
        this.Avoir = new Avoir__c();
        this.NoError = true;
        
        this.orderId = ApexPages.CurrentPage().getParameters().get('order_id');
        
        if(this.orderId != null){
            Order order = [SELECT CurrencyIsoCode, TotalAmountAfterDiscountShowed__c, R_f_Facture__c, Ref_Facture_distributeur__c FROM Order WHERE Id = :this.orderId];
            
            Facture__c[] facture = [SELECT Id FROM Facture__c WHERE Name = :order.R_f_Facture__c];
            Facture_Distributeur__c[] factureDistributeur = [SELECT Id FROM Facture_Distributeur__c WHERE Name = :order.Ref_Facture_distributeur__c];
        
            this.Avoir.Commande_Lie__c = orderId;
            this.Avoir.Montant__c = order.TotalAmountAfterDiscountShowed__c;
            this.Avoir.Facture_distrib_liee__c = factureDistributeur.size() == 0 ? null : factureDistributeur[0].Id;
            this.Avoir.Facture_liee__c = facture.size() == 0 ? null : facture[0].Id;
            this.Avoir.Impact_Order_Price__c = true;
            this.Avoir.CurrencyIsoCode = order.CurrencyIsoCode;
        }else{
            this.NoError = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Aucune commande à rattacher à l\'avoir.'));
        }
    }
    
    private PageReference redirectToOrder(){
        PageReference pageRef = new PageREference('/' + this.orderId);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public PageReference Cancel(){
        return this.redirectToOrder();
    }
    
    public PageReference Save(){
        insert this.Avoir;
        
        return this.redirectToOrder();
    }
}