global class StreetContactMapController {
    
    public StreetContactMapController() {

    }

	@RemoteAction
  	global static String getMapPoint(String url, string sAddress,  string sLnglat) {
        Http h = new Http();

        // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('GET');
        
        // Send the request, and return a response
        HttpResponse res = h.send(req);       
        //return res.getBody();
        string sBody = res.getBody();
        string sReturn = getLocalAuthority(sBody); 
system.debug('@@@ sBody  ' + sBody);        
        string sMsg = '';
        sReturn = sReturn + '^' + sMsg;
        
        string sWard = getWard(sBody);
        string sBorough = getBorough(sBody); 
              
        sReturn = sReturn + '^'  + sWard + '^' + sBorough;
        
        string sLSOA = getOA(sBody, 'OLF');
        
        string sMSOA = getOA(sBody, 'OMF');
        
        sReturn = sReturn + '^' + sLSOA + '^' + sMSOA; 
        
        string wardCode = getWardCode(sBody);
        
        sReturn = sReturn + '^' + wardCode;
                
        return sReturn;
    }


    private static string getOA(string sJSON, string sType){

        JSONParser parser = JSON.createParser(sJSON);
        string sValue = '';
        string sName = '';
        string sCode = '';

        while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)){
                string fieldName = parser.getText();               
                parser.nextToken();
                if(fieldName == 'ons') {
                    sCode = parser.getText();
                }
                else if(fieldName == 'name'){
                    sName = parser.getText();
                } else if (fieldName == 'type'){
                    string sTemp = parser.getText();
                    if (sTemp == sType){
                        break;
                    } 
                }
            
            }
        }
        sValue = sName + '^' + sCode;
        return sValue;
    }
            
    private static string getWard(string sJSON){
        
        JSONParser parser = JSON.createParser(sJSON);
        string sValue = '';
        string sQuote = '"';
        boolean found  = false;

        while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)){
                string fieldName = parser.getText();               
                parser.nextToken();
                if(fieldName == 'name') {
                    string sTemp = parser.getText();
                    sValue = sTemp;
                }
                else if(fieldName == 'type'){
                    string sTemp2 = parser.getText();
                    if (sTemp2 == 'LBW'){
                        found = true;
                        break;
                    } 
                }
            
            }
        }

        if (!found){
            sValue = '';
        }
        return sValue;      
    
    }

   private static string getWardCode(string sJSON){
        
        JSONParser parser = JSON.createParser(sJSON);
        string sValue = '';
        string sQuote = '"';
        boolean found  = false;

        while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)){
                string fieldName = parser.getText();               
                parser.nextToken();
                if(fieldName == 'gss') {
                    string sTemp = parser.getText();
                    sValue = sTemp;
                }
                else if(fieldName == 'type'){
                    string sTemp2 = parser.getText();
                    if (sTemp2 == 'LBW'){
                        found = true;
                        break;
                    } 
                }
            
            }
        }

        if (!found){
            sValue = '';
        }
        return sValue;      
    
    }
    
    private static string getBorough(string sJSON){

        JSONParser parser = JSON.createParser(sJSON);
        string sValue = '';
        string sQuote = '"';
        boolean found  = false;

        while (parser.nextToken() != null) {
            if (found)
                break;
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)){
                string fieldName = parser.getText();               
                parser.nextToken();
                if(fieldName == 'name') {
                    string sTemp = parser.getText();
                    sValue = sTemp;
                    integer pos1 = sValue.indexOf(' ');
                    if (pos1 > -1){
                        sValue = sValue.subString(0, pos1);
                    }
                }
                else if(fieldName == 'type'){
                    string sTemp2 = parser.getText();
                    if (sTemp2 == 'LBO'){
                        found = true;
                    } 

                }
            
            }
        }
           
        if (!found){
            sValue = '';
        }
        return sValue; 
    }

    
    private static string getLocalAuthority(string sJSON){

        JSONParser parser = JSON.createParser(sJSON);
        string sValue = '';
        string sQuote = '"';

        map <string, string> LACodes = new map <string, string>();
        LACodes.put('UTA', 'UTA');
        LACodes.put('DIS', 'DIS');
        LACodes.put('LBO', 'LBO');
        LACodes.put('MTD', 'MTD');

        while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)){
                string fieldName = parser.getText();               
                parser.nextToken();
                if(fieldName == 'name') {
                    string sTemp = parser.getText();
                    if (sTemp.containsIgnoreCase('Council')){
                        sValue = sTemp;
                    }
                }
                else if(fieldName == 'type'){
                    string sTemp2 = parser.getText();
                    if (LACodes.containsKey(sTemp2)){
                        break;
                    } 
                }
            
            }
        }
        return sValue;
    }

    
}