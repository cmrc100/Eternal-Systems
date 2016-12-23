public with sharing class CalendarEvent {

	@AuraEnabled
	public static list<Event> getEventList(){
        
        return [select Id, StartDateTime,  Subject, Department__c from Event ];
        
    }	
	
	@AuraEnabled
	public static list<string> getDepartments(){
        
        list<string> returnList = new list<string>();
        
        returnList.add('All');
        returnList.add('Retail');
        returnList.add('Leasing');
        returnList.add('Finance');
        
        return returnList;
        
    }
    
}