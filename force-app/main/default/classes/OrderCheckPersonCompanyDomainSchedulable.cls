global class OrderCheckPersonCompanyDomainSchedulable implements Schedulable {
   global void execute(SchedulableContext sc) {
      OrderCheckPersonCompanyDomainBatchable batch = new OrderCheckPersonCompanyDomainBatchable(); 
      database.executebatch(batch, 1);
   }
}