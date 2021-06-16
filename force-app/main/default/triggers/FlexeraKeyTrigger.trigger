/**
 * FlexeraKey Trigger
 */
trigger FlexeraKeyTrigger on Flexera_Key__c(after insert, after update, before insert) {
	FlexeraKeyTriggerHandler handler = new FlexeraKeyTriggerHandler(Trigger.isExecuting, Trigger.size);

	if (Trigger.isInsert && Trigger.isBefore) {
		handler.SetAccountOnInsert(Trigger.new);
		handler.SetVersion(Trigger.new);
	} else if (Trigger.isInsert && Trigger.isAfter) {
		handler.OnAfterInsert(Trigger.new[0]);
	} else if (Trigger.isUpdate && Trigger.isAfter) {
		handler.OnAfterUpdate(Trigger.old[0], Trigger.new[0]);
	}
}