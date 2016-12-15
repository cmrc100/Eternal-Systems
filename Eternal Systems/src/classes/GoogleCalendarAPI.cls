public with sharing class GoogleCalendarAPI {
	
	public boolean bCodeReturned {get; private set;}
	public string sAuthoriseMsg {get; private set;}

	private static final string AUTH_FAILED = 'Step 1 of Authorization process not complete, please try again.';
	private static final string AUTH_SUCCESS = 'Step 1 of Authorization process complete, please click Confirm to complete process';
	private static final string TOKEN_URL = 'https://accounts.google.com/o/oauth2/token'; 

	private static map<string, string> fieldMap = new map <string, string>();
	private static map<string, string> multifieldMap = new map <string, string>(); 
	private static integer iCallOutNum = 0; //keep track of callouts
	private static boolean bRepeat = false;
    	
	/*Method to retrieve authorization token from Google, called after user has visited the Google authorization screen from Salesforce */
	public  PageReference retrieveToken(){		
		
		Map<string, GoogleCalendarAPI__c> googleApp = null;
		map<string, string>tokenValues = null;
        string sCode = '';

     	googleApp = GoogleCalendarAPI__c.getAll();
     	sCode = ApexPages.currentPage().getParameters().get('code');  	
     	if (string.isNotBlank(sCode)){
     		
     		string sAccesstoken  = '';
	        string sRefreshToken = '';
	        boolean bRetrieveToken = false;
	        boolean bRetrieved = false;
	        Integer iExpiresIn = 0;
     		
	     	// Return the Custom Setting records
	     	for (GoogleCalendarAPI__c gc :googleApp.values()){
	     		bRetrieveToken = gc.Retrieve_Token__c; // flag to indicate the authorization token relates to this Custom Setting record
	     		if (bRetrieveToken){
	         
	          		// Set up parameters required for Google authorization
	          		string sScope = 'https://www.googleapis.com/auth/calendar';
	          		string sRediruri = 'https://'+ApexPages.currentPage().getHeaders().get('Host')+'/apex/verifyGoogleApp';
	          		string sBody = 'client_id=' +  gc.Client_Id__c + 
	                                        '&redirect_uri=' + sRediruri + 
	                                        '&scope=' + sScope + 
	                                        '&client_secret=' +gc.Client_Secret__c + 
	                                        '&code=' + sCode +
	                                        '&grant_type=authorization_code';        
	        		if (!bRetrieved){ // retrieve token values once for the records in question
	          			tokenValues = doFinalHttpRequest(TOKEN_URL, sBody, gc);
	          			bRetrieved = true;
	          			if (tokenValues != null){
	          				sAccessToken = tokenValues.get('access_token');
	          				sRefreshToken = tokenValues.get('refresh_token');
	          				iExpiresIn = integer.valueOf(tokenValues.get('expires_in'));
	          			}
	          			if (sAccessToken.length() == 0){
	          				break;
	          			}         		
	        		} else {
						// do nothing
	        		}

	        		// Update Custom Setting records with Token details
        			if (sAccessToken.length() > 0){
						gc.code__c = sCode;
		        		gc.Token__c  = sAccesstoken;
		        		gc.Expires__c    = system.now().addSeconds(iExpiresIn);
		        		gc.Refresh_Token__c = sRefreshToken;
        			} else {
        				break;
        			}	        		
	     		}
     		}
    		try{        
    			update googleApp.values();
    		} 
    		catch(DMLException e){
    			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Failed to save Token details :  error returned is ' + e.getMessage()));
    		}     		
     		
     	}
     	this.sAuthoriseMsg = 'Complete';
     	this.bCodeReturned = false;
 		return null;
		
	}
	
	// Retrieves initial code supplied by Google as part of the OAuth2 Authorization process
	public PageReference retrieveCode(){

        if(ApexPages.currentPage().getParameters().containsKey('code')){           
        	this.bCodeReturned = true;
        	sAuthoriseMsg = AUTH_SUCCESS;		
        } else {
        	this.bCodeReturned = false;	
        	sAuthoriseMsg = AUTH_FAILED;
        }

 		return null;		
		
	}
	
	// Last API call required to retrieve OAuth2 Authorization Token from Google 
 	private map<string, string> doFinalHttpRequest(String uri, String body, GoogleCalendarAPI__c googleApp) {
	
	try{
     
	        Http h          = new Http();
	        HttpRequest req = new HttpRequest();
	        HttpResponse res;
	        
	        req.setEndpoint(uri);
	        req.setMethod('POST');
	        req.setBody(body);
	        
	        map<string, string> tokenValues = null;

	        res = h.send(req);
       
	        string sResp = res.getBody();

	        string sMsg = '';
	        string sAccessToken = '';
	        
	        //response comes back as a JSON string
	        JSONParser parser = JSON.createParser(sResp);
	        tokenValues = new map<string, string>();
	        while (parser.nextToken() != null) {
	            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)){
	                string fieldName = parser.getText();
	                parser.nextToken();
	                if(fieldName == 'access_token') {
	                    sAccessToken = parser.getText();
	                    tokenValues.put('access_token', sAccessToken);
	                }
	                else if(fieldName == 'expires_in'){
	                    integer iExpiresIn = parser.getIntegerValue();
	                    tokenValues.put('expires_in', string.ValueOf(iExpiresIn));
	                }
	                else if(fieldName == 'refresh_token'){
	                    string sRefreshToken = parser.getText();
	                    tokenValues.put('refresh_token', sRefreshToken);
	                }
	                else if(fieldName == 'error'){
	                	sMsg = parser.getText();
	                }
	            }
	        }
	        if (sAccessToken.length() == 0){	        
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Failed to retrieve Authorization Token :  message returned is ' + sMsg));
	        } else {
		        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM ,'Token retrieved. Google Calendars available'));
			}
	    
	    	return tokenValues;
	    }

		catch (exception e){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Internal Failure to retrieve Authorization Token  :  error returned is ' + e.getMessage()));
			return null;
		}
		
		
 	}
	// Method called by Batch processes - boolean bIds flag indicates whether process should 
	// only retrieve calendar Ids from Google (true) or write events to Google calendar (false)
	public static void updateCalendars(List<GoogleCalendarAPI__c> gcList, boolean bIds){

		map<string, list<sobject>> googleCalCampaigns = getCalendarList(gcList, bIds);
		if (!bIds){
			deleteEvents(googleCalCampaigns);
			writeEvents(googleCalCampaigns);
		}

	}

	// Retrieves Google calendar Ids to update and Campaign records to publish in map format
	private static map<string, list<sobject>> getCalendarList(List<GoogleCalendarAPI__c> gcList, boolean bIds){
				
		string sURL = 'https://www.googleapis.com/calendar/v3/users/me/calendarList';
		
		// Query Custom Settings to determine calendars to publish to
		Map<string, GoogleCalendarAPI__c> googleApp = null;
		map<string, list<sobject>> googleCalCampaigns = null;
				
     	// Return the Custom Setting records
     	googleApp = GoogleCalendarAPI__c.getAll();
     	//for (GoogleCalendarAPI__c gc :googleApp.values()){
     	for (GoogleCalendarAPI__c gc :gcList){
     		boolean bPublish = gc.Publish__c; // flag to indidcate whether calendar should be updated
     		if (bPublish){
     			// retrieve calendar Id from Google
     			string sName = gc.Calendar_Name__c; // Google calendar name
     			string sToken = gc.Token__c;
     			string sRefreshToken = gc.Refresh_Token__c;
     			string sCalendarId = gc.Google_Calendar_Id__c;
				datetime dtExpires = gc.Expires__c;
				
				if (bIds){
					if (string.isBlank(sCalendarId)){
						updateCalendarId(gcList);
						return null;
					}
				} else {
					
					googleCalCampaigns = getCampaigns(gcList);
					
				}    			
     		}	

     	}
     	
     	return googleCalCampaigns;
	}

	private static map<string, list<sobject>> getCampaigns(List<GoogleCalendarAPI__c> gcList){
	
		map<string, list<sobject>> googleCalCampaigns = new map<string, list<sobject>>();	
		map<string, GoogleCalendarAPI__c> googleApp = null;				
     	// Return the Custom Setting records
     	googleApp = GoogleCalendarAPI__c.getAll();		
		try
		{
			for (GoogleCalendarAPI__c gcApp :googleApp.values()){
				string sName = gcApp.Name;
				for(GoogleCalendarAPI__c gc :gcList){
					if (sName == gc.Name){
						string sSOQL = getSOQL(gcApp);
						string sCalendarId = gc.Google_Calendar_Id__c;

						list<sobject> c = Database.query(sSOQL);
						if(c == null){
							c = new list<sobject>();
						}
						googleCalCampaigns.put(sCalendarId, c);
					}
					
					
				}
			}
		}
		catch (exception e){
			system.debug(e.getMessage() + ' : ' + e.getStackTraceString());			
		}
		
		return(googleCalCampaigns);
		
	}

	private static string getSOQL(GoogleCalendarAPI__c gc){
	
		string sSOQL = 'Select ';
		try{
			
			string sFields = '';
			string s1 = gc.Field_Map_1__c; 
			if (string.isNotBlank(s1)){
				list<string>fldMap = s1.split(',');
				sSOQL += fldMap[0] + ',';
				fieldMap.put(fldMap[0], fldMap[1]);
			}		
			string s2 = gc.Field_Map_2__c;
			if (string.isNotBlank(s2)){
				list<string>fldMap = s2.split(',');
				sSOQL += fldMap[0] + ',';
				fieldMap.put(fldMap[0], fldMap[1]);
			}			
			string s3 = gc.Field_Map_3__c;
			if (string.isNotBlank(s3)){
				list<string>fldMap = s3.split(',');
				sSOQL += fldMap[0] + ',';
				fieldMap.put(fldMap[0], fldMap[1]);
			}	
			string s4 = gc.Field_Map_4__c;
			if (string.isNotBlank(s4)){
				list<string>fldMap = s4.split(',');
				sSOQL += fldMap[0] + ',';
				fieldMap.put(fldMap[0], fldMap[1]);
			}	
			string s5 = gc.Field_Map_5__c;
			if (string.isNotBlank(s5)){
				list<string>fldMap = s5.split(',');
				sSOQL += fldMap[0] + ',';
				fieldMap.put(fldMap[0], fldMap[1]);
			}	
			string s6 = gc.Field_Map_6__c;
			if (string.isNotBlank(s6)){
				list<string>fldMap = s6.split(',');
				sSOQL += fldMap[0] + ',';
				fieldMap.put(fldMap[0], fldMap[1]);
			}	
			string s7 = gc.Field_Map_7__c;
			if (string.isNotBlank(s7)){
				list<string>fldMap = s7.split(',');
				sSOQL += fldMap[0] + ',';
				fieldMap.put(fldMap[0], fldMap[1]);
			}	
			string s8 = gc.Field_Map_8__c;
			if (string.isNotBlank(s8)){
				list<string>fldMap = s8.split(',');
				sSOQL += fldMap[0] + ',';
				fieldMap.put(fldMap[0], fldMap[1]);
			}
			// get multi field mappings
			string smf1 = gc.Multi_field_Map_1__c;
			if (string.isNotBlank(smf1)){
				list<string>fldMap1 = smf1.split('#');
				list<string>fldMap2 = fldMap1[0].split(',');
				multifieldMap.put(fldMap1[0], fldMap1[1]);
				for (string s :fldMap2){
					sSOQL += s + ',';					
				}

	
			}
			string smf2 = gc.Multi_field_Map_2__c;
			if (string.isNotBlank(smf2)){
				list<string>fldMap1 = smf2.split('#');
				list<string>fldMap2 = fldMap1[0].split(',');
				for (string s :fldMap2){
					sSOQL += s + ',';
					multifieldMap.put(s, fldMap1[1]);
				}
	
			}
			sSOQL = sSOQL.removeEnd(',');
			sSOQL += ' from Campaign where ' + gc.Where_Clause__c;
		}
		catch (exception e){
			
			system.debug(e.getMessage() + ' : ' + e.getStackTraceString());
			
		}							
		return sSOQL;
	}
	
	// If a custom setting record does not have a Google calendar Id, makes a callout to retrieve 
	// calendar ids and updates all custom setting records (should only happen once or when a new custom setting record 
	// is introduced)

	private static void updateCalendarId(List<GoogleCalendarAPI__c> gcList){
		
		string sResponse = '';
		string sCalendarId = '';
		string sCalendarName = '';
		boolean bFound = false;
		string sURL = 'https://www.googleapis.com/calendar/v3/users/me/calendarList';
		string sMethod = 'GET';
		
		sResponse = doAPICall('', sMethod, sURL, gcList[0]);
		map<string, string> gcIdMap = new map<string, string>();
		//response comes back as a JSON string
        JSONParser parser = JSON.createParser(sResponse);
        while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)){
                string fieldName = parser.getText();
                parser.nextToken();
                
                if(fieldName == 'id') {
                    sCalendarId = parser.getText();
                }
                else if(fieldName == 'summary'){
                    sCalendarName = parser.getText();
                }
                if (sCalendarName.length() >0 && sCalendarId.length() >0){
					gcIdMap.put(sCalendarName, sCalendarId);
					sCalendarName = '';
					sCalendarId = '';
                }
            }
        }
		for (GoogleCalendarAPI__c gc :gcList){
        	for (string sKey :gcIdMap.keySet()){
	        	if (gc.Calendar_Name__c == sKey){
	        		gc.Google_Calendar_Id__c = gcIdMap.get(sKey);
	        		bFound = true;
	        		break;
	        	}
        	}
        }
        if (bFound){
        	update gcList;
        }
	}

    private static string doAPICall(String sPostBody, String sMethod, String sEndPoint,
    									GoogleCalendarAPI__c googleApp){
		string sReturn = '';
  		
  		if (iCallOutNum >= limits.getLimitCallouts()){
  			if (!bRepeat){
				String str = system.now().addMinutes(1).format('ss mm HH dd MM ? yyyy');
				System.schedule('Google Calendar API - Calendar Events Callout Batch' + str, str , new ScheduleUpdateGoogleCalendars(3));				
  				bRepeat = true;
			}
  			return '';
  		}
 		datetime dtExpires = null;
 		string sAccessToken = '';
 
 		if (googleApp != null){
 			dtExpires = googleApp.Expires__c;
 			if (dtExpires.addMinutes(1) < system.now()){
 				getNewToken(googleApp, null);
 			}
 			sAccessToken = googleApp.Token__c;
 		}
        try { 
	        HttpRequest req = new HttpRequest();
	        Http http       = new Http();
	        HttpResponse res;

	        
	        req.setEndpoint(sEndPoint);
	        req.setMethod(sMethod);
	        req.setHeader('Content-Type','application/json');
	      
	        if(sMethod == 'POST' || sMethod == 'PUT'){
	            req.setBody(sPostBody);
	        }
	        
	        if(sAccessToken.length() == 0){
	           // no header 
	        } else {
	        	req.setHeader('Authorization','Bearer ' + sAccessToken);
	        }
	        iCallOutNum ++;
	
	        res = http.send(req);
	
	        sReturn = res.getBody();  
	
			/*** Debug Code
			//get the list of header names (keys)
			List<string> headerkeys = res.getHeaderKeys();
			  
			//create an object to store your header key-value pairs
			 map<string, string> headers = new map<string, string>();
			 
			//iterate through they keys, and populate your map
			for(string s : headerkeys){
				if (s != null){
					headers.put(s,res.getHeader(s));
				
					system.debug('header: ' + s + ' value: ' + res.getHeader(s));
				}
			}
			system.debug(res.getBody());		
			***/		
        }
        catch (exception e){
			system.debug(e.getMessage() + ' : ' + e.getStackTraceString());	        	
        }
        
        return sReturn;
    }

    // Method to get the new AccessToken using the refresh Token, used by Batch jobs.
    public static void getNewToken(GoogleCalendarAPI__c googleAppIn, List<GoogleCalendarAPI__c> googleAppList){
        
        string sAccessToken = '';
        string sRefreshToken = '';
        string sMsg = '';
        integer iExpiresIn = 0;
        GoogleCalendarAPI__c googleApp = null;
        
        if (googleAppList != null){
        	googleApp = googleAppList[0];
        } else {
        	googleApp = googleAppIn;
        }

        string sAccountId = googleApp.Calendar_Account_Id__c;
        Map<string, GoogleCalendarAPI__c> googleAppMap = null;
		    
		string sPostBody =  'client_id=' +  googleApp.Client_Id__c+ 
							'&client_secret=' + googleApp.Client_Secret__c + 
							'&refresh_token=' + googleApp.Refresh_Token__c +
							'&grant_type=refresh_token';        
		try{
				
			HttpResponse testResponse; // for Testing  	       
	        Http h          = new Http();
	        HttpRequest req = new HttpRequest();
	        HttpResponse res;
	        
	        req.setEndpoint(TOKEN_URL);
	        req.setMethod('POST');
	        req.setBody(sPostBody);
	        
            res = h.send(req);
      
	        string sResp = res.getBody();

		/** Debug Code
		//get the list of header names (keys)
		List<string> headerkeys = res.getHeaderKeys();
		  
		//create an object to store your header key-value pairs
		 map<string, string> headers = new map<string, string>();
		 
		//iterate through they keys, and populate your map
		for(string s : headerkeys){
			if (s != null){
				headers.put(s,res.getHeader(s));
			
				system.debug('header: ' + s + ' value: ' + res.getHeader(s));
			}
		}
		system.debug(res.getBody());		
		*/	

	        //response comes back as a JSON string
	        JSONParser parser = JSON.createParser(sResp);
	        while (parser.nextToken() != null) {
	            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)){
	                string fieldName = parser.getText();
	                parser.nextToken();
	                if(fieldName == 'access_token') {
	                    sAccessToken = parser.getText();
	                }
	                else if(fieldName == 'expires_in'){
	                    iExpiresIn = parser.getIntegerValue();
	                }
	                else if(fieldName == 'refresh_token'){
	                    sRefreshToken = parser.getText();
	                }
	                else if(fieldName == 'error'){
	                	sMsg = parser.getText();
	                }
	            }
	        }

	        if (sAccessToken.length()>0){
		        googleAppMap = GoogleCalendarAPI__c.getAll();
		        for (GoogleCalendarAPI__c gc :googleAppMap.values()){
		 			if(gc.Calendar_Account_Id__c == sAccountId){
		 				gc.Token__c = sAccessToken;
		 				gc.Expires__c    = system.now().addSeconds(iExpiresIn);
		 			}
		        }
				update googleAppMap.values();		        
	        }
		}
		
		catch(exception e){
			system.debug(e.getMessage() + ' : ' + e.getStackTraceString());				
		}
    }



	private static void deleteEvents(map<string, list<sobject>> googleCalCampaigns){
		
		try
		{
			string sGetEventsUrl = 'https://www.googleapis.com/calendar/v3/calendars/calendarId/events';
			string sDeleteEventsURL = 'https://www.googleapis.com/calendar/v3/calendars/calendarId/events/eventId';
			string sPostBody = '';
			string sMethod = '';
			string sResponse = '';
						
			for (string sCalendarId :googleCalCampaigns.keySet()){
				sGetEventsUrl = sGetEventsUrl.replace('calendarId', sCalendarId);
				sDeleteEventsURL = sDeleteEventsURL.replace('calendarId', sCalendarId);
				map<string, GoogleCalendarAPI__c> googleApp = null;				
     			// Return the Custom Setting records
     			googleApp = GoogleCalendarAPI__c.getAll();		
				for (GoogleCalendarAPI__c gc : googleApp.Values()){
					if (gc.Google_Calendar_Id__c == sCalendarId){	
						sMethod = 'GET';
						sResponse = doAPICall(sPostBody, sMethod, sGetEventsUrl,gc);
						list<string> eventIds = new list<string>();
				        //response comes back as a JSON string
				        JSONParser parser = JSON.createParser(sResponse);
				        while (parser.nextToken() != null) {
				            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)){
				                string fieldName = parser.getText();
				                parser.nextToken();
				                if(fieldName == 'id') {
				                    string sEventId = parser.getText();
				                    eventIds.add(sEventId);
				                }					
							}
						}
						for(string sEventId :eventIds){
							string sURL = sDeleteEventsURL.replace('eventId', sEventId);							
							sMethod = 'DELETE';
							sPostBody = '';
							sResponse = doAPICall(sPostBody, sMethod, sURL,gc);	
						}
					}
				}
			
			
			}
		}
		catch (exception e){
			system.debug(e.getMessage() + ' : ' + e.getStackTraceString());			
		}
		
	}

	private static void writeEvents(map<string, list<sobject>> googleCalCampaigns){
		
		try
		{

			string sInsertEventsUrl = 'https://www.googleapis.com/calendar/v3/calendars/calendarId/events';
			string sPostBody = '';
			string sMethod = '';
			string sResponse = '';
			string sQuote = '"';
						
			for (string sCalendarId :googleCalCampaigns.keySet()){
				string sUrl = sInsertEventsUrl.replace('calendarId', sCalendarId);
				map<string, GoogleCalendarAPI__c> googleApp = null;				
     			// Return the Custom Setting records
     			googleApp = GoogleCalendarAPI__c.getAll();		
				for (GoogleCalendarAPI__c gc : googleApp.Values()){
					if (gc.Google_Calendar_Id__c == sCalendarId){				
						list<sobject> campList = googleCalCampaigns.get(sCalendarId); 
						if  (campList.size() > 0){
							for (sobject camp :campList){
								String campaignJSON = '';

								campaignJSON = '{' + '\r\n';
								string sEnd = fieldMap.get('EndDate').trim();
								boolean bDate = false;
								string sValue = '';
								date dtValue = null;
								if (string.isNotBlank(sEnd)){
									dtValue = date.valueOf(camp.get('EndDate'));
									if (dtValue != null)
										sValue = string.valueOf(dtValue);
									if (string.isNotBlank(sValue))
										bDate = true;
									campaignJSON += sQuote + sEnd + sQuote + ':' + '\r\n';
									campaignJSON += '{' + '\r\n';
									campaignJSON += sQuote + 'date' + sQuote + ':' + sQuote + sValue + sQuote + '\r\n';
									campaignJSON += '},' + '\r\n';
								}
								string sStart = fieldMap.get('StartDate').trim();
								if (string.isNotBlank(sEnd)){
									dtValue = date.valueOf(camp.get('StartDate'));
									if (dtValue != null)
										sValue = string.valueOf(dtValue);
									if (string.isNotBlank(sValue))
										bDate = true;
									campaignJSON += sQuote + sStart + sQuote + ':' + '\r\n';
									campaignJSON += '{' + '\r\n';
									campaignJSON += sQuote + 'date' + sQuote + ':' + sQuote + sValue + sQuote + '\r\n';
									campaignJSON += '},' + '\r\n';
								}								
								if (bDate){
									for (string sField :fieldMap.keySet()){
										sValue = string.valueOf(camp.get(sField.trim()));									
										if (string.isNotBlank(sValue)){
											if (sField.trim() == 'StartDate' || sField.trim() == 'EndDate'){
												// do nothing - already processed
											} else {
												campaignJSON += sQuote + fieldMap.get(sField).trim() + sQuote + ':' + sQuote + sValue + sQuote +','  + '\r\n'; 
											}
										}
									}
									sValue = '';
									for (string sField :multifieldMap.keySet()){
										list<string> sFldSplit = sField.split(','); 
										for (string sFld :sFldSplit){
											sValue += sFld + ' = ' + string.valueOf(camp.get(sFld.trim()) + ' | ');
										}
									
										if (string.isNotBlank(sValue)){
											campaignJSON += sQuote + multifieldMap.get(sField).trim() + sQuote + ':' + sQuote + sValue + sQuote +','  + '\r\n'; 
										}
									}									
									campaignJSON = campaignJSON.removeEnd(',\r\n');
									campaignJSON += '\r\n' + '}';
system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    JSON !!!!!!!!!! ...  ' + campaignJSON);	
									sResponse = doAPICall(campaignJSON, 'POST', sUrl,gc);								
								}
								
							}
							
							
						}
						
					}
				}
			}
			
		}
		
		catch (exception e){
			system.debug(e.getMessage() + ' : ' + e.getStackTraceString());			
		}
		
	}



	/***************************************/
	/*********TEST METHODS *****************/
	/***************************************/
		
	private static TestMethod void Test_Authorization() {

		PageReference pageRef = page.verifyGoogleApp;
		GoogleCalendarAPI  controller = new GoogleCalendarAPI();	
	
        //custom settings
        GoogleCalendarAPI__c cs = new GoogleCalendarAPI__c();
        cs.Name = 'Test Calendar';
        cs.Calendar_Account_Id__c = 'test@test.com';
        cs.Client_Id__c = '12345';
        cs.Client_Secret__c = 'ABCDE';
        cs.Code__c = '';
        cs.Expires__c = system.now().addMinutes(5);
        cs.Field_Map_1__c = '';
        cs.Field_Map_2__c = '';
        cs.Field_Map_3__c = '';
        cs.Google_Calendar_Id__c = '';
        cs.Calendar_Name__c = 'Test Calendar';
        cs.Multi_Field_Map_1__c = '';
        cs.Notification_Email__c = '';
        cs.Publish__c = true;
        cs.Refresh_Token__c = 'AABBCC';
        cs.Retrieve_Token__c = true;
        cs.Token__c = '';
        cs.Where_Clause__c = '';
        
        
        insert cs;
        				
        // Set mock callout class 
        test.setMock(HttpCalloutMock.class, new MockGCalendarAPI());

     			
		test.startTest();
		test.setCurrentPageReference(pageRef);
		controller.retrieveCode();
		pageRef.getParameters().put('code','testcode');	
		controller.retrieveToken();
		
		cs = [Select token__c from GoogleCalendarAPI__c where Name = 'Test Calendar'];
		
		system.assertEquals(cs.token__c, 'test_token_from_MockGCalendarAPI_class');
		test.stopTest();
		
	}
 	
	private static testMethod void Test_GetNewToken(){

        //custom settings
        GoogleCalendarAPI__c cs = new GoogleCalendarAPI__c();
        cs.Name = 'Test Calendar';
        cs.Calendar_Account_Id__c = 'test@test.com';
        cs.Client_Id__c = '12345';
        cs.Client_Secret__c = 'ABCDE';
        cs.Code__c = '';
        cs.Expires__c = system.now().addMinutes(5);
        cs.Field_Map_1__c = '';
        cs.Field_Map_2__c = '';
        cs.Field_Map_3__c = '';
        cs.Google_Calendar_Id__c = '';
        cs.Calendar_Name__c = 'Test Calendar';
        cs.Multi_Field_Map_1__c = '';
        cs.Notification_Email__c = '';
        cs.Publish__c = true;
        cs.Refresh_Token__c = 'AABBCC';
        cs.Retrieve_Token__c = true;
        cs.Token__c = 'START_TOKEN';
        cs.Where_Clause__c = '';
        
        
        insert cs;
        				
        // Set mock callout class 
        test.setMock(HttpCalloutMock.class, new MockGCalendarAPI());

     			
		test.startTest();	
		
		GoogleCalendarAPI.getNewToken(cs, null);
		cs = [Select token__c from GoogleCalendarAPI__c where Name = 'Test Calendar'];
		
		system.assertEquals(cs.token__c, 'test_token_from_MockGCalendarAPI_class');		
		
		test.stopTest();	

	} 

	private static testmethod void Test_UpdateCalendars_Ids(){

       //custom settings
        GoogleCalendarAPI__c cs = new GoogleCalendarAPI__c();
        cs.Name = 'Test Calendar';
        cs.Calendar_Account_Id__c = 'test@test.com';
        cs.Client_Id__c = '12345';
        cs.Client_Secret__c = 'ABCDE';
        cs.Code__c = '';
        cs.Expires__c = system.now().addMinutes(5);
        cs.Field_Map_1__c = 'Name, Summary';
        cs.Field_Map_2__c = 'StartDate, start';
        cs.Field_Map_3__c = 'EndDate, end';
        cs.Google_Calendar_Id__c = '';
        cs.Calendar_Name__c = 'Test Calendar';
        cs.Multi_Field_Map_1__c = 'Status,Type#description';
        cs.Notification_Email__c = '';
        cs.Publish__c = true;
        cs.Refresh_Token__c = 'AABBCC';
        cs.Retrieve_Token__c = true;
        cs.Token__c = 'START_TOKEN';
        cs.Where_Clause__c = '';

        insert cs;
        				
        // Set mock callout class 
        test.setMock(HttpCalloutMock.class, new MockGCalendarAPI());
 			
		test.startTest();	
		list<sobject> testList = new list<sobject>();
		testList.add(cs);
		GoogleCalendarAPI.updateCalendars(testList, true);
		cs = [Select Google_Calendar_Id__c from GoogleCalendarAPI__c where Name = 'Test Calendar'];
		
		system.assertEquals(cs.Google_Calendar_Id__c, 'mockcalendarid');		
		
		test.stopTest();			
		
	}

	private static testmethod void Test_UpdateCalendars_Events(){

       //custom settings
        GoogleCalendarAPI__c cs = new GoogleCalendarAPI__c();
        cs.Name = 'Test Calendar';
        cs.Calendar_Account_Id__c = 'test@test.com';
        cs.Client_Id__c = '12345';
        cs.Client_Secret__c = 'ABCDE';
        cs.Code__c = '';
        cs.Expires__c = system.now().addMinutes(5);
        cs.Field_Map_1__c = 'Name, summary';
        cs.Field_Map_2__c = 'StartDate, start';
        cs.Field_Map_3__c = 'EndDate, end';
        cs.Google_Calendar_Id__c = 'mockcalendarid';
        cs.Calendar_Name__c = 'Test Calendar';
        cs.Multi_Field_Map_1__c = 'Status,Type#description';
        cs.Multi_Field_Map_2__c = 'Description#description';
        cs.Notification_Email__c = '';
        cs.Publish__c = true;
        cs.Refresh_Token__c = 'AABBCC';
        cs.Retrieve_Token__c = true;
        cs.Token__c = 'START_TOKEN';
        cs.Where_Clause__c = 'IsActive=true and Master__c = false';

        insert cs;
        campaign c = new Campaign(Name='Test Campaign1',StartDate=system.now().date().addDays(1),
        												EndDate=system.now().date().addDays(2),
        												IsActive=true,Description='Testing1',Status='Planned',
        												Location__c='Somewhere',Public_Event__c=true,Master__c=false);
		insert c;        												
        // Set mock callout class 
        test.setMock(HttpCalloutMock.class, new MockGCalendarAPI());
 			
		test.startTest();	
		list<sobject> testList = new list<sobject>();
		testList.add(cs);
		GoogleCalendarAPI.updateCalendars(testList, false);
		cs = [Select Google_Calendar_Id__c from GoogleCalendarAPI__c where Name = 'Test Calendar'];
	
		test.stopTest();
	}
	
}