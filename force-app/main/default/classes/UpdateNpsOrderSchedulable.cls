global class UpdateNpsOrderSchedulable implements Schedulable {
   global void execute(SchedulableContext sc) {
      UpdateNpsOrder  batch = new UpdateNpsOrder (); 
      database.executebatch(batch);
   }
}