public class ExportStripeInvoicesExtension {

        public class Row {     
        public DateTime Created_UTC  {get; set;}        
        public Decimal customer_facing_amount {get; set;}
        public String customer_facing_currency {get; set;}
        public Decimal gross {get; set;}
        public Decimal fee {get; set;}
        public Decimal net {get; set;}
		public String factures {get; set;}
        public String orderNumber {get; set;}
		public String numoJPA {get; set;}        
    }
    
    
    public List<Row> rows {get; set;}    
    public string header{get;set;}
    private static String CREDIT_NOTE_TYPE_NAME = 'charge';
    private String idPayout;
    
    public ExportStripeInvoicesExtension(ApexPages.StandardController stdController){
        idPayout = stdController.getId();
        rows = new List<Row>();    
        header = 'Date de Creation;Montant Client;Devise Client;Montant Hors Frais (euro);Frais (euro);Montant Net (euro);Numero Facture;Numero Commande;Numero JPA\r';                      
    }
    
    public void exportToExcel(){
        List<StripeReconciliation__c> conciliations = [select Created_UTC__c,customer_facing_amount__c,customer_facing_currency__c,gross__c,fee__c,net__c,factures__c,Order__r.OrderNumber ,numoJPA__c 
                                                       from StripeReconciliation__c where Stripe_Payouts__r.Id = :idPayout and reporting_category__c= :CREDIT_NOTE_TYPE_NAME];
        
        for (StripeReconciliation__c c :conciliations) {
            Row r = new Row();
            r.Created_UTC = c.Created_UTC__c;
            r.customer_facing_amount = c.customer_facing_amount__c;
            r.customer_facing_currency = c.customer_facing_currency__c;
            r.gross = c.gross__c;
            r.fee = c.fee__c;
            r.net = C.net__c;   
            r.orderNumber = c.Order__r.OrderNumber;
            r.factures = c.factures__c; 
            r.numoJPA = c.numoJPA__c;
            
            rows.add(r);
        }
    }
    
}