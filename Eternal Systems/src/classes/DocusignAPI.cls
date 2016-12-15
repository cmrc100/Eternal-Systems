public with sharing class DocusignAPI {

	public string userName{get;set;}
	public string password {get;set;}
	public string integrationKey {get; set;}
	public string accessToken {get; set;}
	public docusignResponse docusignResp {get; private set;}
	
	private static final string TOKEN_URL = 'https://demo.docusign.net/restapi/v2/oauth2/token';
	private static string API_URL = '';
	public boolean debugMode {get; set;}
	
	public DocusignAPI(){
		
		debugMode = false;

		accessToken = system.label.Docusign_Token;
		API_URL = system.label.Docusign_Base_Url;
	}
		
	public void getOAuthToken(){

       	string errCode = '';
		string errMsg = '';
		boolean bReturn = false;
		
		try{
			
			string sPostBody = '';
        	integer iExpiresIn = 0;
      						
			string sGrantType = 'grant_type=' + EncodingUtil.urlEncode('password', 'UTF-8');
			string sClient = '&client_id=' + EncodingUtil.urlEncode(integrationKey, 'UTF-8');
			string sUserName = '&username=' + EncodingUtil.urlEncode(userName, 'UTF-8');
			string sPassword = '&password=' + EncodingUtil.urlEncode(password, 'UTF-8');
			string sScope = '&scope=' + EncodingUtil.urlEncode('api', 'UTF-8');
	
			sPostBody = sGrantType + sClient + sUsername + sPassword + sScope;
 	       
	        Http h          = new Http();
	        HttpRequest req = new HttpRequest();
	        HttpResponse res;
	        
	        req.setEndpoint(TOKEN_URL);
	        req.setHeader('Content-type', 'application/x-www-form-urlencoded');
	        req.setHeader('Accept', 'application/json');
	        req.setMethod('POST');
	        req.setBody(sPostBody);
	        
            res = h.send(req);
      
	        string sResp = res.getBody();		
			
			if (debugMode){
				debugCall(req, res);
			}
			
	        //response comes back as a JSON string
	        JSONParser parser = JSON.createParser(sResp);
	        while (parser.nextToken() != null) {
	            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)){
	                string fieldName = parser.getText();
	                parser.nextToken();
	                if(fieldName == 'access_token') {
	                    accessToken = parser.getText();
	                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Access Token retrieved, ' + accessToken));
	                	break;
	                }
	            }
	        }
	        
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,sResp));
		} catch (exception e){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Internal Failure to retrieve Access Token  :  error returned is : ' + e.getMessage() + ' - ' + e.getStackTraceString()));

		}
		
		
	}


	// This is the main function used for all API calls (other than token/authorization requests)
	// all retry and error handling logic is contained in this method
	private boolean makeCall(string sMethod, string sUrl, string sJson){
		
		string errCode = '';
		string errMsg = '';
		integer httpStatus = 0;
		string sResp = '';
		
		docusignResp = new docusignResponse();
		boolean bReturn = false;
				
		try{
 	       
	        Http h          = new Http();
	        HttpRequest req = new HttpRequest();
	        HttpResponse res;
		        
	        req.setEndpoint(sUrl);
	        req.setHeader('Authorization', 'Bearer ' + accessToken);

	        req.setHeader('Content-type', 'application/json');
	        req.setMethod(sMethod);
	        if (!string.isBlank(sJson)){
	        	req.setBody(sJson);
	        }
	        
            res = h.send(req);			
		    sResp = res.getBody();
			httpStatus = res.getStatusCode();

			if (debugMode){
				debugCall(req, res);
			}

	        docusignResp.jsonResponse = sResp;
	        docusignResp.httpStatusCode = httpStatus;
	        
	        if (httpStatus != 200 && httpStatus != 201){

		        //response comes back as a JSON string
		        JSONParser parser = JSON.createParser(sResp);
		        while (parser.nextToken() != null) { // Check for further error details in message body
		            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)){
		                string fieldName = parser.getText();
		                parser.nextToken(); 
	
		                if(fieldName == 'errorCode'){
		                	errCode = parser.getText();
		                }
		                if (fieldName == 'message'){
		                	errMsg = parser.getText();
		                }
		            }
		        }
		        if (string.isBlank(errCode)){ // No error details in message body, therefore use header values
		        	errCode = string.valueOf(res.getStatusCode());
		        	errMsg = res.getStatus();
		        }
	        }
	        
		    if (!string.isBlank(errCode)){ // check for API errors and handle gracefully.
		    	docusignResp.errCode = errCode;	
		    	docusignResp.errDescription = errMsg;
		    	docusignResp.errSource = 'Docusign API - ' + sUrl;
		    	bReturn = false;
		    } else { // no errors
		    	bReturn = true; //success!	
		    }
		        			
			return bReturn;	
			
		} catch (exception e){
			system.debug(e.getMessage() + ' : ' + e.getStackTraceString());
			bReturn = false;
			docusignResp.errCode = 'INT-001';
			docusignResp.errDescription = e.getMessage() + ' : ' + e.getStackTraceString();
			docusignResp.errSource = 'Internal';
			return bReturn;
		}
				
	}

	// Object exposed to user, detailing callout result including full response json if appropriate
	// and any API error details. This object is updated after each API call.	
	public class docusignResponse{
		
		public string errCode{get;private set;}
		public string errDescription {get;private set;}
		public string errSource {get;private set;}
		public integer httpStatusCode {get;private set;}
		public string jsonResponse {get;private set;}	
		
		public docusignResponse(){
			errCode = '';
			errDescription = '';
			errSource = '';
			httpStatusCode = 0;
			jsonResponse = '';
		}
	}

	// debug method to log message details, only used where debugMode set to true.
	private void debugCall(HttpRequest req, HttpResponse res){
		
		system.debug(req.getBody());
		system.debug('HTTP STATUS ...  ' + res.getStatusCode());	
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
	}			


	// Method exposing the get folders list docusign API function
	public boolean getEnvelopes(string sSearch){
		
		boolean bReturn = true;
		string sMethod = 'GET';
		string s = '';
		
		if (string.isBlank(sSearch)){
			sSearch = '?from_date=5-5-2013';
		} else {
			sSearch = '?' + sSearch;
		}
		
		string sURL = API_URL + '/envelopes' + sSearch;
		bReturn = makeCall(sMethod, sURL, null);
							
		return bReturn;
		
	}

	// Method exposing the get envelope custom field docusign API function
	public boolean getEnvelopeCustomField(string envelopeId){
		
		boolean bReturn = true;
		string sMethod = 'GET';
		
		string sURL = API_URL + '/envelopes/' + envelopeId + '/custom_fields';
		bReturn = makeCall(sMethod, sURL, null);
							
		return bReturn;
	}

}