public with sharing class AnalyticSearchController {

  	// the soql without the order
  	private String soql {get;set;}
  	private String soql2 {get;set;}
	public List<Analytic__c> analytics {get;set;}
	public List<Analytic__c> analyticsAll {get;set;}
	public Boolean dynamicSearching{get; private set;}
	public Boolean regionSelected{get; private set;}
	public Boolean areaSelected{get; private set;}
	public Boolean communitySelected{get; private set;}
	public Boolean contactSelected{get; private set;}
	public Boolean closeWindow {get;set;}
	public String selectedLayout {get; set;}
	public String selectedType {get; set;}
	public String selectedRegion {get; set;}
	public string selectedArea {get; set;}
	public string selectedCommunity {get; set;}
	public string selectedContact {get; set;}
	public string selectedFocus;
	
	// Constructor, setting up some defalt values	
	public AnalyticSearchController(){
		
		// retrieve Custom Setting (for dynamic search setting)
		DynamicReportSearching__c dynamicSearch = DynamicReportSearching__c.getValues('Value'); 
		dynamicSearching = dynamicSearch.Dynamic_Search_Switch__c;
		
		selectedLayout = '';
		selectedType = '';
		selectedRegion = '';
		selectedArea = '';
		selectedCommunity = '';
		selectedContact = '';
		selectedFocus = '';
	}
	
	public String getselectedFocus() { 
		return selectedFocus; 
	}
	

	public void setselectedFocus (String value) { 
	// set boolean values depending on selected focus (used for page rendering logic)
		selectedFocus = value;
		if (value == 'Region'){
			regionSelected = true;
			areaSelected=false; 
			selectedArea = '';
			communitySelected = false; 
			selectedCommunity = '';
			contactSelected = false;
			selectedContact = '';			
		} else if (value == 'Area') {
			areaSelected=true;
			regionSelected = true;
			selectedRegion = '';
			selectedArea = '';
			communitySelected = false; 
			contactSelected = false;
			selectedContact = '';
		} else if (value == 'Community') {
			areaSelected = true;
			regionSelected = true;
			selectedArea = '';
			selectedRegion = '';
			communitySelected = true;
			contactSelected =  false;
			selectedContact = '';
		} else if (value == 'Contact'){
			areaSelected = false;
			regionSelected = false;
			selectedArea = '';
			selectedRegion = '';
			communitySelected = false;
			selectedCommunity = '';
			contactSelected =  true;
			selectedContact = '';			
		}
	}
	
	// Extract the picklist values required from Schema
    public List<SelectOption> getLayouts(){
		
        List<SelectOption> options = new List<SelectOption>();
        List<Schema.PicklistEntry> listValues  = getAnalyticLayouts();
        for (Schema.PicklistEntry listItem :listValues){
        	options.add(new SelectOption(listItem.getLabel(), listItem.getValue()));
        }
        return options;
    }

    public List<SelectOption> getTypes(){
    	
        List<SelectOption> options = new List<SelectOption>();
        List<Schema.PicklistEntry> listValues  = getAnalyticTypes();
        for (Schema.PicklistEntry listItem :listValues){
        	options.add(new SelectOption(listItem.getLabel(), listItem.getValue()));
        }
        return options;
    }    		

	public List<SelectOption> getFocusitems(){
    	
        List<SelectOption> options = new List<SelectOption>();
        List<Schema.PicklistEntry> listValues  = getFocusPickItems();
        for (Schema.PicklistEntry listItem :listValues){
        	options.add(new SelectOption(listItem.getLabel(), listItem.getValue()));
        }
        return options;
    }    

    public List<SelectOption> getRegions(){
    	
        List<SelectOption> options = new List<SelectOption>();
        List<Region__c> listValues  =  [Select Name from Region__c];        
        for (Region__c listItem :listValues){
        	options.add(new SelectOption(listItem.Id, listItem.Name));
        }
        return options;
    } 

    public List<SelectOption> getAreas(){
    	
        List<SelectOption> options = new List<SelectOption>();
        List<Area__c> listValues  =  [Select Name from Area__c where Region__c = :selectedRegion order by Name];
        
        for (Area__c listItem :listValues){
        	options.add(new SelectOption(listItem.Id, listItem.Name));
        }
        return options;
    }     

    public List<SelectOption> getCommunities(){
    	
        List<SelectOption> options = new List<SelectOption>();
        List<Community__c> listValues  =  [Select Name from Community__c where Area__c = :selectedArea order by Name];
        
        if (selectedArea == null){
        	options =  new List<SelectOption>();
        } else {
	        for (Community__c listItem :listValues){
	        	options.add(new SelectOption(listItem.Id, listItem.Name));
	        }
        }
        return options;
    }      

    public List<SelectOption> getContacts(){
    	
        List<SelectOption> options = new List<SelectOption>();
        List<Analytic__c> listValues  =  [Select a.Contact__r.Id, a.Contact__r.Email, a.Contact__r.FirstName, a.Contact__r.LastName, 
        								a.Contact__c From Analytic__c a where a.Contact__r.Id != null  LIMIT 10000];

		options.add(new SelectOption('', ''));
        for (Analytic__c listItem :listValues){
 			string sName = listItem.Contact__r.FirstName + ' ' + listItem.Contact__r.LastName;
        	options.add(new SelectOption(listItem.Contact__r.Id, sName));
        }

        return options;
    }
    
    private static List<Schema.PicklistEntry> getAnalyticLayouts() {
        return Analytic__c.Layout__c.getDescribe().getPicklistValues();
    }
    
    private static List<Schema.PicklistEntry> getAnalyticTypes() {
        return Analytic__c.Type__c.getDescribe().getPicklistValues();
    }

    private static List<Schema.PicklistEntry> getFocusPickItems() {
        return Analytic__c.Focus__c.getDescribe().getPicklistValues();
    }
	// the current sort direction. defaults to ascending
	public String sortDir {
    get  { if (sortDir == null) {  sortDir = 'asc'; } return sortDir;  }
    set;
  	}
 
	// the current field to sort by. defaults to name
	public String sortField {
	get  { if (sortField == null) {sortField = 'Name'; } return sortField;  }
    set;
  	}
	// toggles the sorting of query from asc<-->desc
	public void toggleSort() {
	// simply toggle the direction
	sortDir = sortDir.equals('asc') ? 'desc' : 'asc';
	// run the query again
	runQuery();
	}

	// runs the actual query
	public void runQuery() {
 
		try {
				analyticsAll = Database.query(soql + ' order by ' + sortField + ' ' + sortDir);
				
				soql2 = soql + ' and highlight__c = true';
				
				analytics = Database.query(soql2 + ' order by ' + sortField + ' ' + sortDir);
											
		} catch (Exception e) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
		}
 
  }
    
	public PageReference runSearch() {
	    String slayout = selectedLayout;
	    String stype = selectedType;
	    String sfocus = selectedFocus;
	    String sregion = selectedRegion;
	    String sarea = selectedArea;
	    String scommunity = selectedCommunity;
	   	String scontact = selectedContact;

	    soql = 'Select name, layout__c, type__c, focus__c, region__c, area__c,' 
	    			+ 'community__c, contact__c, highlight__c, url__c '
	    		    + ' from Analytic__c where active__c = true ';
	    if (!string.isEmpty(selectedLayout))
	      soql += ' and layout__c LIKE \''+String.escapeSingleQuotes(selectedLayout)+'%\'';
	    if (!string.isEmpty(selectedType))
	      soql += ' and type__c LIKE \''+String.escapeSingleQuotes(selectedType)+'%\'';
	    if (!string.isEmpty(selectedFocus))
	      soql += ' and focus__c LIKE \''+String.escapeSingleQuotes(selectedFocus)+'%\'';
	    if (!string.isEmpty(selectedRegion))
	      soql += ' and region__r.Id =  \'' + selectedRegion + '\'';
	    if (!string.isEmpty(selectedArea))
	      soql += ' and area__r.Id =  \'' + selectedArea + '\'';
	    if (!string.isEmpty(selectedCommunity))
	      soql += ' and community__r.Id =  \'' + selectedCommunity + '\'';	      	        
	    if (!string.isEmpty(selectedContact))
	      soql += ' and contact__r.Id =  \'' + selectedContact + '\'';
 
	    // run the query again
	    runQuery();
	 
	    return null;		

	}
	
	public PageReference Clear(){

		selectedLayout = '';
		selectedType = '';
		selectedRegion = '';
		selectedArea = '';
		selectedCommunity = '';
		selectedContact = '';
		selectedFocus = '';	
		
		regionSelected = false;
		areaSelected = false;
		communitySelected = false;
		contactSelected = false;	
		
		analytics.clear();
		analyticsAll.clear();
		
		return null;
	}
	
	public void closeWin(){
        closeWindow = true;
    }
    
    
    
    /************************/
   	/***** TEST METHODS *****/
   	/************************/
   
   
    private static TestMethod Void Test_AnalyticSearch() {

    PageReference pageRef = Page.AnalyticSearch; 
    Test.setCurrentPage(pageRef);
    
	string rId;
	string aId;
	string commId;
	string contactId;
	string contactfocusId;
    
    // create contact
    Contact c = New Contact(FirstName='Test', Lastname='surname', Email='test@test.com');
    insert c;
    c = [Select Name, Id from Contact where FirstName='Test' and Lastname='Surname'];
    contactId = c.Id;
    
    // create Region
    Region__c r = New Region__c(Name='London');
    insert r;
    r = [Select Name, Id from Region__c where Name = 'London'];
    //create Area
    Area__c a = new Area__c(Name='Westminster', region__c = r.id);    
    insert a;
    a = [Select Name, Id from Area__c where Name = 'Westminster'];
    //create Community
    Community__c comm = new Community__c(Name='Tourists', area__c = a.id);
    insert comm;
    comm = [Select Name, Id from Community__c where Name = 'Tourists'];
 
    // create Analytic records
 	Test.startTest();    
    AnalyticSearchController searchA = new AnalyticSearchController();
    
    List<SelectOption> layouts = searchA.getLayouts();
    string sLayout = layouts[0].getValue();
    
    List<SelectOption> types = searchA.getTypes();
    string sType = types[0].getValue();
    
    List<SelectOption> regions = searchA.getRegions();
    for(SelectOption rTest :regions){
    	if (rTest.getLabel() == 'London'){
    		rId = rTest.getValue();
    		break;
    	}
    }
    
    List<SelectOption> areas = searchA.getAreas();
    for(SelectOption rTest :areas){
    	if (rTest.getLabel() == 'Westminster'){
    		aId = rTest.getValue();
    		break;
    	}
    }
    
    List<SelectOption> communities = searchA.getCommunities();
    for(SelectOption rTest :communities){
    	if (rTest.getLabel() == 'Tourists'){
    		commId = rTest.getValue();
    		break;
    	}
    }
       
    List<Analytic__c> atestList = new List<Analytic__c>();
    List<SelectOption> focusList = searchA.getFocusitems();
    List<string> nameList = new List<string>();
    Map<string, string> focusNames = new map<string, string>();
    
    Analytic__c atest = new Analytic__c();
    
    for (SelectOption sFocus :focusList){
    		
    	atest = new Analytic__c(Name='A1' + sFocus.getLabel(), layout__c = sLayout, type__c = sType,
    									focus__c = sFocus.getValue(), Region__c = rId, Area__c = aId,
    									Community__c = commId, highlight__c = true, active__c = true);
    	atestList.add(atest);
    	focusNames.put(sFocus.getValue(),sFocus.getLabel());
    	if(sFocus.getLabel() == 'Contact')
    		contactfocusId = sFocus.getValue(); 
    	nameList.add('A1' + sFocus.getLabel());
    }
    										
	insert atestList;
	atestList = [Select Name,Id, focus__c from Analytic__c where Focus__c in :focusNames.values() AND Name in :nameList];
	
    system.assertequals(r.name, 'London');


    
	for (string sFocus :focusNames.keyset()){ 
	    
	    searchA.selectedLayout = sLayout;
	    searchA.selectedType = sType;
	    searchA.setselectedFocus(focusnames.get(sFocus));
	    searchA.selectedRegion = rId;
	    searchA.selectedArea = aId;
	    searchA.selectedCommunity = commId;
	    searchA.selectedContact = null;
	
	    pageRef = searchA.runSearch();
	    
	    for (Analytic__c resultA :searchA.analyticsAll){
			for(Analytic__c ar :atestList){
				if(ar.focus__c == sFocus){
					system.assertequals(ar.Id, resultA.Id);
					break;
				}
			}
	    }		    	
	}
	
	aTestList.clear();

	atest = new Analytic__c(Name='C1' + contactId, layout__c = sLayout, type__c = sType,
									focus__c = contactfocusId, Region__c = rId, Area__c = aId,
									Community__c = commId, highlight__c = true, active__c = true,
									Contact__c = contactid);
	atestList.add(atest);
	atest = new Analytic__c(Name='C2' + contactId, layout__c = sLayout, type__c = sType,
									focus__c = contactfocusId, Region__c = rId, Area__c = aId,
									Community__c = commId, highlight__c = true, active__c = true,
									Contact__c = contactId);
	// Test adding contact focus record
	atestList.add(atest);
	insert atestList;
    	
    searchA.selectedLayout = sLayout;
    searchA.selectedType = sType;
    searchA.setselectedFocus(contactfocusId);
    searchA.selectedRegion = rId;
    searchA.selectedArea = aId;
    searchA.selectedCommunity = commId;
    searchA.selectedContact = contactId;

	pageRef = searchA.runSearch();
	
	//check Contact can be found
	List<SelectOption> contactList = searchA.getContacts();
	for (SelectOption sContact :contactList){
		if (sContact.getLabel() == 'Test Surname'){
			system.assertequals(sContact.getValue(), contactId);
			break;
		}
	}
	
	// Test record sorting
	string firstId = searchA.analyticsAll[0].Id;
	searchA.sortField = 'Id';
	searchA.toggleSort();
	system.assertNotEquals(firstId,searchA.analyticsAll[0].Id);

	pageRef = searchA.Clear();
	searchA.closeWin();	
	system.assertequals(searchA.selectedLayout, '');
	   
    Test.stopTest();
    }    
     
}