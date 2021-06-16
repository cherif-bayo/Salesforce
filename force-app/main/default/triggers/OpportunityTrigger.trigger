/**
 * Opportunity Trigger
 */
trigger OpportunityTrigger on Opportunity (after insert, after update, after delete) {
	
	OpportunityTriggerHandler handler = new OpportunityTriggerHandler();

	/* INSERT */
	if(Trigger.isInsert && Trigger.isBefore){
		//handler.OnBeforeInsert(Trigger.new[0]);
	}
	else if(Trigger.isInsert && Trigger.isAfter){
		handler.OnAfterInsert(Trigger.new[0]);
	}

	/* UPDATE */
	else if(Trigger.isUpdate && Trigger.isBefore){
		//handler.OnBeforeUpdate(Trigger.old[0], Trigger.new[0]);
	}
	else if(Trigger.isUpdate && Trigger.isAfter){
		handler.OnAfterUpdate(Trigger.old[0], Trigger.new[0]);
	}

	/* DELETE */
	else if(Trigger.isDelete && Trigger.isAfter){
		handler.OnAfterDelete(Trigger.old[0]);
	}
}