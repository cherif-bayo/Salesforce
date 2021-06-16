public class exportDiscountsExcel {
    public class WrapperDiscount{
        public String ProductCode {get; set;}
        public List<String> Discounts {get; set;}
    }
   
    public string header{get;set;}
    public List<WrapperDiscount> lstwrapper {get; set;}
    public List<List<WrapperDiscount>> listLstWrapper {get; set;}
   
    public string Filetype{get;set;}
    
    public String PricebookName{get; set;}
    
    public exportDiscountsExcel(){
            Filetype = '';
            lstwrapper = new List<WrapperDiscount>();
            header = 'sep=,\rProduct Code';
            for(Integer i = 0; i < 30; i++){
                header += ',';
            }                 
            header += '\r';    
    }
   
    public void exportToExcel(){
        String pricebookId = ApexPages.currentPage().getParameters().get('pricebookId');
        if(pricebookId == null){
            pricebookId = [select Id from Pricebook2 where isStandard = false limit 1].Id;
        }
        PricebookName = [select Name from Pricebook2 where Id = :pricebookId].Name;
        
        String likeQuery = 'S_%';    
        AyPrice__DiscountDetail__c[] discounts  = [select AyPrice__Product_Id__r.ProductCode, Price_After_Discount__c  from AyPrice__DiscountDetail__c where AyPrice__Price_Book_Id__c = :pricebookId and AyPrice__Product_Id__r.ProductCode like :likeQuery order by AyPrice__Product_Id__r.ProductCode, AyPrice__Range_From__c];
    
        this.listLstWrapper = new List<List<WrapperDiscount>>();
        
        Map<String, List<AyPrice__DiscountDetail__c>> discountsByProduct = new Map<String, List<AyPrice__DiscountDetail__c>>();
        for(AyPrice__DiscountDetail__c dd:discounts){        
            if(discountsByProduct.containsKey(dd.AyPrice__Product_Id__r.ProductCode)){
                discountsByProduct.get(dd.AyPrice__Product_Id__r.ProductCode).add(dd);
            }else{
                List<AyPrice__DiscountDetail__c> ldd = new List<AyPrice__DiscountDetail__c>();
                ldd.add(dd);
                discountsByProduct.put(dd.AyPrice__Product_Id__r.ProductCode, ldd);
            }
        }
        
        for(String productCode : discountsByProduct.keySet()){
            List<String> discountsStr = new List<String>();
        
            for(AyPrice__DiscountDetail__c discount : discountsByProduct.get(productCode)){
                discountsStr.add(String.valueof(discount.Price_After_Discount__c));
            }
            
            WrapperDiscount w = new WrapperDiscount();
            w.ProductCode = productCode;
            w.Discounts = discountsStr;
            this.lstwrapper.add(w);
            
            if(this.lstwrapper.size() == 1000){
                this.listLstWrapper.add(this.lstWrapper);
                this.lstWrapper = new List<WrapperDiscount>();
            }
        }
        
        this.listLstWrapper.add(this.lstwrapper);
    }
}