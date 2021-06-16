public class ExportStripeFeesExtension {    
    
    public class Row {     
        public DateTime Created_UTC  {get; set;}        
        public String description {get; set;}
        public Decimal customer_facing_amount {get; set;}
        public String customer_facing_currency {get; set;}
        public Decimal gross {get; set;}
        public Decimal fee {get; set;}
        public Decimal net {get; set;}
    }

    
    public List<Row> rows {get; set;}    
    public string header{get;set;}
    private static String FEES_TYPE_NAME = 'fee';
    private String idPayout;
    
    public ExportStripeFeesExtension(ApexPages.StandardController stdController){
        idPayout = stdController.getId();
        rows = new List<Row>();    
        header = 'Date de Creation;Description;Montant Hors Frais (euro);Frais (euro);Montant Net (euro)\r';                     
    }
    
    public void exportToExcel(){
   		List<StripeReconciliation__c> conciliations = [select Created_UTC__c,Description__c,gross__c,fee__c,net__c 
                                                       from StripeReconciliation__c where Stripe_Payouts__r.Id = :idPayout and reporting_category__c= :FEES_TYPE_NAME];
    	
        for (StripeReconciliation__c c :conciliations) {
            Row r = new Row();
            r.Created_UTC = c.Created_UTC__c;
            r.Description = c.Description__c;
            r.gross = c.gross__c;
            r.fee = c.fee__c;
            r.net = C.net__c;
            
            rows.add(r);
        }
    }
}