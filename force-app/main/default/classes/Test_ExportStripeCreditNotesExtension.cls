@isTest
public class Test_ExportStripeCreditNotesExtension {
    
    @testSetup
    public static void setUp() {
        Stripe_Payouts__c p = new Stripe_Payouts__c();        
        insert p;
        
        StripeReconciliation__c r = new StripeReconciliation__c();
        r.Created_UTC__c = DateTime.now();
        r.customer_facing_amount__c = 47.25;
        r.customer_facing_currency__c = 'eur';
        r.gross__c = 43;
        r.fee__c = 2;
        r.net__c = 41;
        r.Stripe_Payouts__c = p.Id;     
        r.reporting_category__c = 'refund';
        r.avoir__c = 'A-412';
        insert r;
    }
    
    @isTest
    public static void mainTest() {		
        stripe_payouts__c p = [Select Id from Stripe_Payouts__c limit 1];
        Test.setCurrentPage(Page.ExportStripeCreditNotes);
        ExportStripeCreditNotesExtension page = new ExportStripeCreditNotesExtension (new ApexPages.StandardController(p));		
        page.exportToExcel();
    }
}