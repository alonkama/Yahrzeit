({
	doInit : function(component, event, helper) {
		var action = component.get("c.updateYahrzeit");
        action.setParams({
            "deceasedId" : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                $A.get("e.force:closeQuickAction").fire();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                   "title": "Success!",
                   "message": "Date is updated!"
                });
                toastEvent.fire();
                $A.get('e.force:refreshView').fire();
            }
            else {
                var errors = response.getError();
                if (errors) {
	    	        component.set("v.error", true);
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                 errors[0].message);
	                	component.set("v.errorMessage", errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
	        }
        });
        $A.enqueueAction(action);
	}
})