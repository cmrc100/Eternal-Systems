/**
Docusign API Mock HTTP Response generator used only for testing.
 */
@isTest
global class MockDocusignAPI implements HttpCalloutMock {

  	// Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
     	
     	HttpResponse res = new HttpResponse();
     	string sBody = '';
     	string sQuote = '"';
     	string sEndPoint = req.getEndpoint();
     	string sToken = req.getHeader('Authorization');
     	if (string.isBlank(sToken)){
     		sToken = '';
     	}
	    string sMethod = req.getMethod();
	    if (string.isBlank(sMethod)){
	    	sMethod = '';
	    }
	    string sReqBody = req.getBody();
	    if (string.isBlank(sReqBody)){
	    	sReqBody = '';
	    }
    
	    if (sEndPoint.contains('https://demo.docusign.net/restapi/v2/oauth2/token')){
	        // Create a fake response
	        res = new HttpResponse();
			sBody = '{';
  			sBody += sQuote + 'access_token' + sQuote + ' : ' +  sQuote + 'test_token_from_MockDocusignAPI_class' + sQuote ;
			sBody += '}';
	        res.setHeader('Content-Type', 'application/json');
	        res.setBody(sBody);
	        res.setStatusCode(200);    		
     	}	

	    if (sEndPoint.contains('envelopes')){
	        // Create a fake response
	        res = new HttpResponse();
			sBody = '{';
  			sBody += sQuote + 'status' + sQuote + ' : ' +  sQuote + 'sent' +sQuote  + ',';
  			sBody += sQuote + 'envelopeId' + sQuote + ' : ' +  sQuote + '1111' +sQuote  + ',';
			sBody += sQuote + 'envelopeId' + sQuote + ' : ' +  sQuote + '2222' +sQuote  + ',';
			sBody += sQuote + 'envelopeId' + sQuote + ' : ' +  sQuote + '3333' +sQuote  + ',';
			sBody += sQuote + 'envelopeId' + sQuote + ' : ' +  sQuote + '4444' +sQuote + ',';
			sBody += sQuote + 'name' + sQuote + ' : ' +  sQuote + 'Child_SFDC_ID' +sQuote + ',';
			sBody += sQuote + 'value' + sQuote + ' : ' +  sQuote + '456789' +sQuote;
			sBody += '}';
	        res.setHeader('Content-Type', 'application/json');
	        res.setBody(sBody);
	        res.setStatusCode(200);    		
     	}

	    if (sEndPoint.contains('bulkparent')){
	        // Create a fake response
	        res = new HttpResponse();
			sBody = '{';
			sBody += sQuote + 'status' + sQuote + ' : ' +  sQuote + 'sent' +sQuote  + ',';			
  			sBody += sQuote + 'envelopeId' + sQuote + ' : ' +  sQuote + '1111' +sQuote  + ',';
			sBody += sQuote + 'envelopeId' + sQuote + ' : ' +  sQuote + '2222' +sQuote  + ',';
			sBody += sQuote + 'envelopeId' + sQuote + ' : ' +  sQuote + '3333' +sQuote  + ',';
			sBody += sQuote + 'envelopeId' + sQuote + ' : ' +  sQuote + '4444' +sQuote + ',';			
  			sBody += sQuote + 'envelopeId' + sQuote + ' : ' +  sQuote + '5555' +sQuote  + ',';
			sBody += sQuote + 'envelopeId' + sQuote + ' : ' +  sQuote + '6666' +sQuote  + ',';
			sBody += sQuote + 'envelopeId' + sQuote + ' : ' +  sQuote + '7777' +sQuote  + ',';
			sBody += sQuote + 'envelopeId' + sQuote + ' : ' +  sQuote + '8888' +sQuote + ',';
  			sBody += sQuote + 'envelopeId' + sQuote + ' : ' +  sQuote + '9999' +sQuote  + ',';
			sBody += sQuote + 'envelopeId' + sQuote + ' : ' +  sQuote + '1010' +sQuote  + ',';
			sBody += sQuote + 'envelopeId' + sQuote + ' : ' +  sQuote + '1212' +sQuote  + ',';
			sBody += sQuote + 'envelopeId' + sQuote + ' : ' +  sQuote + '1414' +sQuote + ',';
			sBody += sQuote + 'name' + sQuote + ' : ' +  sQuote + 'Child_SFDC_ID' +sQuote + ',';
			sBody += sQuote + 'value' + sQuote + ' : ' +  sQuote + '456789' +sQuote;

			sBody += '}';
	        res.setHeader('Content-Type', 'application/json');
	        res.setBody(sBody);
	        res.setStatusCode(200);    		
     	}		

	    if (sEndPoint.contains('badparent')){
	        // Create a fake response
	        res = new HttpResponse();
			sBody = '{';
  			sBody += sQuote + 'errorCode' + sQuote + ' : ' +  sQuote + '400' + sQuote + ',';
			sBody += sQuote + 'message' + sQuote + ' : ' +  sQuote + 'Server down' + sQuote ;
			sBody += '}';
	        res.setHeader('Content-Type', 'application/json');
	        res.setBody(sBody);
	        res.setStatusCode(400);    		
     	}
     	
		return res;
    }
}