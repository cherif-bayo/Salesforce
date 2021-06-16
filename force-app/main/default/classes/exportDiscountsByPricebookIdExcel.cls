public class exportDiscountsByPricebookIdExcel {
    public class WrapperDiscount{
        public String Id {get;set;}
        public Decimal RowCounter {get;set;}
        public Decimal RangeFrom{get;set;}
        public Decimal RangeTo{get;set;}
        public String ProductCode {get; set;}
        public Decimal Discount {get; set;}
    }
   
    public string header{get;set;}
    public List<WrapperDiscount> lstwrapper {get; set;}
    public List<List<WrapperDiscount>> listLstWrapper {get; set;}
   
    public string Filetype{get;set;}
    
    public String PricebookName{get; set;}
    
    public exportDiscountsByPricebookIdExcel(){
            Filetype = '';
            lstwrapper = new List<WrapperDiscount>();
            header = 'sep=,\rId, Row Counter, From, To, Product Code, Discount';
            header += '\r';    
    }
   
    public void exportToExcel(){
        String pricebookId = ApexPages.currentPage().getParameters().get('pricebookId');
        if(pricebookId == null){
            pricebookId = [select Id from Pricebook2 where isStandard = false limit 1].Id;
        }
        PricebookName = [select Name from Pricebook2 where Id = :pricebookId].Name;
        
        String likeQuery = '%EDU%';    
        AyPrice__DiscountDetail__c[] discounts  = [select Id, AyPrice__Range_From__c, AyPrice__Range_To__c, AyPrice__Row_Counter__c, AyPrice__Product_Id__r.ProductCode, AyPrice__Product_Id__r.IsActive, Price_After_Discount__c  from AyPrice__DiscountDetail__c where AyPrice__Price_Book_Id__c = :pricebookId and AyPrice__Product_Id__r.ProductCode like :likeQuery and AyPrice__Product_Id__r.IsActive = true order by AyPrice__Product_Id__r.ProductCode, AyPrice__Range_From__c];
    
        this.listLstWrapper = new List<List<WrapperDiscount>>();        
        for(AyPrice__DiscountDetail__c discount : discounts){
            WrapperDiscount w = new WrapperDiscount();
            w.ProductCode = discount.AyPrice__Product_Id__r.ProductCode;
            w.Id = discount.Id;
            w.RowCounter = discount.AyPrice__Row_Counter__c;
            w.RangeFrom = discount.AyPrice__Range_From__c;
            w.RangeTo = discount.AyPrice__Range_To__c;
            w.Discount  = discount.Price_After_Discount__c;
            this.lstwrapper.add(w);
            
            if(this.lstwrapper.size() == 1000){
                this.listLstWrapper.add(this.lstWrapper);
                this.lstWrapper = new List<WrapperDiscount>();
            }
        }
        
        this.listLstWrapper.add(this.lstwrapper);
    }
}