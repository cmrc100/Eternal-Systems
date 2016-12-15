({
	alert : function(component, title, message) {
		
		$A.createComponent(
			"c:modalDialog",
			{ "title" : title,
			  "body" : message,
			  "onclose": component.getReference("c.onDestroyModalDialog")
			},
			function(msgBox){
				if (component.isValid()){
					var targetCmp = component.find('optionalModalDialog');
					var body = targetCmp.get("v.body");
					body.push(msgBox);
					targetCmp.set("v.body", body);
				}						
			}
		);
	},
	
	callServer : function(component,method,callback,params) {
	    var action = component.get(method);
	    if (params) {
	        action.setParams(params);
	    }
	  
	    action.setCallback(this,function(response) {
	        var state = response.getState();
console.log(' @@@@  ' + state);	        
	        if (state === "SUCCESS") { 
console.log(' @@@@  ' + response.getReturnValue());
	            // pass returned value to callback function
	            callback.call(this,response.getReturnValue());   
	        } else if (state === "ERROR") {
	            // generic error handler
	            var errors = response.getError();
	            if (errors) {
	                console.log("Errors", errors);
	                if (errors[0] && errors[0].message) {
	                    throw new Error("Error" + errors[0].message);
	                }
	            } else {
	                throw new Error("Unknown Error");
	            }
	        }
	    });
	
	    $A.enqueueAction(action);
	},
	
	raiseS1Event : function(component, event, helper, eventName, params){
	
		var evt = $A.get(eventName);
		
		if (evt) {
			evt.setParams(params);
			evt.fire();
		} else {
		
			helper.alert(
				component,
				"Feature Only Available in Salesforce1",
				$A.get("$Label.c.FeatureNotAvailable")
			);
			
		}
	
	}
		
})