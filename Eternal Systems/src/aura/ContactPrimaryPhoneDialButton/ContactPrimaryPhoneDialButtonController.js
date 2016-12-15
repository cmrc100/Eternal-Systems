({
	doInit : function(component, event, helper) {
		
        helper.callServer(
        	component,
            "c.getPhone",
            function (response){
                component.set('v.contactPhone', response);
            },
            {contactId: component.get('v.recordId')}
        
        );
                
	}
})