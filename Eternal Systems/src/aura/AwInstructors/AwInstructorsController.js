({
	showSpinner : function (component, event, helper) {
	    var m = component.find('modalspinner');
	    $A.util.removeClass(m, "slds-hide");
	},
	
	hideSpinner : function (component, event, helper) {
	    
	    var m = component.find('modalspinner');
	    $A.util.addClass(m, "slds-hide");
	
	}
})