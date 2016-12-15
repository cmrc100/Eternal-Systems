trigger OpportunityTrigger on Opportunity (before insert, before update) {

  	if (Trigger.isInsert && Trigger.isBefore) {    
		OPPTriggerHandler.updateProbability(trigger.new, null);
		  
  	} else if(Trigger.isUpdate && Trigger.isBefore) {    
		OPPTriggerHandler.updateProbability(trigger.new, trigger.oldMap); 
  	}
}