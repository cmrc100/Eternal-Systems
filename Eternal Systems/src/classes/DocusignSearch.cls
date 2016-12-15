global with sharing class DocusignSearch {

	static final string PARENT_FIELD = 'Parent_SFDC_ID'; //custom Docusign field name
	static final string CHILD_FIELD = 'Child_SFDC_ID'; // custom Docusign field name
	static final string SOBJECT_FIELD = 'Docusign_Status__c'; // Salesforce field to update
			
	/** This method performs 3 main functions:
	1. Retrieve any docusign envelope records associated with parent Salesforce object
	2. Retrieve associated child salesforce object ids on the envelope records 
	3. Update Salesforce child object record with envelope status
	**/ 
	
	webservice static string updateObjectDocusignStatus(string parentId, Id[] objIds, string envIds){

		string sReturn = 'Records Updated'; // default message to return to caller when proces has finished without error.
		integer iCallOuts = 0;
		boolean success  = true;
		DocusignAPI ds = null;
		
		map<string, string> envelopeMap = new map<string,string>();		
		map<string, string> objectIdMap = new map<string, string>();
		
		try{
			// check whether envIds list has been passed in. If so
			// this indicates that this another batch of records sent for processing
			// within the same original client call. The envIds list is only passed
			// back to client caller in the event of Web service callout limit being reached.
			// Client then sends the list back in a different process thread which therefore
			// overcomes the governor limit. 
			if (!string.isBlank(envIds)){
				list<string> envIdsProcess = envIds.split(',');			
				for(string s :envIdsProcess){
					list<string> envIdItem = s.split(';');
									
					if(envIdItem[0].length() > 1){
						try{
						envelopeMap.put(envIdItem[0], envIdItem[1]);
						} catch(exception e){
							
						}
					}
				}
			}
			else {
				// Instantiate API utiltity class
				ds = new DocusignAPI();
				ds.debugMode = false;
				
				// First retrieve all docusign recods associated to parent Salesforce object
				success = ds.getEnvelopes('from_date=5-5-2013&custom_field='+PARENT_FIELD + '=' +EncodingUtil.urlEncode(parentId, 'UTF-8'));		
	
				iCallOuts ++; // keep track of number of callouts made
				
				if (success){ // API call worked, process response 
					string sResp = ds.docusignResp.jsonResponse; // retrieve response from utility class wrapper object
			        JSONParser parser = JSON.createParser(sResp);
			        string sStatus = '';
			        // Extract envelope id and status, and populate map
			        while (parser.nextToken() != null) { 
			            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)){
			                string fieldName = parser.getText();
			                parser.nextToken();
			                if(fieldName == 'status') {
			                    sStatus = parser.getText();		                    
			                }
			                if(fieldName == 'envelopeId') {
			                    string sEnvelopeId = parser.getText();
			                    envelopeMap.put(sEnvelopeId, sStatus);	                   
			                }
			            }
			        }			
				} else { // API Error, handle gracefully and pass back details to caller			
					sReturn = 'An error has occurred retrieving the Docusign Status : ';
					sReturn += ds.docusignResp.errCode + ' - ' + ds.docusignResp.errDescription;
				}
			}
			
			if (envelopeMap.size() > 0){ // Associated docusign records have been found!
				// loop through envelopeId/status map and make call to retrieve custom field value
				// containing salesforce child object id				
				if (ds == null) {
				// Instantiate API utiltity class
					ds = new DocusignAPI();
				}				
				for (string envelopeId :envelopeMap.keySet()){
					string sEnvStatus = envelopeMap.get(envelopeId); // extract envelope status from map
					success = ds.getEnvelopeCustomField(envelopeId);
					iCallOuts++;
					if (success){
						string sResp = ds.docusignResp.jsonResponse;
				        JSONParser parser = JSON.createParser(sResp);
				        string sValue = '';
				        string sName = '';
				        while (parser.nextToken() != null) {
				            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)){
				                string fieldName = parser.getText();
				                parser.nextToken();
				                if(fieldName == 'name') {
				                    sName = parser.getText();		                    
				                }
				                if(fieldName == 'value') {
				                    if (sName == CHILD_FIELD){
				                    	sValue = parser.getText();
				                    	// populate map to relate object Id with envelope status found earlier
				                    	objectIdMap.put(sValue, sEnvStatus);
				                    	envelopeMap.put(envelopeId, 'PROCESSED');
				                    }	                   
				                }
				            }
				        }			
					} else { // API Error, handle gracefully and pass back details to caller					
						sReturn = 'An error has occurred retrieving the Docusign Status : ';
						sReturn += ds.docusignResp.errCode + ' - ' + ds.docusignResp.errDescription;
					}
					
					// Check whether callout limit has been reached,
					// if so, pass back string of envelope ids outstanding.
					// Caller(client) should then make another call to this function
					// passing this string of unprocessed envelopes.
					// This is a workaround for the callout governor limit 
					if (iCallouts == limits.getLimitCallouts() && envelopeMap.size() >= iCallouts){
						sReturn = '';
						for(string eId :envelopeMap.keySet()){
							string sProcessStatus = envelopeMap.get(eId);
							if(sProcessStatus != 'PROCESSED'){
								sReturn +=  eId + ';' + sProcessStatus + ',';
							}
							
						}	
						break; // stop processing to avoid callout limits error
					}					
				}
				
				// Use dynamic SOQL to find Sobject and update. This makes the solution generic and reusable for
				// any object relationship
				if(objectIdMap.size() > 0){ // envelopes mapped to salesforce objects have been found
					Set<string> keys = objectIdMap.keyset(); //put ids into a set so they can be queried
					Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
				       
				    Map<String,String> keyPrefixMap = new Map<String,String>{};
				    
				    // Use schema object and object id to find out the object name to update      
				    for(String sObj : gd.keySet()){
				      Schema.DescribeSObjectResult r =  gd.get(sObj).getDescribe();
				      keyPrefixMap.put(r.getKeyPrefix(), r.getName());
				    }
				    string objectTypeKey = '';
				    for(string s :keys){
				    	objectTypeKey = s.subString(0,3);
				    	break;	
				    }	    
				    
				    // get object name
				    string objectTypeName = keyPrefixMap.get(objectTypeKey);
				    
				    // construct dynamic SOQL string  
				    string objectQueryString = 'SELECT Id, Name, ' + SOBJECT_FIELD + '  FROM '
				                                    + objectTypeName
				                                    + ' WHERE Id in:keys';
				    if(test.isRunningTest()){ // Used only by test class
						objectTypeName = 'Opportunity';
						objectQueryString = 'SELECT Id, Name, ' + SOBJECT_FIELD + '  FROM '
				                               + objectTypeName
				                               + ' WHERE name like \'%opp-docusign%\'' ;			    	
				    }   
				                                 
   					// populate list
				    list<Sobject> objectList = Database.query(objectQueryString);
					
					if(test.isRunningTest()){ // used only by test class
						for (sobject obj :objectList){	
							obj.put(SOBJECT_FIELD, 'sent');
						}
					} else {						
						//Update each Sobject with envelope status
						for (sobject obj :objectList){						
							string sId = string.valueOf(obj.get('Id'));
							sId = sId.substring(0,15);							
							obj.put(SOBJECT_FIELD, objectIdMap.get(sId));
						}					
					}
					database.update(objectList);
					
				}
				
				
			}

			return sReturn;
		
		} catch (exception e){
			
			system.debug(e.getMessage() + ' : ' + e.getStackTraceString());
			sReturn = ' An internal error has occurred : ';
			sReturn += e.getMessage() + ' - ' + e.getStackTraceString();
			return sReturn;
		}
	
	}


}