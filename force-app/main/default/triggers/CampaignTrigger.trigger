/**
 * Campaign Trigger
 */
trigger CampaignTrigger on Campaign (before update, before insert, after insert) {
	
	CampaignTriggerHandler handler = new CampaignTriggerHandler();

	/* UPDATE */
	if(Trigger.isUpdate && Trigger.isBefore){
		handler.OnBeforeUpdate(Trigger.old[0], Trigger.new[0]);
	}
	else if(Trigger.isUpdate && Trigger.isAfter){
		//handler.OnAfterUpdate(Trigger.old[0], Trigger.new[0]);
		//{{ trigger_handler_name }}.OnAfterUpdateAsync(Trigger.newMap.keySet());
	}

	/* INSERT */
	else if(Trigger.isInsert && Trigger.isBefore){
		handler.OnBeforeInsert(Trigger.new[0]);
	}
	else if(Trigger.isInsert && Trigger.isAfter){
		//handler.OnAfterInsert(Trigger.new[0]);
	}
}