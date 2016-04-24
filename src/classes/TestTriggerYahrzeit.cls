/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TestTriggerYahrzeit {

    static testMethod void myUnitTest() {
		Account a = new Account(name='Test account');
		insert a;
		Contact c = new Contact(FirstName='First', LastName='Last', Title='Son');
		c.AccountId = a.Id;
		insert c;
		
		Deceased__c deceased = new Deceased__c(
			Hebrew_date_observed__c=FALSE, 
			Month_Gregorian__c='1', 
			Day_Gregorian__c='15',
			Related_to_contact__c=c.Id);
		insert deceased;    
		
//		System.assertEquals(a.Name, deceased.Household__r.Name);
			
    	
    }
}