({
   createRecord: function(component, event, helper) {

		component.set("v.parentId", component.get("v.recordId"));
        var parentObject = component.get("v.sObjectName");
        console.log('@@@@@ parentObject  ..  ' + parentObject);
        if (parentObject){
            if (parentObject == 'Account') {//Assume Person Account context, retrieve the contact Id
                var parentId = component.get("v.simpleRecord.PersonContactId");
                if (parentId){
                    component.set("v.parentId", parentId);
                }
            }
        }
        
        console.log('@@@@@ parent Id  ..  ' + component.get("v.parentId"));       

       	var mapRecTypeIds = component.get("v.recTypeIdMap");
		var RecTypeId = component.get("v.selectedRecType")
        var createRecordEvent = $A.get("e.force:createRecord");
	  	component.set("v.recordTypeId", RecTypeId);
		
        if (RecTypeId) {
            if (RecTypeId.substring(0,15) === component.get("v.mapRecordTypeId").substring(0,15)){
               component.set("v.mapContact", true);                       
            } else  {
                createRecordEvent.setParams({
                   "entityApiName": component.get("v.objName"),
                   "recordTypeId": RecTypeId,
                   "defaultFieldValues" : {
                       "Client__c": component.get("v.parentId"), 
    
                   }
                });
                createRecordEvent.fire();
            }          
        }
   },
})