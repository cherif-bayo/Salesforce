global class UpdateContactLeadSchedulable implements Schedulable {
   global void execute(SchedulableContext sc) {
      UpdateContactLead batch = new UpdateContactLead(); 
      database.executebatch(batch);
   }
}