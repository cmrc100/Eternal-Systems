public with sharing class OPMUtil {

    // Global JSON generator
    private static JSONGenerator gen {get; set;}

    // map to hold roles with Id as the key  
    public static Map <Id, UserRole> roleUsersMap;  
  
    // map to hold child roles with parentRoleId as the key  
    public static Map <Id, List<UserRole>> parentChildRoleMap; 
	
    //map to hold the role Id and its corresponding parent role Id
    public static Map<Id,Id> mapRoleIdParentRoleId;
	
	// list to hold roles sorted by parent 
	public static list<UserRole> sortedRoles;
	
    // List holds all subordinates  
    public static List<User> allSubordinates {get; set;}
    
    // method to populate role tree component    
    public static String getRoleTreeJSON() {
        sortedRoles = [select parentRoleId from UserRole order by parentRoleId asc];

        string roleId = sortedRoles[0].Id;
        gen = JSON.createGenerator(true);
        getAllRoles();
        if(roleUsersMap != null){
        	if (roleUsersMap.size() > 0){
		        NodeWrapper node = createNode(roleId);
		        gen.writeStartArray();
		        convertNodeToJSON(node);
		        gen.writeEndArray();
        	}
        }

        return gen.getAsString();
    } 
	
	// method to populate wrapper class used by role tree component
    private static NodeWrapper createNode(Id roleId) {
    	
    	NodeWrapper n = new NodeWrapper();

		try{    
		        n = new NodeWrapper();

		        if (!roleUsersMap.get(roleId).Users.isEmpty()) {  
		            n.myUsers = roleUsersMap.get(roleId).Users;  
		            allSubordinates.addAll(n.myUsers);  
		            n.hasUsers = true;  
		        }  	

		        n.RoleId = roleId;  
		        n.RoleName = roleUsersMap.get(roleId).Name;  
		        n.ParentId = roleUsersMap.get(roleId).ParentRoleId;  
		  
		        if (parentChildRoleMap.containsKey(roleId)){  
		            n.hasChildren = true;  
		            n.isLeafNode = false;  
		            List<NodeWrapper> lst = new List<NodeWrapper>();  
		            for (UserRole r : parentChildRoleMap.get(roleId)) {  
		                lst.add(createNode(r.Id));  
		            }             
		            n.ChildNodes = lst;  
		        }  
		        else {  
		            n.isLeafNode = true;  
		            n.hasChildren = false;  
		        }  		        
				return n;
		        
		} catch(exception e){
			system.debug(e.getMessage() + ' : ' + e.getStackTraceString());        
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));			
	
			return null;
		}	   
    }

    private static void convertNodeToJSON(NodeWrapper objNW){
        gen.writeStartObject();
      
            gen.writeStringField('title', objNW.roleName);
            gen.writeStringField('key', objNW.roleId);
            gen.writeBooleanField('unselectable', objNW.unselectable);
            gen.writeBooleanField('hideCheckbox', objNW.unselectable);
            gen.writeBooleanField('expand', true);
            gen.writeBooleanField('isFolder', true);
            

            if (objNW.hasChildren)
            {
                gen.writeFieldName('children');
                gen.writeStartArray();
                if (objNW.hasChildren)
                {
                    for (NodeWrapper wr : objNW.childNodes)
                    {
                        convertNodeToJSON(wr);
                    }
                }
                gen.writeEndArray();
            }
        gen.writeEndObject();
    }

    
   public class NodeWrapper {
    

        public String roleName {get; set;}
        
        public Id roleId {get; set;}
        
        public String parentId {get; set;}
        
        public boolean selected{get; set;}
        
        public boolean unselectable{get;set;}
        
        public string formatClass{get;set;}
        
        // Node children identifier properties - begin
        public Boolean hasChildren {get; set;}
        
        public Boolean isLeafNode {get; set;}
    
       	public Boolean hasUsers {get; set;}  
        // Node children identifier properties - end  
            
        // Node children properties - begin  
        public List<User> myUsers {get; set;}  
      
        public List<NodeWrapper> ChildNodes {get; set;}  
        // Node children properties - end     
          
        public NodeWrapper(){  
            hasUsers = false;  
            hasChildren = false; 
            unselectable = false; 
        }  
    }   

    public static void getAllRoles() {  
          
        // Create a blank list  
        allSubordinates = new List<User>();  
        
        if (sortedRoles == null)
        	sortedRoles = [select parentRoleId from UserRole order by parentRoleId asc];  
        
        // Get role to users mapping in a map with key as role id  
        roleUsersMap = new Map<Id, UserRole>([select Id, Name, parentRoleId, (select id, name from users) 
        											from UserRole order by parentRoleId]);  
          
        // populate parent role - child roles map  
        parentChildRoleMap = new map <Id, List<UserRole>>(); 
        // populate map containing role and parent id 
        mapRoleIdParentRoleId = new map <Id, Id>();          
        for (UserRole r : roleUsersMap.values()) {  
            List<UserRole> tempList;
 			mapRoleIdParentRoleId.put(r.Id, r.ParentRoleId);
            if (!parentChildRoleMap.containsKey(r.parentRoleId)){  
                tempList = new List<UserRole>();  
                tempList.Add(r);  
                parentChildRoleMap.put(r.parentRoleId, tempList);  
            }  
            else {  
                tempList = (List<UserRole>)parentChildRoleMap.get(r.parentRoleId);  
                tempList.add(r);  
                parentChildRoleMap.put(r.parentRoleId, tempList);  
            }  
        }  
    } 

	// Future method call to update Opportunity Probabilities matching
	// configuration record item	
	@future
	public static void applyUpdateFuture(list<Id> oppIds){
		applyUpdate(oppIds, null);
	}
	
	
	// Main method which contains the logic for updating opportunity probability values.
	// This method can be called from a Trigger or from the UI. Where null parameters
	// are passed, all Opportunity records are processed. This is normally a Future call.
	// When called from a trigger, the oppListIn parameter will be populated. When the
	// oppIds parameter is passed in, only the Opportunities in the list are processed.
	public static void applyUpdate(list<Id> oppIds, list<Opportunity> oppListIn){
		
		// Call static class method to retrieve required role collection variables
		getAllRoles();
		
		string sIdsSupplied = '';
		if (oppIds != null){
			sIdsSupplied = ' and Id in :oppIds';
		}
		string sSOQL = 'select Id, Name, StageName, Product_Line__c, OwnerId, Owner.UserRoleId,';
				sSOQL += 'Probability from Opportunity ';
				sSOQL += ' where StageName Not In (' + '\'' + 'Closed Won' + '\' ,' + '\'' + 'Closed Lost' + '\'  )' + sIdsSupplied ;			
		// Retrieve all open opportunities
		list<Opportunity> oppList = new list<Opportunity>();
		if (oppListIn != null){
			oppList = oppListIn;
		} else {
			oppList = Database.query(sSOQL);
		}
												
		// Put the records in a map for easy access and to avoid having to loop through them all the time
		// The key id for the map will match the composite key created for each configuration record
		map <string, list<Opportunity>> oppMap = new map<string, list<Opportunity>>();
		map <Id, string> userRoleMap;
		for (Opportunity opp :oppList){
			string sRole = opp.Owner.UserRoleId;
			if (sRole == null){
				if (userRoleMap == null){
					userRoleMap = findRole(oppList);
					sRole = userRoleMap.get(opp.OwnerId);
				} else {
					sRole = userRoleMap.get(opp.OwnerId);
				}
			} 
			string sKey = sRole + opp.StageName + opp.Product_Line__c;		
			list<Opportunity> oppitemList = oppMap.get(sKey);
			if (oppItemList == null){ // first time we've come across this key
				oppItemList = new list<Opportunity>();
			}
			oppItemList.add(opp);
			oppMap.put(sKey, oppItemList);
		}								
		
		// for each configuration record, run through the opportunity list to determine whether there
		// is a match
		list <Opportunity_Probability_Management__c> opmList = [select Probability__c, Product_Line__c, Composite_Key__c,
																	Stage__c, Role__c, Subordinates_Included__c
																	From Opportunity_Probability_Management__c
																	Where Active__c = true];
		// put records in a map for easy access..
		map <string, Opportunity_Probability_Management__c> opmMap = new map<string, Opportunity_Probability_Management__c>();
		for (Opportunity_Probability_Management__c opm :opmList){
			// we know composite key is unique, so add record to map
			opmMap.put(opm.Composite_Key__c, opm);
		}
		
		// Now loop through each of the configuration records in the map and retrieve all matching 
		// opportunity records from the opportunity map created earlier - the keys for 
		// both maps are identical
		
		//List to hold all opportunity records to eventually update
		list<Opportunity> oppUpdateList = new list<Opportunity>();
		for (string sKey :oppMap.keySet()){
			
			list<Opportunity> oppProcessList = oppMap.get(sKey);

			Opportunity_Probability_Management__c opm = opmMap.get(sKey); // get matching configuration record
			if (opm != null){ //we have some opportunity records to process!

				for (Opportunity opp :oppProcessList){
					// update probability
					opp.Probability = opm.Probability__c;
					//add record to list of records to update
					oppUpdateList.add(opp);
				}
			
			} else { // Opportunity records do not match any configuration records
				// check whether any parent exists as a configuration record which includes subordinates
				string sParentId = '';			
				string sStage = oppProcessList[0].StageName;				
				string sProductLine = oppProcessList[0].Product_Line__c;
				string sKey2 = '';
				string sRoleId = oppProcessList[0].Owner.UserRoleId;
				if(sRoleId == null){
					if (userRoleMap == null){
						userRoleMap = findRole(oppProcessList);
						sRoleId = userRoleMap.get(oppProcessList[0].OwnerId);
					} else {
						sRoleId = userRoleMap.get(oppProcessList[0].OwnerId);
					}					
				}
				do {
					sParentId = mapRoleIdParentRoleId.get(sRoleId);
					sKey2 = sParentId + sStage + sProductLine;						
					Opportunity_Probability_Management__c opmChild = opmMap.get(sKey2);
					if (opmChild != null){
						// if subordinates included .. 
						if (opmChild.Subordinates_Included__c){
							// can update opportunity records with configuration settings
							for (Opportunity opp :oppProcessList){
								// update probability
								opp.Probability = opmChild.Probability__c;
								//add record to list of records to update
								oppUpdateList.add(opp);
							}
							break;
						}
					}
					sRoleId = sParentId;
					
				} while (!string.isBlank(sParentId));	
			
			}	
		

		}
		if (oppListIn != null) { //called from trigger, therefore update list (no DML needed here)
			for (Opportunity opp1 :oppUpdateList){
				double dProb = opp1.Probability;
				for (Opportunity opp2 :oppListIn){
					if(opp2.Id == opp1.Id){
						opp2.Probability = opp1.Probability;
					}
				}
			}
				
		} else {
			// Finally update opportunity records 
			// setup the save point for rollback
			Savepoint sp = Database.setSavepoint();
			try {
				if (!oppUpdateList.isEmpty()){
					update oppUpdateList;
				}
			} catch(exception e){
				Database.rollback(sp);
				system.debug(e.getMessage() + ' : ' + e.getStackTraceString());			
			}				
		}	
	}    
	
	private static map<Id, string> findRole(list<Opportunity> oppList){
		
		map<Id, string> ownerIds = new map<Id, string>();
		
		for (Opportunity opp :oppList){
			ownerIds.put(opp.OwnerId, opp.OwnerId);
		}
		
		list<User> usrList = [Select u.UserRole.Name, u.UserRoleId From User u where u.Id in :ownerIds.keySet()];
		
		if (usrList != null){
			for (User usr :usrList){
				ownerIds.put(usr.Id, usr.UserRoleId);
			}
		}	
		
		return ownerIds;
	
	}
}