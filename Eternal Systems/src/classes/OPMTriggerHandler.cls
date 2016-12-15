public with sharing class OPMTriggerHandler {

	// Method called before insert of new record and on before update
	// to ensure uniqueness.
	public static void populateKey(list<Opportunity_Probability_Management__c> opmList){
		
		//Set composite key field to value Role+Stage+Product Line
		for (Opportunity_Probability_Management__c opm :opmList){
			opm.Composite_Key__c = opm.Role__c + opm.Stage__c + opm.Product_Line__c;
		}
		
		
	}

}