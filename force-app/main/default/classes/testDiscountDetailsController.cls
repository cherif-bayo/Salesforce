@isTest (SeeAllData=true)

public class testDiscountDetailsController{
    public static testMethod void testGetItems() {
        discountController testController = new discountController();
    
        Pricebook2[] pricebooks = [select id, name FROM Pricebook2];
        
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', ''));
        for(Pricebook2 pr:pricebooks)
        {
            options.add(new SelectOption(pr.id,pr.name));
        }
        
        System.assertEquals(options, testController.getItems());
    }
    
    public static testMethod void testGetPricebook2ById() {
        Pricebook2[] pricebooks = [select id, name FROM Pricebook2];
        
        if(pricebooks.size() > 0){
            Pricebook2 pricebook = pricebooks[0];
            discountController testController = new discountController();
            String pricebookNameController = testController.getPricebook2ById(pricebook.id);   
            
            System.assertEquals(pricebook.name, pricebookNameController);
        }
    }
    
    public static testMethod void testSelectedPricebook() {
        Pricebook2[] pricebooks = [select id, name FROM Pricebook2];
        
        if(pricebooks.size() > 0){
            Pricebook2 pricebook = pricebooks[0];
        
            discountController testController = new discountController();
            testController.setSelectedPricebook2Id(pricebook.id);
            String pricebookNameController = testController.getSelectedPricebook2Id();   
            
            System.assertEquals(pricebook.name, pricebookNameController);
        }
    }
    
    public static testMethod void testGetPricebookEntries() {
        discountController testController = new discountController();
        String selectedPricebookId = '';
        testController.selectedPricebookId = selectedPricebookId;
        List<WrapperPricebookEntry> pricebookEntries = new List<WrapperPricebookEntry>();
        for ( PricebookEntry pe : [select Product2.id, Product2.name, UnitPrice, ProductCode, AyPrice__Tiers__c, UseStandardPrice, Pricebook2.id FROM PricebookEntry where PriceBook2.id = :selectedPricebookId]) {
            if(pe.AyPrice__Tiers__c == null)
                pe.AyPrice__Tiers__c = 0;
            pricebookEntries.add(new WrapperPricebookEntry(pe));
        }
        System.assertEquals(pricebookEntries, testController.getPricebookEntries());
    }
    
    public static testMethod void testGetDiscountDetails() {
        discountController testController = new discountController();
        String selectedPricebookId = '';
        String selectedProductId = '';
        testController.selectedPricebookId = selectedPricebookId;
        testController.selectedProductId = selectedProductId; 
        AyPrice__DiscountDetail__c[] discountDetails = [select id, AyPrice__Discount__c, AyPrice__Price_Book_Id__c, AyPrice__PricebookName__c, 
            AyPrice__Price_List__c, AyPrice__Product_Id__c, AyPrice__Product__c, AyPrice__Range_From__c, 
            AyPrice__Range_To__c, AyPrice__Row_Counter__c from AyPrice__DiscountDetail__c 
            where AyPrice__Price_Book_Id__c = :selectedPricebookId and AyPrice__Product_Id__c = :selectedProductId
            order by AyPrice__Row_Counter__c ];
            
        System.assertEquals(discountDetails, testController.getDiscountDetails());
    }
    
    public static testMethod void testUpdateDiscountDetails() {
        discountController testController = new discountController();
        String selectedPricebookId = '';
        String selectedProductId = '';
        testController.selectedPricebookId = selectedPricebookId;
        testController.selectedProductId = selectedProductId; 
        List<AyPrice__DiscountDetail__c> discountDetails = testController.getDiscountDetails();
        
        for(AyPrice__DiscountDetail__c dis:discountDetails)
        {
            if(dis.AyPrice__Range_To__c == 0.00){
                dis.AyPrice__Range_To__c = null;
            }
            dis.AyPrice__Discount__c = testController.isPercentage(dis.AyPrice__Discount__c) ? dis.AyPrice__Discount__c : 0;
        }
        
        testController.updateDiscountDetails();
        System.assertEquals(discountDetails, testController.getDiscountDetails());
    }
    
    public static testMethod void testAddDiscountDetail() {
        discountController testController = new discountController();
        
        Pricebook2[] pricebooks = [select id, name FROM Pricebook2];
        testController.selectedPricebook2Id = pricebooks[0].id;
        List<WrapperPricebookEntry> pricebookEntries = testController.getPricebookEntries();
        testController.selectedPricebookId = pricebookEntries[0].pe.Pricebook2.id;
        testController.selectedProductId = pricebookEntries[0].pe.Product2.id; 
        List<AyPrice__DiscountDetail__c> discountDetails = testController.getDiscountDetails();
        
        testController.addDiscountDetail();
        
        List<AyPrice__DiscountDetail__c> newListDiscountDetails = testController.getDiscountDetails();
        
        System.assertEquals(discountDetails.size() + 1, newListDiscountDetails.size());
    }
    
    public static testMethod void testRemoveDiscountDetails(){
        discountController testController = new discountController();
        
        Pricebook2[] pricebooks = [select id, name FROM Pricebook2];
        testController.selectedPricebook2Id = pricebooks[0].id;
        List<WrapperPricebookEntry> pricebookEntries = testController.getPricebookEntries();
        testController.selectedPricebookId = pricebookEntries[0].pe.Pricebook2.id;
        testController.selectedProductId = pricebookEntries[0].pe.Product2.id; 
        List<AyPrice__DiscountDetail__c> discountDetails = testController.getDiscountDetails();
        testController.addDiscountDetail();
        discountDetails = testController.getDiscountDetails();
        
        testController.selectedDiscountDetailToRemoveId = discountDetails[0].id;
        testController.removeDiscountDetail();
        List<AyPrice__DiscountDetail__c> newDiscountDetails = testController.getDiscountDetails();
        
        System.assertEquals(discountDetails.size() - 1, newDiscountDetails.size());
    }
    
    public static testMethod void testRemovePricebookEntries(){
        discountController testController = new discountController();
        
        List<WrapperPricebookEntry> entries = testController.getPricebookEntries();
        testController.deletePricebookEntries();
        List<WrapperPricebookEntry> newEntries = testController.getPricebookEntries();
        
        System.assertEquals(entries.size(), newEntries.size());
    }
    
    public static testMethod void testAll(){
        discountController testController = new discountController();
        testController.insertPrices();
        testController.deleteDiscounts();
        testController.updatePrices();
        testController.choosePricebook();
        testController.addProducts();
        testController.choosePricebookEntry();
    }
}