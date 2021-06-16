public without sharing class FlexeraKeyTriggerHandler {

	private final sObject mysObject;
	private boolean isExecuting = false;
	private integer batchSize = 0;

	public FlexeraKeyTriggerHandler(Boolean isExecuting, Integer size) {
		this.isExecuting = isExecuting;
		batchSize = size;
	}

	public Contact getContact(Id contactId) {
		return[SELECT Id, ActivatedKey__c FROM Contact WHERE Id = : contactId LIMIT 1];
	}

	public void changeValueOfActivatedKey(Id c, Boolean value) {
		Contact cont = getContact(c);
		cont.ActivatedKey__c = value;
		update cont;
	}

	public void OnAfterUpdate(Flexera_Key__c oldFlexeraKey, Flexera_Key__c newFlexeraKey) {
		if (newFlexeraKey.Contact__c != null) {
			changeValueOfActivatedKey(newFlexeraKey.Contact__c, datetime.now() < newFlexeraKey.Date_limite__c);
		}
	}

	public void OnAfterInsert(Flexera_Key__c flexeraKey) {
		if (flexeraKey.Contact__c != null) {
			changeValueOfActivatedKey(flexeraKey.Contact__c, datetime.now() < flexeraKey.Date_limite__c);
		}
	}

	public void SetAccountOnInsert(List<Flexera_Key__c> flexeraKey) {
		List<Flexera_Key__c> keysToUpdate = new List<Flexera_Key__c> ();
		List<Id> contactsIds = new List<Id> ();

		for (Flexera_Key__c key : flexeraKey) {
			if (key.Account__c == null) {
				contactsIds.add(key.Contact__c);
				keysToUpdate.add(key);
			}
		}

		Map<Id, Contact> contactsById = new Map<Id, Contact> ([SELECT Id, AccountId FROM Contact WHERE Id in :contactsIds]);
		Map<Id, Account> personAccountsByContactId = new Map<Id, Account> ();

		for (Account account :[SELECT Id, PersonContactId FROM Account WHERE IsPersonAccount = true AND PersonContactId in :contactsIds]) {
			personAccountsByContactId.put(account.PersonContactId, account);
		}

		for (Flexera_Key__c key : keysToUpdate) {
			if (contactsById.containsKey(key.Contact__c)) {
				key.Account__c = contactsById.get(key.Contact__c).AccountId;
			} else if (personAccountsByContactId.containsKey(key.Contact__c)) {
				key.Account__c = personAccountsByContactId.get(key.Contact__c).Id;
			}
		}
	}

	public void SetVersion(List<Flexera_Key__c> flexeraKey) {
		Date minDate = null;
		List<Flexera_Key__c> keysWithNoVersion = new List<Flexera_Key__c> ();

		for (Flexera_Key__c key : flexeraKey) {
			keysWithNoVersion.add(key);
			if (minDate == null || key.Date_Limite__c<minDate) {
				minDate = key.Date_Limite__c;
			}
		}

		Version__c[] versions = [select Id, Date__c from Version__c where Date__c <= :minDate order by Date__c DESC];

		for (Flexera_Key__c key : keysWithNoVersion) {
			for (Version__c version : versions) {
				if (version.Date__c <= key.Date_Limite__c) {
					key.Version__c = version.Id;
					break;
				}
			}
		}
	}
}