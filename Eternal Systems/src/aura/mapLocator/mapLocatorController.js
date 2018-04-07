({
	doInit : function(component, event, helper) {
      
	    //Send LC Host as parameter to VF page so VF page can send message to LC; make it all dynamic
        component.set('v.lcHost', window.location.hostname);
		
        var messageHandler = function(event){
            // Handle the message
           
            if(event.data.state === 'LOADED'){
                helper.loadMap(component, event, helper);
                //Send data to VF page to draw map
                helper.sendToVF(component, helper);
            }
            
            if(event.data.state === 'UPDATE'){
                if (event.data.editMode == true){
                    //Edit Record
                    helper.saveEditRecord(component,event,helper);
					                    
                    component.destroy();
                    window.location.reload();                    
                } else {
                	//Create Record                    
                	helper.saveNewRecord(component,event,helper); 
                    var closeEvent = component.getEvent("evtMapClose");
                    closeEvent.fire();
                    window.removeEventListener("message", messageHandler, false);
                    component.destroy();
                }
            }
            if(event.data.state === 'CANCEL'){
                window.removeEventListener("message", messageHandler, false);

                var recId = component.get("v.recordId");
               
                if (component.get("v.parentId") && event.data.editMode == true){
                    recId = component.get("v.parentId");
                } 
                component.destroy();
                window.location.reload();
                /*
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": recId
                });
                navEvt.fire();
                */
            }            
        }            
        
		//Add message listeners
        window.addEventListener("message", messageHandler, false);
        
        window.addEventListener("beforeunload", function (event) {
  			window.removeEventListener("message", messageHandler, false);
		});

	}
           

})