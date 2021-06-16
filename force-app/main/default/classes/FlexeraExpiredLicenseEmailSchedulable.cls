global class FlexeraExpiredLicenseEmailSchedulable implements Schedulable {
   global void execute(SchedulableContext sc) {
      FlexeraExpiredLicenseEmailBatchable batch = new FlexeraExpiredLicenseEmailBatchable(); 
      database.executebatch(batch, 1);
   }
}