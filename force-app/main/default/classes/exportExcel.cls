public class exportExcel {
   
    public string header{get;set;}
    public List<WrapperExportCSV> lstwrapper {get; set;}
    public List<List<WrapperExportCSV>> listLstWrapper {get; set;}
   
    public string Filetype{get;set;}
    
    public exportExcel(){
            Filetype = '';
            lstwrapper = new List<WrapperExportCSV>();
            header = 'sep=,\rRow Counter,Pricebook Id,Pricebook Name,Product Id,Product Code,Range From,Range To,Price After Discount\r';                     
    }
   
    public void exportToExcel(){
        String pricebookId = ApexPages.currentPage().getParameters().get('pricebookId');
        if(pricebookId == null){
            pricebookId = [select Id from Pricebook2 where isStandard = true limit 1].Id;
        }
        
        String pricebookName = [select Name from Pricebook2 where Id = :pricebookId limit 1].Name;
        
        Map<String, String> mapProducts = new Map<String, String>();
        List<Product2> products = [select id, ProductCode from Product2];
        for(Product2 product:products){
            mapProducts.put(product.id, product.ProductCode);
        }
    
        this.listLstWrapper = new List<List<WrapperExportCSV>>();
        
        String queryLike = 'S_%';
        
        for(PricebookEntry entry:[select Pricebook2.id, Product2.id, AyPrice__Tiers__c from PricebookEntry where Pricebook2.id = :pricebookId and Product2.ProductCode like :queryLike order by id]){  
            Integer count = 0;          
            while (count < 30) {
                WrapperExportCSV w = new WrapperExportCSV();
                w.pricebookId = entry.Pricebook2.id;
                w.pricebookName = pricebookName ;
                w.productId = entry.Product2.id;
                w.ProductCode = mapProducts.get(w.productId);
                w.rangeFrom = String.valueof(count + 1);
                if(count != 29){
                    w.rangeTo = String.valueof(count + 1);
                }else{
                    w.discount = null;
                }
                w.rowCounter = String.valueof(count + 1);
                w.discount = 0;
                
                this.lstwrapper.add(w);    
                
                if(this.lstwrapper.size() == 1000){
                      this.listLstWrapper.add(this.lstWrapper);
                      this.lstWrapper = new List<WrapperExportCSV>();
                  }
                
                count++;
            }
        }
    }
}