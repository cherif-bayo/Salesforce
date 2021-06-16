global class UpdateContactSystemeSchedulable implements Schedulable {
   global void execute(SchedulableContext sc) {
      UpdateContactSystemeBatchable batch = new UpdateContactSystemeBatchable (); 
      database.executebatch(batch, 1);
   }
}