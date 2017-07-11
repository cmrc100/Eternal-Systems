public with sharing class apiService {

	private static integer retryCount = 0; //keep track of attempts and stop after 3 retries 
	private static final boolean debugMode = true;

	public static string readBankList(string bankName){
		
		string endPoint = '';
		
		if (bankName == 'Barclays'){
			endPoint = 'https://atlas.api.barclays/open-banking/v1.3/branches';				
		}
		string returnString = doGet(endPoint, true);
		
		return returnString;
	}    
	
	private static string doGet(string endPoint, boolean retry){
		
		Http h = new Http();
		HttpRequest req = new HttpRequest();
		HttpResponse res;
		string responseString = '';
		
		try{
			
			string apiUrl = endPoint;

			req.setEndPoint (apiUrl);
			req.setMethod('GET');
			req.setTimeout(5000); //5 seconds
			res = h.send(req);
			
			responseString = res.getBody();
			integer httpStatus = res.getStatusCode();
			
			if (debugMode){
				debugApiCall(req, res);
			}
			
			if (httpStatus != 200){				
				responseString = 'ERROR Returned : HTTP Status Code ' + httpStatus + ', ';
				responseString += ' HTTP Error ' + res.getStatus() + ', ';
				responseString += 'Details returned ' + res.getBody(); 
				retryCount++;
                if (retry){
                    if (retryCount < 3){ //try again upto 3 times
                        system.debug( ' Current Retry Count is : ' + retryCount + ' Attempting retry of : ' + endPoint);
                        responseString = doGet(endPoint, true);
                    } else {
                        retryCount = 0;
                    }
                }    
			} else {
				responseString = res.getBody();
				retryCount = 0;
			}
			
			
		} catch (exception e){
			
            if (retryCount < 3){ //try again upto 3 times
				system.debug( ' Current Retry Count is : ' + retryCount + ' Attempting retry of : ' + endPoint);
				retryCount++;
				responseString = doGet(endPoint, retry);
			} else if (retryCount > 2){
				responseString = 'ERROR ... Internal Technical Error ' + e.getMessage();
				system.debug('ERROR ... Internal Technical Error ' + e.getMessage() + ' : ' + e.getStackTraceString());				
			} else {
            	retryCount = 0;
            }				    	   										
		}
		
		return responseString;			
	}

	private static void debugApiCall(HttpRequest req, HttpResponse res){
				
		system.debug (' **************    Debug Output Follows ***************');
		
		system.debug(req.getBody());

		//get the list of header names (keys)
		List<string> headerkeys = res.getHeaderKeys();
		  
		//create an object to store header key-value pairs
		 map<string, string> headers = new map<string, string>();
		 
		//iterate through they keys, and populate map
		for(string s : headerkeys){
			if (s != null){
				headers.put(s,res.getHeader(s));
			
				system.debug('header: ' + s + ' value: ' + res.getHeader(s));
			}
		}
		system.debug(res.getBody());		
		
		system.debug (' **************    Debug Output END ***************');			
		
		
	}
    
    private static string nullToEmptyString(string value){
        
        string returnVal = '';
        
        if (string.isBlank(value)){
            returnVal = '';
        } else {
            returnVal = value;
        }
        return returnVal;
        
    }
    
}