({
	doInit : function(component, event, helper) {
		
        var action1 = component.get("c.getTheRecs");
           
        action1.setCallback(this, function(a) {             
        	var returnVal = a.getReturnValue();
			
            component.set("v.theRecords", returnVal);
            console.log('@@@ RECORDS .. ' + JSON.stringify(component.get("v.theRecords")));


            var action2 = component.get("c.getTheFlds");
               
            action2.setCallback(this, function(a) {             
                var returnVal = a.getReturnValue();
                
                component.set("v.theFields", returnVal);
    
                $A.createComponent(
                    "c:myDataTable",{
                        "theRecords" : component.get("v.theRecords"),
                        "theFields" : component.get("v.theFields")            
                    },
                    function(tbl, status, errorMessage){
                        if (status === "SUCCESS") {
                            component.set("v.body", tbl);
                        }
                    }
                );
    
    
                
            });
            $A.enqueueAction(action2);   


            
    	});
		$A.enqueueAction(action1);            


      
		
        
        


	}
})