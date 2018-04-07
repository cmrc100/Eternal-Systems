({
	doInit : function(component, event, helper) {
		
        var theRecords = component.get("v.theRecords");
        
		for (var rec in theRecords) {
			console.log(theRecords[rec]);                              		
            for (var fld in theRecords[rec]) {
                
                console.log(fld +' = ' + theRecords[rec][fld]);
            }
        	console.log(' @@@@ next record ');
        }
        
	}
})