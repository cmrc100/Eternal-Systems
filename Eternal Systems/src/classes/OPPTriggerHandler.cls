public with sharing class OPPTriggerHandler {
	
	private static boolean bCalled = false;
	
	// Method called before insert of new record and on before update
	// to update probability field with configuration value if required
	public static void updateProbability(list<Opportunity> oppList, map<Id, Opportunity> oppOldMap){

		OPMUtil.applyUpdate(null, oppList);
		
	}


}