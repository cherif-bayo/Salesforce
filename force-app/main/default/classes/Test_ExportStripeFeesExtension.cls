@isTest
public class Test_ExportStripeFeesExtension {
    
    @testSetup
    public static void setUp() {
        Stripe_Payouts__c p = new Stripe_Payouts__c();        
        insert p;
        
        StripeReconciliation__c r = new StripeReconciliation__c();
        r.Created_UTC__c = DateTime.now();
        r.Description__c = 'desc';
        r.customer_facing_amount__c = 47.25;
        r.customer_facing_currency__c = 'eur';
        r.gross__c = 43;
        r.fee__c = 2;
        r.net__c = 41;
        r.Stripe_Payouts__c = p.Id;     
        r.reporting_category__c = 'fee';
        insert r;
    }
    
    @isTest
    public static void mainTest() {		
        stripe_payouts__c p = [Select Id from Stripe_Payouts__c limit 1];
        Test.setCurrentPage(Page.ExportStripeFees);
        ExportStripeFeesExtension page = new ExportStripeFeesExtension (new ApexPages.StandardController(p));		
        page.exportToExcel();
    }
}