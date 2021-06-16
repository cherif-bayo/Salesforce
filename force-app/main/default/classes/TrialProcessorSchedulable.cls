global class TrialProcessorSchedulable implements Schedulable {
   global void execute(SchedulableContext sc) {
      TrialProcessor  batch = new TrialProcessor(); 
      database.executebatch(batch);
   }
}