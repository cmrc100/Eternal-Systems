global with sharing class ScheduleUpdateGoogleCalendars implements Schedulable{
	
	integer iSequence = 1;
	
	// constructor used to determine batch process sequence
	public ScheduleUpdateGoogleCalendars(integer i){
		iSequence = i;
	}
	public ScheduleUpdateGoogleCalendars(){
		iSequence = 1;
	}
	
    global void execute(SchedulableContext sc){
    	//Batch Job for updating Google calendar entries
    	string sQuery = 'Select Name, Calendar_Account_Id__c, Google_Calendar_Id__c, Calendar_Name__c, Token__c, Refresh_Token__c, Expires__c, Publish__c, Client_Id__c, Client_Secret__c';
    	sQuery +=  ' from GoogleCalendarAPI__c ';
    	sQuery += ' where publish__c = true';
    	
    	if (iSequence == 1){ // First batch process - get new Google calendar API Authorization token   		
        	BatchUpdateGoogleCalendars batchJob1 = new BatchUpdateGoogleCalendars(sQuery, 1);
        	Database.executeBatch(batchJob1, 1); 
    	}
    	
    	if (iSequence == 2){ // second batch process - update Google calendar ids in custom settings
			BatchUpdateGoogleCalendars batchJob2 = new BatchUpdateGoogleCalendars(sQuery, 2);
        	Database.executeBatch(batchJob2, 1); 
    	}
    	
    	if (iSequence == 3){ // third batch process - process campaigns and write events to Google calendar
			BatchUpdateGoogleCalendars batchJob3 = new BatchUpdateGoogleCalendars(sQuery, 3);
        	Database.executeBatch(batchJob3, 1);     		
    	}
    }

}