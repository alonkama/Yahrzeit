@isTest
public class YahrzeitTestSuite {   
    @isTest
    public static void testUpdateYahrzeitSingle() {

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
    }	
    
    
        @isTest
    public static void testUpdateYahrzeitSingleGregorian() {

        Account household = new Account(name='Test Account');
		insert household;

		Contact c = new Contact(FirstName='Foo', LastName = 'Bar', 
			AccountId = household.Id, Title = 'Mom');
		insert c;
				
		Deceased__c deceasedGregorian = new Deceased__c(Related_to_contact__c = c.Id,
			Hebrew_date_observed__c=FALSE, Month_Gregorian__c='6', Day_Gregorian__c='2', Year_Gregorian__c='2011');
		insert deceasedGregorian;
        
  		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new HebcalHttpCalloutMockImpl());
        ApexPages.StandardController stdController = new ApexPages.StandardController(deceasedGregorian);
        UpdateYahrzeitController uyc = new UpdateYahrzeitController(stdController);
        
        uyc.autoRun();       
        test.stopTest();
    }	

    
    @isTest
    public static void testUpdateYahrzeitMultiple() {
        Account household = new Account(name='Test Account');
		insert household;

		Contact c = new Contact(FirstName='Foo', LastName = 'Bar', 
			AccountId = household.Id, Title = 'Mom');
		insert c;
				
		Deceased__c deceasedGregorian = new Deceased__c(Related_to_contact__c = c.Id,
			Hebrew_date_observed__c=FALSE, Month_Gregorian__c='6', Day_Gregorian__c='2', Year_Gregorian__c='2011');
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
        UpdateYahrzeitController uyc2 = new UpdateYahrzeitController(setController);
        
        uyc2.autoRun();
        
        test.stopTest();
    }
    
}