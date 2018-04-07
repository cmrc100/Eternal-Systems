({
	doInit : function(component, event, helper) {
		
		//var url_string = window.location.href;
		//var recType = url_string.substring(url_string.indexOf("recordTypeId") + 13,url_string.indexOf("recordTypeId") + 28);
        //component.set("v.recordTypeId", recType);
        
        console.log('@@@@@ record Id  ..  ' + component.get("v.recordId"));
        
        var mapRecTypeIds = {};
        var action = component.get("c.fetchRecordTypeValues");
        action.setParams({
            "objName" : component.get("v.objName")           
        });     
        action.setCallback(this, function(response) {
            var data = response.getReturnValue();
console.log('@@@@@@@@  data  recTypes   ' + JSON.stringify(data));            
            var recTypes = [];
			for(var key in data){               
				//recTypes.push({value:data[key], key:key});
                recTypes.push({label:data[key], value:key});
                mapRecTypeIds[data[key]] = key;
			}
console.log('@@@@@@@@  recTypes  recTypes   ' + JSON.stringify(recTypes));            
            component.set("v.lstOfRecordType", recTypes);
            component.set("v.recTypeIdMap", mapRecTypeIds);

        });
        $A.enqueueAction(action);
 
	},
	cancelMap : function(component, event, helper){
      component.set("v.mapContact", false);
    },    
    createRecord : function(component, event, helper){
      helper.createRecord(component, event, helper);  
    },
    closeMap: function(component, event, helper) {
      	component.set("v.selectedRecType", "");
        component.set("v.mapContact", false);
    },

	handleChange: function (component, event) {
        var changeValue = event.getParam("value");
        component.set("v.selectedRecType", changeValue);
    }    
})