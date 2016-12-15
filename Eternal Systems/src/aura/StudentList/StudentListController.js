({
doInit: function(component, event, helper) {
        
     helper.callServer(component,"c.getStudents",function(response){
         var rec;
         var recs = [];
       
         for (var i=0; i< response.length; i++) {
             rec = response[i].Student__r;
             recs.push({
                 pk: rec.Id,
                 data: ''.concat(
                    rec.Name,
                    "|",
                    response[i].Course_Delivery__r.Course__r.Name,
                    '|',
                    response[i].Course_Delivery__r.Start_Date__c,
                    '|',
                     rec.Email,
                    "|",
                     (rec.MobilePhone ? rec.MobilePhone : "Not Specified")
                 ),
                 delimiter: "|"
             });
         }

         component.set("v.rows", recs);  
         component.find('grid').refresh();
     }, {
         studentName: component.get('v.studentName'),
         courseId: component.get('v.courseId'),
         startDate: component.get('v.startDate'),
         endDate: component.get('v.endDate')
     });
 },
	
	onListItemClick : function(component, event, helper) {
		var params = event.getParams();
		component.set("v.selectedRecordId", params.pk);
		
		var selectedRowEl = component.get("v.selectedRowEl");
		
		if(selectedRowEl){
			$A.util.removeClass(selectedRowEl, "slds-is-selected");
		
		}
		
		component.set("v.selectedRowEl", params.domEl);
		
		$A.util.addClass(params.domEl, "slds-is-selected");
			
	},
	
	onMenuClick : function(component, event, helper) {
		
		var compEvent = component.getEvent("recordaction");
		compEvent.setParams({
			type: event.detail.menuItem.get('v.value'),
			recordId: component.get("v.selectedRecordId")				
		});
		compEvent.fire();
				

		/*
		switch (event.detail.menuItem.get('v.value')) {
		    
		    case 'View' :
		        helper.alert(
		          component,
		          "Not Available",
		          $A.get("$Label.c.FeatureNotAvailable")
		        ); 
		        break;
		    
		    case 'Edit' :
		        
		        helper.raiseS1Event(
		        	component,
		        	event,
		        	helper,
		        	"event.force:editRecord",
		        	{recordId : component.get("v.selectedRecordId")}		        
		        );

		        break;
		    
		    case 'Delete' :
		        helper.alert(
		          component,
		          "Not Available",
		          $A.get("$Label.c.FeatureNotAvailable")
		        ); 
		        break;
		}
		*/
	},
	onDestroyModalDialog: function(component){
		
		var cmp = component.find('optionalModalDialog');
		cmp.set("v.body", []); 
	
	
	}
})