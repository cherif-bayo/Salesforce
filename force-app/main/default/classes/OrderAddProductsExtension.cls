public with sharing class OrderAddProductsExtension
{    
    private static Map<String, String> orderDomainToProductDomain = new Map<String, String>{ 'Company' => 'Entreprise/Privé', 'Academic' => 'Education', 'Student' => 'Etudiant'};

    public Order Order{get; set;}
    public Account Account{get; set;}
    public List<WrapProductOrderItem> ProductsOrderItems {get; set;}
    public List<SelectOption> LicenceList {get; set;}
    public String OrderDomain {get; set;}
    
    public OrderAddProductsExtension(ApexPages.StandardController standardController)
    {
        this.Order = [select CurrencyIsoCode , Editor_Auto__c, HasDiscount__c , Discount_Manuel__c , EffectiveDate , Type_Licence__c, (SELECT Id, PricebookEntry.Product2Id FROM OrderItems), Id, Domaine_Utilisateur__c, AccountId, Discount_Client_Activated__c, Discount_Client__c, DIscount_Coupon__c, Ref_du_coupon__c from Order where Id = :standardController.getId() limit 1];
        this.Account = [SELECT Id, Type, Discount_global__c FROM Account WHERE Id = :this.Order.AccountId];
        
        Map<Id, Id> productsIdsByOrderItemId = new Map<Id, Id>();
        for(OrderItem orderItem : this.Order.OrderItems){
            productsIdsByOrderItemId.put(orderItem.Id, orderItem.PricebookEntry.Product2Id);
        }
        
        Map<Id, Product2> productsById = new Map<Id, Product2>([SELECT Id, Name, Domaine_Utilisateur__c, Domaine_utilisateur_en__c, Type_licence_desc_EN__c  FROM Product2 WHERE Id in :productsIdsByOrderItemId.values()]);
        
        Map<Id, OrderItem> orderItemById = new Map<Id, OrderItem>([SELECT Id, OrderId, PricebookEntryId, Quantity, UnitPrice, Total_Price_After_Discount__c, Unit_Price_Catalogue__c, Unit_Price_Discount_Volume__c, Percent_Discount_Client__c, Percent_Discount_Coupon__c, Percent_Discount_Manuel__c, Percent_Discount_Total__c  FROM OrderItem WHERE Id in :productsIdsByOrderItemId.keySet()]);
        
        Integer counter = 0;
        ProductsOrderItems  = new List<WrapProductOrderItem>();
        for(Id orderItemId : orderItemById.keySet()){
            WrapProductOrderItem wrap = new WrapProductOrderItem(productsById.get(productsIdsByOrderItemId.get(orderItemId)), orderItemById.get(orderItemId), counter);
            
            ProductsOrderItems.add(wrap);
            
            counter++;
        }
        
        this.OrderDomain = orderDomainToProductDomain.containsKey(this.Order.Domaine_Utilisateur__c) ? orderDomainToProductDomain.get(this.Order.Domaine_Utilisateur__c) : this.Order.Domaine_Utilisateur__c;
        
        List<Product2> Licences = [SELECT Type_licence__c, Type_licence_desc_EN__c FROM Product2 WHERE Domaine_utilisateur__c = :this.OrderDomain];

        List<SelectOption> LicenceOptionList = new List<SelectOption>();
        Set<String> sNamesLicence = New Set<String>();
        LicenceOptionList.add(new SelectOption('-----Select Licence-----', '-----Select Licence-----'));
        for(Product2 licence : Licences)
        {
            if(sNamesLicence.Contains(licence.Type_licence__c) == FALSE){
            
                sNamesLicence.add(licence.Type_licence__c);
                
                LicenceOptionList.add(new SelectOption(licence.Type_licence__c, licence.Type_licence_desc_EN__c));
            }
        }
        
        this.LicenceList = LicenceOptionList;
    }
}