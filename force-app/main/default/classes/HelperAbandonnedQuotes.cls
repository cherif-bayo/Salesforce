public class HelperAbandonnedQuotes  {
    
    List<Quote> abandonnedQuotes = new List<Quote> ();
    
    public HelperAbandonnedQuotes() {
        
        // Recuperation de la fourchette de date de relance de devis abandonnés
        Integer nbDaysMin = Integer.valueOf(Parameters.getString('Abandonned_Quotes_Day_min'));
        if (Test.isRunningTest()) nbDaysMin = -1; // Pour être independant du parametre custom metadata
        
        Integer nbDaysMax = Integer.valueOf(Parameters.getString('Abandonned_Quotes_Day_Max'));
        if (Test.isRunningTest()) nbDaysMax = 7; // Pour être independant du parametre custom metadata
        
        Integer minPrice = Integer.valueOf(Parameters.getString('Abandonned_Quotes_Price_Min'));
        if (Test.isRunningTest()) minPrice = 50; // Pour être independant du parametre custom metadata
        
        // Recuperation des devis abandonnés
        Date dateMin = DateTime.now().addDays(- nbDaysMin).date();
        Date dateMax = DateTime.now().addDays(- nbDaysMax).date();
        
        // Recuperation des devis abandonnés
        List<Quote> quotes = [SELECT ContactId,CreatedDate FROM Quote WHERE 
                              CreatedDate <= :dateMin
                              and Website_Auto__c = true
                              and CreatedDate >= :dateMax
                              and TotalPrice > : minPrice
                              and Devis_Abandonne_Relance__c = false];
        
        System.debug('[HelperabandonnedQuotes] commandes avec devis abandonné:' + quotes);
        
        // Calcul des Quotes abandonnés à relancer (pas de commande postérieure)
        abandonnedQuotes = HelperCustomer.checkNonPayedQuotes(quotes);
    }
    
    public void markAbonnedQuotesAsCovered() {
        for (Quote q : abandonnedQuotes) q.Devis_Abandonne_Relance__c = true;
        update abandonnedQuotes;
    }
    
    public List<Pardot.Prospect> getProspects() {
        List<Pardot.Prospect> prospects = new List<Pardot.Prospect> ();
        
        List<String> quoteIds = new List<String>();
        for (Quote q :abandonnedQuotes) quoteIds.add(q.Id);
        
        List<Quote> quotes = [SELECT TotalPrice, CurrencyIsoCode, ContactId, CreatedDate,
                              Opportunity.Contact_lie__r.FirstName,
                              Opportunity.Contact_lie__r.LastName,
                              Opportunity.Contact_lie__r.email,
                              Opportunity.Contact_lie__r.Id,
                              (select Product2.Libelle_Devis__c from QuoteLineItems)
                              FROM Quote WHERE Id in :quoteIds];
        
        System.debug('[HelperabandonnedQuotes] devis abandonnés : ' + quotes);
        
        for (Quote q : quotes) {
            Pardot.Prospect prospect = new Pardot.Prospect();
            
            // Concatenation de la liste des produits
            String products = '';
            for (QuoteLineItem  qi :q.QuoteLineItems) {
                products += qi.Product2.Libelle_Devis__c +','; 
                System.debug('[HelperabandonnedQuotes] quoteLineItem: ' + qi + 'Products list: '+ products); 
            }
            prospect.Produit_Panier = products.substringBeforeLast(','); 
            prospect.email = q.Opportunity.Contact_lie__r.Email;
            prospect.Devise_Panier = q.CurrencyIsoCode;		
            prospect.Montant_Panier = q.TotalPrice;
            prospect.first_name = q.Opportunity.Contact_lie__r.FirstName;
            prospect.last_name = q.Opportunity.Contact_lie__r.LastName;
            prospect.fid = q.Opportunity.Contact_lie__r.Id; 
            prospects.add(prospect);
            
            System.debug('[HelperabandonnedQuotes] prospect:' + prospect);
        }
        
        return prospects;
    }
}