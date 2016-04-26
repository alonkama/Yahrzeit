trigger TriggerYahrzeitInsertHousehold on Deceased__c (before insert, before update) {
	System.debug('I am in the trigger!');
    
    Map<Id,Deceased__c> noHousehold = new Map<Id,Deceased__c>();
	
	for(Deceased__c d : Trigger.new) {
		System.debug('Deceased: ' + d);
		System.debug('Deceased name: ' + d.Name);
		System.debug('  Household = ' + d.household__c);
		System.debug('  Related_to = ' + d.Related_to_contact__c);
		if (d.Household__c == null && d.Related_to_contact__c != null) {
			System.debug('---Assigning household---');
            noHousehold.put(d.Related_to_contact__c, d);
        }
        
        if (noHousehold.size() > 0) {
            Set<Id> keys = noHousehold.keySet();
            List<Contact> contacts = [SELECT Id, AccountId from Contact WHERE Id IN :keys];
            for (Contact c : contacts) {
				System.debug('---Assigning to household ' + c.AccountId + '---');
						
				noHousehold.get(c.Id).Household__c = c.AccountId;
            }
        }
    }
}