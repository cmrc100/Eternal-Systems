({
	doInit : function(component, event, helper) {
	    
	    helper.callServer(component,"c.getCourses",function(response){
	        var opts = [{
	            label: "Please Select",
	            value: ""
	        }];
	        for (var i=0; i<response.length; i++) {
	            opts.push({
	                label : response[i].Name,
	                value: response[i].Id
	            });
	        }
	        component.set("v.courses", opts);
	    });
	},
	
	validateData : function(component, event, helper) {
	        
	  var fields=["studentName","startDate","endDate"];
	  var field = "";
	  var validity = null; 
	  
	  for (var i=0; i<fields.length; i++) {
	    field=component.find(fields[i]);
	    validity=field.get('v.validity');
	    if (typeof validity == 'object' && validity != null) {
	      if (validity.badInput || 
	          validity.patternMismatch || 
	          validity.rangeOverflow || 
	          validity.rangeUnderflow ||
	          validity.stepMismatch || 
	          validity.tooLong || 
	          validity.typeMismatch || 
	          validity.valueMissing) {
	                      
	          component.find("btnSubmit").set("v.disabled",true);
	          return;
	       }
	    }
	  }
	  component.find("btnSubmit").set("v.disabled",false);
	},
	
	submitForm : function(component, event, helper) {
	
		event.preventDefault();
		var compEvent = component.getEvent("formsubmit");
		
		compEvent.setParams({
			formData: {
				studentName: component.get('v.studentName'),
				courseId: component.get('v.courseId'),
				startDate: component.get('v.startDate'),
				endDate: component.get('v.endDate')			
			}			
		});
		compEvent.fire();
	}	
	
	
})