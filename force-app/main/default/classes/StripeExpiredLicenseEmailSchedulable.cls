global class StripeExpiredLicenseEmailSchedulable implements Schedulable {
   global void execute(SchedulableContext sc) {
      StripeExpiredLicenseEmailBatchable batch = new StripeExpiredLicenseEmailBatchable(); 
      database.executebatch(batch, 1);
   }
}