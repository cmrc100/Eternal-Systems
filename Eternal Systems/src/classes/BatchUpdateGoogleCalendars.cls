public with sharing class BatchUpdateGoogleCalendars implements Database.Batchable<SObject>, 
																Database.Stateful, 
																Database.AllowsCallouts{

    private String query;
    private integer iNum;
    private List<sObject> calendarsList;

    public BatchUpdateGoogleCalendars(String query, integer i){
    
        this.query = query; // Query to get the Calendar records to publish to from custom settings
    	this.iNum = i;
    }
	
	public Database.Querylocator start(Database.BatchableContext BC){
		
		return Database.getQueryLocator(query);
	}
	
	public void execute(Database.BatchableContext BC, List<sObject> calendars){
	
		if (iNum == 1){
			GoogleCalendarAPI.getNewToken(null, calendars);
		}
		if (iNum == 2){
			GoogleCalendarAPI.updateCalendars(calendars, true);	
		}
		if (iNum == 3){
			GoogleCalendarAPI.updateCalendars(calendars, false);	
		}		
	
	}

	public void finish(Database.BatchableContext BC){
		
		if (iNum == 1){ //schedule next part of processing - updating custom settings with Google calendar ids
			String str = system.now().addMinutes(1).format('ss mm HH dd MM ? yyyy');
			System.schedule('Google Calendar API - Calendar Ids ' + str, str , new ScheduleUpdateGoogleCalendars(2));			
		}
		
		if (iNum == 2){ // schedule final part of processing - deleting events and writing campaigns to Google calendar
			String str = system.now().addMinutes(1).format('ss mm HH dd MM ? yyyy');
			System.schedule('Google Calendar API - Calendar Events ' + str, str , new ScheduleUpdateGoogleCalendars(3));				
		}

	}

}