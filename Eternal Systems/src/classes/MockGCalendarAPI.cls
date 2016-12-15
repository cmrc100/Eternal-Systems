/**
Google Calendar API Mock HTTP Response generator used only for testing.
 */
@isTest
global class MockGCalendarAPI implements HttpCalloutMock{

  // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
     	
     	HttpResponse res = new HttpResponse();
     	string sBody = '';
     	string sQuote = '"';
     	string sEndPoint = req.getEndpoint();
	    
	    if (sEndPoint.contains('https://accounts.google.com/o/oauth2/token')){
	        // Create a fake response
	        res = new HttpResponse();
			sBody = '{';
  			sBody += sQuote + 'access_token' + sQuote + ' : ' +  sQuote + 'test_token_from_MockGCalendarAPI_class' + sQuote + ',';
  			sBody += sQuote + 'token_type' + sQuote + ' : ' + sQuote +  'Bearer' + sQuote + ',';
  			sBody += sQuote + 'expires_in' + sQuote + ' : ' +  '3600';
			sBody += '}';
	        res.setHeader('Content-Type', 'application/json');
	        res.setBody(sBody);
	        res.setStatusCode(200);    		
     	}
	    if (sEndPoint.endsWith('/events') && req.getMethod() == 'GET'){
	        // Create a fake response
	       	res = new HttpResponse();
			sBody = '{';
 			sBody += sQuote + 'kind' +sQuote + ':'  + sQuote + 'calendar#events' + sQuote + ',';
 			sBody += sQuote + 'summary' +sQuote + ':' +sQuote + 'Test Calendar' +sQuote + ',';
 			sBody += sQuote + 'items' + sQuote + ':' + '[';
  			sBody += '{';
   			sBody += sQuote + 'id' +sQuote + ':' +sQuote + 'mockcalendareventid' +sQuote + ',';
   			sBody += sQuote + 'summary' +sQuote + ':' +sQuote + 'Test Event' +sQuote;
			sBody += '}]}';
			res.setBody(sBody);
	        res.setHeader('Content-Type', 'application/json');
	        res.setStatusCode(200);    		
     	}
	    if (sEndPoint.endsWith('/events') && req.getMethod() == 'POST'){
	        // Create a fake response
	       	res = new HttpResponse();
			sBody = '';
	        res.setHeader('Content-Type', 'application/json');
	        res.setStatusCode(200);    		
     	}     	
     	if (sEndPoint.endsWith('events/')){
	        // Create a fake response
	        // Create a fake response
	       	res = new HttpResponse();
	       	sBody = '';
	        res.setHeader('Content-Type', 'application/json');
	        res.setStatusCode(200);   
     	}
     	if (sEndPoint.contains('https://www.googleapis.com/calendar/v3/users/me/calendarList')){
	        // Create a fake response
	        res = new HttpResponse();
			sBody = '{';
 			sBody += sQuote + 'kind' +sQuote + ':'  + sQuote + 'calendar#calendarList' + sQuote + ',';
 			sBody += sQuote + 'items' + sQuote + ':' + '[';
  			sBody += '{';
   			sBody += sQuote + 'id' +sQuote + ':' +sQuote + 'mockcalendarid' +sQuote + ',';
   			sBody += sQuote + 'summary' +sQuote + ':' +sQuote + 'Test Calendar' +sQuote;
			sBody += '}]}';
	        res.setHeader('Content-Type', 'application/json');
	        res.setBody(sBody);
	        res.setStatusCode(200);
     	}
     	
        return res;

    }
}