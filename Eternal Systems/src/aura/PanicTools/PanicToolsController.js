({
    onSoundEffects : function(component, event, helper) {
        component.find('btnCall').set('v.variant','neutral');
        component.find('btnSound').set('v.variant','brand');
        helper.toggleCard(component,"soundeffects");
    },
    onCall : function(component, event, helper) {
        component.find('btnCall').set('v.variant','brand');
        component.find('btnSound').set('v.variant','neutral');
        helper.toggleCard(component,"dialbutton");
    }
    
})