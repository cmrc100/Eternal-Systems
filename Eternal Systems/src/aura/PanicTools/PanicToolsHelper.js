({
    toggleCard : function(component,cardId) {
        var pnlDial = component.find('dialbutton');
        var pnlSoundEffects =component.find('soundeffects');
        if (cardId == "dialbutton"){
            $A.util.removeClass(pnlDial,"card--off");
            $A.util.addClass(pnlSoundEffects,"card--off");
        } else {
            $A.util.removeClass(pnlSoundEffects,"card--off");
            $A.util.addClass(pnlDial,"card--off");
        }
        
    }
})