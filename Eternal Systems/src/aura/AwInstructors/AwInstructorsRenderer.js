({
	afterRender : function(component){
		
		this.superAfterRender();
		
		var targetEl = component.find("mainApp").getElement();
		
		targetEl.addEventListener("touchmove", function (e) {
		e.stopPropagation()}, false);
		
		
	}
	
})