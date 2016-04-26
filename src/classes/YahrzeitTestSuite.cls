@isTest
public class YahrzeitTestSuite {
    
    @isTest
    public static void testTriggerNoHousehold() {
        Account household = new Account(name='Test Account');
		insert household;

		Contact c = new Contact(FirstName='Foo', LastName = 'Bar', 
			AccountId = household.Id, Title = 'Mom');
		insert c;
        
		Deceased__c deceasedHebrew = new Deceased__c(Related_to_contact__c = c.Id,
			Hebrew_date_observed__c=TRUE, Month_Gregorian__c='6', Day_Gregorian__c='2', Year_Gregorian__c='2011');
		insert deceasedHebrew;
        
        deceasedHebrew = [SELECT Id, Household__c FROM Deceased__c WHERE Id = :deceasedHebrew.Id];

		System.assertEquals(household.Id, deceasedHebrew.Household__c);        
    }
    
    
    @isTest
    public static void testUpdateYahrzeitSingleGregorian() {

        Account household = new Account(name='Test Account');
		insert household;

		Contact c = new Contact(FirstName='Foo', LastName = 'Bar', 
			AccountId = household.Id, Title = 'Mom');
		insert c;
				
		Deceased__c deceasedHebrew = new Deceased__c(Related_to_contact__c = c.Id,
			Hebrew_date_observed__c=TRUE, Month_Gregorian__c='6', Day_Gregorian__c='2', Year_Gregorian__c='2011');
		insert deceasedHebrew;
        
  		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new HebcalHttpCalloutMockImpl());
        ApexPages.StandardController stdController = new ApexPages.StandardController(deceasedHebrew);
        UpdateYahrzeitController uyc = new UpdateYahrzeitController(stdController);
        
        uyc.autoRun();       
        test.stopTest();
        deceasedHebrew = [SELECT Month_Hebrew__c, Day_Hebrew__c, Year_Hebrew__c FROM Deceased__c WHERE Id = :deceasedHebrew.Id];
        System.assertNotEquals(null, deceasedHebrew.Day_Hebrew__c);
        System.assertNotEquals(null, deceasedHebrew.Month_Hebrew__c);
        System.assertNotEquals(null, deceasedHebrew.Year_Hebrew__c);
    }	
    
    
    @isTest
    public static void testUpdateYahrzeitMultiple() {
        Account household = new Account(name='Test Account');
		insert household;

		Contact c = new Contact(FirstName='Foo', LastName = 'Bar', 
			AccountId = household.Id, Title = 'Mom');
		insert c;
				
		Deceased__c deceasedGregorian = new Deceased__c(Related_to_contact__c = c.Id,
			Hebrew_date_observed__c=FALSE, Month_Gregorian__c='6', Day_Gregorian__c='2', Year_Gregorian__c='2011',
            Yahrzeit_this_year__c = null);
		insert deceasedGregorian;
        
		Deceased__c deceasedHebrew = new Deceased__c(Related_to_contact__c = c.Id,
			Hebrew_date_observed__c=TRUE, Month_Gregorian__c='6', Day_Gregorian__c='2', Year_Gregorian__c='2011');
		insert deceasedHebrew;
        
        
        List<Deceased__c> dList = new List<Deceased__c>();
        dList.add(deceasedHebrew);
        dList.add(deceasedGregorian);
 		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new HebcalHttpCalloutMockImpl());
        
        ApexPages.StandardSetController setController = new ApexPages.StandardSetController(dlist);
        setController.setSelected(dList);
        UpdateYahrzeitController uyc2 = new UpdateYahrzeitController(setController);
        
        uyc2.autoRun();
        
        
        deceasedGregorian = [SELECT Id, Hebrew_Date_Observed__c, Yahrzeit_this_year__c FROM Deceased__c WHERE Id = :deceasedGregorian.Id];
        System.assertNotEquals(null, deceasedGregorian.Yahrzeit_this_year__c);

        deceasedHebrew = [SELECT Id, Yahrzeit_this_year__c FROM Deceased__c WHERE Id = :deceasedHebrew.Id];
        System.assertNotEquals(null, deceasedHebrew.Yahrzeit_this_year__c);
        
        System.assertNotEquals(deceasedGregorian.Yahrzeit_this_year__c, deceasedHebrew.Yahrzeit_this_year__c);
        test.stopTest();        
    }
    
}