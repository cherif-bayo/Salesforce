public class discountController{

    public PageReference exportCSV() {
        return null;
    }


    public PageReference insertPrices() {
        return null;
    }

    public void deleteDiscounts(){
        PricebookEntry[] entries = [select Id, AyPrice__Tiers__c from PricebookEntry where Pricebook2.Id = :selectedPricebook2Id and Product2.Id = :selectedProductId];
        for(PricebookEntry entry : entries){
            entry.AyPrice__Tiers__c = 0;
        }
        
        update entries;
    
        AyPrice__DiscountDetail__c[] discounts = [select Id from AyPrice__DiscountDetail__c where AyPrice__Price_Book_Id__c = :selectedPricebook2Id and AyPrice__Product_Id__c = :selectedProductId limit 500];
        delete discounts;
    }

    public PageReference updatePrices() {
        return null;
    }

    Public String selectedPricebook2Id {get; set;}
    List<AyPrice__DiscountDetail__c> discountDetails;
    public String selectedPricebookId {get; set;}
    public String selectedProductId {get; set;}
    public String selectedDiscountDetailToRemoveId {get; set;}
    public List<WrapperPricebookEntry> pricebookEntries;
    //public List<WrapperProduct> productsToAdd;
    
    public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', ''));
        for(Pricebook2 pr:this.getPricebook2())
        {
            options.add(new SelectOption(pr.id,pr.name));
        }
        return options;
    }
    
    public Pricebook2[] getPricebook2() {
        return [select id, name FROM Pricebook2];
    }
    
    public String getPricebook2ById(String id) {
        Pricebook2[] pricebook = [select id, name FROM Pricebook2 where id=:id];
        if(pricebook.size() == 1){
            return pricebook[0].name;
        }else{
            return '';
        }
    }
    
    public String getSelectedPricebook2Id(){
        return this.getPricebook2ById(this.selectedPricebook2Id);
    }
    
    public void setSelectedPricebook2Id(String selectedPricebook2Id ){
        this.selectedPricebook2Id = selectedPricebook2Id ;
    }
    
    public PageReference choosePricebook() {
        return null;
    }
    
    //public PageReference addProductsChecked(){
    //    for ( Integer i = 0; i < productsToAdd.size(); i++ ) {
    //        if ( productsToAdd[i].checked ) {
    //            Product2 product = productsToAdd[i].p;
    //            PricebookEntry pe = new PricebookEntry();
    //            pe.Product2Id = product.id;
    //            pe.Pricebook2Id = this.selectedPricebook2Id;
    //            pe.UnitPrice = 1.0;
    //            
    //            insert pe;
    //        }
    //    }
    //    return null;
    //}
    
    //public List<WrapperProduct> getProductsToAdd() {
    //    this.productsToAdd = new List<WrapperProduct>();
    //    if(this.selectedPricebook2Id != null){
    //        PricebookEntry[] entries = [select Product2.id FROM PricebookEntry where PriceBook2.id = :this.selectedPricebook2Id];
    //        List<String> productIds = new List<String>();
    //        for(PricebookEntry pe:entries){
    //            productIds.add(pe.Product2.id);
    //        }
    //        for ( Product2 p : [select ProductCode, Name, AyPrice__List_Price__c FROM Product2 where id NOT IN :productIds]) {
    //            this.productsToAdd.add(new WrapperProduct(p));
    //        }
    //    }
    //    return this.productsToAdd;
    //}
    
    public PageReference addProducts() {
        return null;
    }
    
    public List<WrapperPricebookEntry> getPricebookEntries() {
        this.pricebookEntries = new List<WrapperPricebookEntry>();
        for ( PricebookEntry pe : [select Product2.id, Product2.name, UnitPrice, ProductCode, AyPrice__Tiers__c, UseStandardPrice, Pricebook2.id FROM PricebookEntry where PriceBook2.id = :this.selectedPricebook2Id]) {
            if(pe.AyPrice__Tiers__c == null)
                pe.AyPrice__Tiers__c = 0;
            this.pricebookEntries.add(new WrapperPricebookEntry(pe));
        }
        return this.pricebookEntries;
    }
    
    public PageReference deletePricebookEntries() {
        List<PricebookEntry> pricebookEntriesToDelete = new List<PricebookEntry>();
        for ( Integer i = 0; i < this.pricebookEntries.size(); i++ ) {
            if ( this.pricebookEntries[i].checked ) {
                pricebookEntriesToDelete.add(pricebookEntries.remove(i--).pe);
            }
        }
        delete pricebookEntriesToDelete;
        return null;
    }
    
    public PageReference choosePricebookEntry() {
        return null;
    }

    public List<AyPrice__DiscountDetail__c> getDiscountDetails() {
        this.discountDetails = [select id, AyPrice__Discount__c, AyPrice__Price_Book_Id__c, AyPrice__PricebookName__c, 
            AyPrice__Price_List__c, AyPrice__Product_Id__c, AyPrice__Product__c, AyPrice__Range_From__c, 
            AyPrice__Range_To__c, AyPrice__Row_Counter__c, Price_After_Discount__c from AyPrice__DiscountDetail__c 
            where AyPrice__Price_Book_Id__c = :this.selectedPricebookId and AyPrice__Product_Id__c = :this.selectedProductId
            order by AyPrice__Row_Counter__c ];
        return this.discountDetails;
    } 
    
    public void updateDiscountDetails(){
        /*for(AyPrice__DiscountDetail__c dis:this.discountDetails)
        {
            if(dis.AyPrice__Range_To__c == 0.00){
                dis.AyPrice__Range_To__c = null;
            }
            dis.AyPrice__Discount__c = this.isPercentage(dis.AyPrice__Discount__c) ? dis.AyPrice__Discount__c : 0;
        }*/
        update discountDetails;
    }
    
    public PageReference addDiscountDetail(){
        this.updateDiscountDetails();
    
        AyPrice__DiscountDetail__c newDiscountDetail = new AyPrice__DiscountDetail__c();
        newDiscountDetail.AyPrice__Price_Book_Id__c = selectedPricebookId;
        newDiscountDetail.AyPrice__Product_Id__c = selectedProductId;
        newDiscountDetail.AyPrice__Row_Counter__c = this.getMaxRowCounterDiscountDetails() + 1;
        //newDiscountDetail.AyPrice__Discount__c = this.isPercentage(newDiscountDetail.AyPrice__Discount__c) ? newDiscountDetail.AyPrice__Discount__c : 0;
        newDiscountDetail.Price_After_Discount__c = newDiscountDetail.AyPrice__Discount__c != null ? newDiscountDetail.AyPrice__Discount__c : 0;
        insert newDiscountDetail;
        return null;
    }
    
    public PageReference removeDiscountDetail(){
        AyPrice__DiscountDetail__c discountDetail = this.findDiscountDetailById(this.selectedDiscountDetailToRemoveId);
        PricebookEntry pricebookEntry = this.findPricebookEntryByProductIdAndPricebookId(discountDetail.AyPrice__Product_Id__c  ,discountDetail.AyPrice__Price_Book_Id__c);
        pricebookEntry.AyPrice__Tiers__c  = pricebookEntry.AyPrice__Tiers__c - 1;
        update pricebookEntry;
        delete this.findDiscountDetailById(this.selectedDiscountDetailToRemoveId);
        return null;
    }
    
    public PricebookEntry findPricebookEntryByProductIdAndPricebookId(String productId, String pricebookId) {
        return [select id, AyPrice__Tiers__c FROM PricebookEntry where Product2.id = :productId and Pricebook2.id = :pricebookId][0];
    }
    
    public PageReference generateCSV(){
        return null;
    }
    
    private double getMaxRowCounterDiscountDetails(){
        Integer size = this.discountDetails.size();
        if(size > 0){
            size = size - 1;
            return this.discountDetails[size].AyPrice__Row_Counter__c;
        }else{
            return 0;
        }
    }
    
    private AyPrice__DiscountDetail__c findDiscountDetailById(String id){
        return [select id, AyPrice__Price_Book_Id__c, AyPrice__Product_Id__c from AyPrice__DiscountDetail__c where id = :id];
    }
    
    public Boolean isPercentage(Decimal textToTest){
        return textToTest <= 100 && textToTest >= 0;
    }
    
    public void deletePricebookEntriesNotGoodCurrencyByPricebookEntryId(){
        Pricebook2 pricebook = [select Name from Pricebook2 where Id = :this.selectedPricebook2Id limit 1];
        String currencyISO = '';
        
        if(pricebook.Name.contains('EUR')){
            currencyISO = 'EUR';
        }else if(pricebook.Name.contains('USD')){
            currencyISO = 'USD';
        }else if(pricebook.Name.contains('JPY')){
            currencyISO = 'JPY';
        }else if(pricebook.Name.contains('GBP')){
            currencyISO = 'GBP';
        }
        
        PricebookEntry[] pe = [select Id from PricebookEntry where Pricebook2.Id = :this.selectedPricebook2Id and CurrencyIsoCode <> :currencyISO];
        
        List<String> peIds = new List<String>();
        for(PricebookEntry pricebookEntry : pe){
            peIds.add(pricebookEntry.Id);    
        }
        
        List<OrderItem> oi = [select Id from OrderItem where PricebookEntry.Id in :peIds];
        delete oi;
        
        delete pe;
    }
}