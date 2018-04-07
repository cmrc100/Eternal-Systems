({
	popTitle : function(component, event, helper){    	
        var help = 'hello there mate'
        console.log(help);
        //console.log(event.srcElement.id);

        //great, now insert the tooltip!
        let helpElId = event.currentTarget.id.substr(0, event.currentTarget.id.lastIndexOf ('_'));
console.log(helpElId);        
        let helpEl = component.find(helpElId);
        $A.util.toggleClass(helpEl, "slds-hide");
    },
    
	handleHelp : function(component, event, helper) {
        let helpElId = event.currentTarget.id.substr(0, event.currentTarget.id.lastIndexOf ('_'));
        let helpEl = component.find(helpElId);
        $A.util.toggleClass(helpEl, "slds-hide");
	}    
})