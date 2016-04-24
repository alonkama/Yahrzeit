trigger TriggerYahrzeitInsertHousehold on Deceased__c (before insert, before update) {
	System.debug('I am in the trigger!');
	
	for(Deceased__c d : Trigger.new) {
		System.debug('Deceased: ' + d);
		System.debug('Deceased name: ' + d.Name);
		System.debug('  Household = ' + d.household__c);
		System.debug('  Related_to = ' + d.Related_to_contact__c);
		if (d.Household__c == null && d.Related_to_contact__c != null) {
			System.debug('---Assigning household---');
			Contact c = [SELECT Id, AccountId from Contact WHERE Id = :d.Related_to_contact__c];
			System.debug('---Assigning to household ' + c.AccountId + '---');
			
			d.Household__c = c.AccountId;
        }
	}
}