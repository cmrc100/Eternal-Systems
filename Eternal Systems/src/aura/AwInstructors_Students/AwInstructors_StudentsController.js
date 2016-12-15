({
	onQbeFormSubmit : function(component, event, helper) {
		var formData = event.getParam('formData');
		console.log(JSON.stringify(formData));
		
		var sList = component.find("studentListCmp");
		sList.set('v.studentName', formData.studentName);
		sList.set('v.courseId', formData.courseId);
		sList.set('v.startDate', formData.startDate);
		sList.set('v.endDate', formData.endDate);
		
		sList.refresh();
		
		helper.showCard(component, "studentList");
	},
	
	onBack: function(component,event,helper){
		helper.onBack(component,event,helper);
	},
	
	onRecordAction: function(component,event,helper) {
        
	    var params = event.getParams();
	    component.set('v.currentRecordId',params.recordId);
	    	    
	    switch (params.type) {
	        case 'View' :
	          helper.showCard(component,"studentDetailView");
	          break;
	        case 'Edit' :
	          helper.showCard(component,"studentEditView");
	          break;
	        case 'Delete' :
	          //alert("Function not available");
	          helper.alert(
		          component,
		          "Not Available",
		          $A.get("$Label.c.FeatureNotAvailable")
		        ); 
	          break;
	    }
	},
	
	onSaveBtnPress: function(component, event, helper){
		
		var editGui = component.find('recordEditView');
		editGui.get("e.recordSave").fire();
	},
	
	onSaveSuccess: function(component, event, helper){
		component.find('studentListCmp').refresh();
		helper.onBack(component,event,helper);
	}	
		
	
})