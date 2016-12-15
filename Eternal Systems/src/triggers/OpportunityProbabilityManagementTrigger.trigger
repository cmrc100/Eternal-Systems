trigger OpportunityProbabilityManagementTrigger on Opportunity_Probability_Management__c (before insert, before update) {

  	if (Trigger.isInsert && Trigger.isBefore) {    
  		OPMTriggerHandler.populateKey(trigger.new);  
  	} else if(Trigger.isUpdate && Trigger.isBefore) {    
  		OPMTriggerHandler.populateKey(trigger.new);  
  	}
  	
}