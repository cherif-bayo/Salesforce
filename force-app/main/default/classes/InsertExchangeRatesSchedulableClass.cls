global class InsertExchangeRatesSchedulableClass implements Schedulable {
   global void execute(SchedulableContext ctx) {
      InsertExchangeRatesFromWebService.InsertRates();
   }   
}