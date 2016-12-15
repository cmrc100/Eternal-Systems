({
    showCard: function(component,activeCard) {
        var cards = component.find("cardContainer").get('v.body');
        for (var i=0; i<cards.length; i++) {
            if (activeCard == cards[i].getLocalId()) {
                $A.util.removeClass(cards[i],"card--off");
            } else {
                $A.util.addClass(cards[i],"card--off");
            }
        }
        component.set('v.currentView',activeCard);
    },
    
	onBack : function(component,event,helper) {
 	    
     	var cards = component.find("cardContainer").get('v.body');
        var activeCard = component.get('v.currentView');
        
        if (activeCard == 'studentEditView') {
          helper.showCard(component,"studentList")
        } else {
            // generally assumes that cards are listed in sequence
            for (var i=0; i<cards.length; i++) {
                if (cards[i].getLocalId() == activeCard) {
                    helper.showCard(component,cards[i-1].getLocalId());
                    break;
                }   
            }
        }
	}
})