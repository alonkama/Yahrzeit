public with sharing class UpdateYahrzeitController {

	// Constructor - this only really matters if the autoRun function doesn't work right
    public List<Deceased__c> objs {get; set;}
    
    public Integer getObjsSize() {
        return objs.size();
    }
    
    public UpdateYahrzeitController(ApexPages.StandardController stdController) {
        List<Id> ids = new List<Id>();
        ids.add(stdController.getId());
        objs = getDetailsByIds(ids);
    }
    
    public UpdateYahrzeitController(ApexPages.StandardSetController setController) { 
        
    	objs = (List<Deceased__c>) setController.getSelected();
        if (objs == null) return;
    	
        List<Id> ids = new List<Id>();
        for (Deceased__c d : objs) {
    		ids.add(d.Id);
    	}
        objs = getDetailsByIds(ids);
    }
    
    private List<Deceased__c> getDetailsByIds(List<Id> ids) {
        return [SELECT Id, Name, Hebrew_date_observed__c, After_Sunset__c, Yahrzeit_this_year__c,
            Day_Hebrew__c, Month_Hebrew__c, Year_Hebrew__c, MergeField_Letter__c,
            Day_Gregorian__c, Month_Gregorian__c, Year_Gregorian__c FROM Deceased__c 
            WHERE Id IN :ids];
    }
    
    public PageReference autoRun() {
        return doUpdate();

    }
    
	// Code we will invoke on page load.
    public PageReference doUpdate() {
        Yahrzeit.updateYahrzeitForDeceased(objs);
 
        // If single record, Redirect the user back to the original page
        if (objs.size() == 1) {
        	PageReference pageRef = new PageReference('/' + objs.get(0).Id);
	        pageRef.setRedirect(true);
	        return pageRef;
        }
 		return null; //ApexPages.currentPage();
    }    

}