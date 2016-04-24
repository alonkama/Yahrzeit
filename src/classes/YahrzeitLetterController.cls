public class YahrzeitLetterController {

    private final List<Id> ids;
    public YahrzeitLetterController(ApexPages.StandardController stdController) {
    	ids = new Id[] { ((Deceased__c)stdController.getRecord()).Id };
    }
    
}