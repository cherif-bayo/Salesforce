global class FlexeraKeyBatch implements Database.Batchable<sObject> {

	String query = 'SELECT Id, ActivatedKey__c FROM Contact';

	global FlexeraKeyBatch() {

	}

	/**
	* [start description]
	* @param  BC [description]
	* @return    [description]
	*/
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

	/**
	* [execute description]
	* @param  BC    [description]
	* @param  scope [description]
	* @return       [description]
	*/
	global void execute(Database.BatchableContext BC, List<Contact> scope) {
		Map<Id, Contact> mapToUpdate = new Map<Id, Contact>();
		FlexeraKeyTriggerHandler handler = new FlexeraKeyTriggerHandler(Trigger.isExecuting, Trigger.size);

		for(Contact c : scope){
			Boolean isUpdated = false;
			List<Flexera_Key__c> lstfk = [SELECT Id, Expiration__c, Date_limite__c FROM Flexera_Key__c WHERE Contact__c = :c.Id];

			for(Flexera_Key__c fk : lstfk){
				//Change value of field [if condition ...]
				if(datetime.now() < fk.Date_limite__c ){
					//Get Contact
					c.ActivatedKey__c = true;
					isUpdated = true;
				}
			
				//None key are activated
				if(isUpdated == false){ 
					//Get Contact
					c.ActivatedKey__c = false;
				}
				mapToUpdate.put(c.Id, c);
			}
		}
		update mapToUpdate.values();
	}

	/**
	* [finish description]
	* @param  BC [description]
	* @return    [description]
	*/
	global void finish(Database.BatchableContext BC) {

	}

}