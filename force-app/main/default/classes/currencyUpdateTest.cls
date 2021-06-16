@isTest
public class currencyUpdateTest {
    
    @isTest
    public static void mainTest(){
        
        Account acc = new Account();
        acc.Type ='Client';
        acc.Name ='TestCurrencyUpdate';
        acc.Domaine_utilisateur__c='Comapny';
        
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name='currencyOpportunity';
        opp.AccountId= acc.Id;
        opp.Type='Test';
        opp.CurrencyIsoCode='USD';
        opp.CloseDate= Date.today().addDays(30);
        opp.StageName='Proposition/Devis';
        
        insert opp;
        
        List<Opportunity> opps = [SELECT Id, Name, AccountId, Type, CurrencyIsoCode, CloseDate, StageName FROM Opportunity WHERE Name='currencyOpportunity' AND CurrencyIsoCode='USD'];
        System.assertEquals(1, opps.size());
    }
}