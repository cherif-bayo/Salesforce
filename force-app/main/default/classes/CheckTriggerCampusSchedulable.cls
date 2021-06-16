global class CheckTriggerCampusSchedulable  implements Schedulable {
    global void execute(SchedulableContext sc){
        CheckTriggerCampusBatchable batch = new CheckTriggerCampusBatchable();
        Database.executeBatch(batch);
    }
}