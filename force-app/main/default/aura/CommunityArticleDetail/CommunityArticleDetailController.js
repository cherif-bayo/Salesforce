({
	doInit : function(component, event, helper) {
		var action = component.get("c.getSummary");
        action.setParams({ recordId : component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.article", response.getReturnValue());
            } else if (state === "INCOMPLETE") {
				console.log("Errreur in getSummary : INCOMPLETE");
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) console.log("Error message action: " + errors[0].message);
                } else {
                    console.log("Errreur in getSummary");
                }
            }
        });
        $A.enqueueAction(action);

		var getFiles = component.get("c.getFiles");
        getFiles.setParams({ recordId : component.get("v.recordId") });
        getFiles.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.files", response.getReturnValue());				
            } else if (state === "INCOMPLETE") {
				console.log("Errreur in getFiles : INCOMPLETE");
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) console.log("Error message files: " + errors[0].message);
                } else {
                    console.log("Erreur in getFiles");
                }
            }
        });
		$A.enqueueAction(getFiles);
	}
})