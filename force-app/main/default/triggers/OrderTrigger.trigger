/**
 * Order Trigger
 */
trigger OrderTrigger on Order (before insert, after insert, before update, after update, before delete) {
	
	OrderTriggerHandler handler = new OrderTriggerHandler();

	/* INSERT */
	if(Trigger.isInsert && Trigger.isBefore){
		handler.OnBeforeInsert(Trigger.new[0]);
	}
	else if(Trigger.isInsert && Trigger.isAfter){
		handler.OnAfterInsert(Trigger.new[0]);
		//{{ trigger_handler_name }}.OnAfterInsertAsync(Trigger.newMap.keySet());
	}

	/* UPDATE */
	else if(Trigger.isUpdate && Trigger.isBefore){
		handler.OnBeforeUpdate(Trigger.old[0], Trigger.new[0]);
	}
	else if(Trigger.isUpdate && Trigger.isAfter){
		handler.OnAfterUpdate(Trigger.old[0], Trigger.new[0]);
		//{{ trigger_handler_name }}.OnAfterUpdateAsync(Trigger.newMap.keySet());
	}

	/* DELETE */
	else if(Trigger.isDelete && Trigger.isBefore){
		handler.OnBeforeDelete(Trigger.old[0]);
	}
}