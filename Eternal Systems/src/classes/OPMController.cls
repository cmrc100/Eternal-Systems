public with sharing class OPMController {
	
	public ApexPages.StandardSetController setCon;
	public string newRole{get; set;}
	public boolean newSubordinates{get; set;}
	public string newProductLine{get; set;}
	public string newStage {get; set;}
	public double newProbability {get; set;}
	public string selectedItem {get; set;}
	private id newRecId;
  
    public Integer resultsPerPage{get;Set;}
    public Integer currentPage{get;Set;}
    public decimal totalPages{get;Set;}
    
	public string filterStage {get; set;}    
	public string filterProductLine {get; set;} 
	public string filterRole {get; set;}
	private string sApplySOQL = '';
	public string sortField = 'role_name__c';	// default sort column
	
	
	public OPMController(){
		List<Opportunity_Probability_Management__c> OPMList = [SELECT Name, Role__c, Role_Name__c, Active__c, Subordinates_included__c,
		 											Product_line__c, stage__c, probability__c FROM Opportunity_Probability_Management__c LIMIT 20];
		
		sApplySOQL = 'SELECT Name, Role__c, Role_Name__c, Active__c, Subordinates_included__c,';
		sApplySOQL = sApplySOQL + ' Product_line__c, stage__c, probability__c FROM Opportunity_Probability_Management__c ';		
		sApplySOQL = sApplySOQL + ' Order By ' + sortField + ' ' + sortDir;
		
		refreshOPMList();
	}
	
    // Single function that initializes/refreshes the record list.
    // A StandardSetController object has been used to store the 
    // UI Summary data items
    public void refreshOPMList() {        
        try{
        	setCon = new ApexPages.StandardSetController(Database.getQueryLocator(sApplySOQL));
        	setCon.setPageSize(25); // UI Page Size setting, could perhaps be parameterised in future
        } catch (exception e){
			system.debug(e.getMessage() + ' : ' + e.getStackTraceString());        
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));        	
        }
    }
  	
  	// Object used in UI record Summary table 
	public list<Opportunity_Probability_Management__c> getOPMList(){
		
		// Set pagination properties
		this.resultsPerPage = setCon.getPageSize();
        this.currentPage = setCon.getPageNumber();
        decimal rs = Decimal.valueOf(setCon.getResultSize());
        this.totalPages = rs.divide(setCon.getPageSize(),0,system.roundingmode.up);

        if (setCon.getPageSize() > setCon.getResultSize()){
            this.totalPages = 1;
        } else {
            rs = Decimal.valueOf(setCon.getResultSize());
            this.totalPages = rs.divide(setCon.getPageSize(),0,system.roundingmode.up);
        }
  		// Populate list to display with contents of Set Controller
        return (List<Opportunity_Probability_Management__c>) setCon.getRecords();
	}
	
	//Method to populate UI Roles picklist for filtering
	public List<SelectOption> getRoles(){
    	
    	map <Id, List<UserRole>> parentChildRoleMap = OPMUtil.parentChildRoleMap;
    	List<SelectOption> options = new List<SelectOption>();
    	
    	for(string s :parentChildRoleMap.keySet()){    		
    		list<UserRole> urList = parentChildRoleMap.get(s);
			for(UserRole ur :urList){
		        options.add(new SelectOption(ur.Name, ur.Name));    			
			}
    	}

        options.add(0, new SelectOption(' -- Select Value -- ', ' -- Select Value -- '));

        return options;
    } 
	
	// Method to populate UI Product Lines picklist for filtering and 
	// record creation
    public List<SelectOption> getProductLines(){
    	
        List<SelectOption> options = new List<SelectOption>();
        List<Schema.PicklistEntry> listValues  = Opportunity.Product_Line__c.getDescribe().getPicklistValues();
        for (Schema.PicklistEntry listItem :listValues){
        	options.add(new SelectOption(listItem.getLabel(), listItem.getLabel()));
        }
        
        options = selectOptionSortByLabel(options);
        options.add(0, new SelectOption(' -- Select Value -- ', ' -- Select Value -- '));
        return options;
    } 

	// Method to populate UI Stage picklist for filtering and 
	// record creation
    public List<SelectOption> getStages(){
    	
        List<SelectOption> options = new List<SelectOption>();
        List<Schema.PicklistEntry> listValues  = Opportunity.StageName.getDescribe().getPicklistValues();

        for (Schema.PicklistEntry listItem :listValues){
        	options.add(new SelectOption(listItem.getLabel(), listItem.getLabel()));
        }
        options = selectOptionSortByLabel(options);
		options.add(0, new SelectOption(' -- Select Value -- ', ' -- Select Value -- '));
        return options;
    } 

	//Utility method to sort picklist values alphabetically
     public static list<selectOption> selectOptionSortByLabel(list<selectOption>
                                                            selectOptionsToSort) {
        if(selectOptionsToSort == null || selectOptionsToSort.size() <= 1){
            return selectOptionsToSort;
        }
        List<SelectOption> lessSelectOption = new List<SelectOption>();
        List<SelectOption> greaterSelectOption = new List<SelectOption>();
        integer pivot = selectOptionsToSort.size() / 2;
    
        //save the pivot and remove it from the selectOption list
        SelectOption pivotValue = selectOptionsToSort[pivot];


        for(selectOption SO : selectOptionsToSort){
            if (SO.getLabel() != pivotValue.getLabel()){
                if(SO.getLabel() <= pivotValue.getLabel()){
                    lessSelectOption.add(SO);
                }else if(SO.getLabel() > pivotValue.getLabel()){
                    greaterSelectOption.add(SO);   
                }
             }
        }

        list<selectOption> sortedSelectOptions = new list<selectOption>(); 
        sortedSelectOptions.addAll(selectOptionSortByLabel(lessSelectOption));
        sortedSelectOptions.add(pivotValue);
        sortedSelectOptions.addAll(selectOptionSortByLabel(greaterSelectOption));
        return SortedSelectOptions;
    }
    
    // Tree controller data
	public String getJsonString() 
    {
        string str = null;
        str = OPMUtil.getRoleTreeJSON();
        
        return str; 
    }
    
	public string selectedValues;
	
	public string getselectedValues(){
		return selectedValues;
	}
	
	public void setselectedValues(string sValue){
				
		this.selectedValues = sValue;		
		newRole = sValue;		
	}
	
	//Method to create a new configuration record
	public void saveNew(){
		
		string sRole = '';
		UserRole ur = null;
			
		try{
			if (string.isEmpty(newRole)){
				throw new customException();	
			} else {
				ur = [Select Name from UserRole where Id=:newRole];
			}
			if (ur != null){
				sRole = ur.Name;
			} else {
				throw new customException();
			}
		} catch (customException e){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ' Please select a Role'));
			return;
		}

		try {			
			if(newStage == ' -- Select Value -- ' || newProductLine == ' -- Select Value -- '){
				throw new customException();
			}
		} catch (customException e){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please select valid values for both Stage and Product Line'));
			return;
		}
			
		try{			
			Opportunity_Probability_Management__c opm = new Opportunity_Probability_Management__c
															(Stage__c = newStage,
															 Product_Line__c = newProductLine,
															 Role__c = newRole,
															 Role_Name__c = sRole,
															 Probability__c = newProbability,
															 Subordinates_included__c = newSubordinates);
																
			insert opm;
			newRecId = opm.Id;
			refreshOPMList();
			
		} catch (exception e){

			system.debug(e.getMessage() + ' : ' + e.getStackTraceString());        
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));			
			
		}
		
	}

	//UI filtering method, reconstructs query and calls method to refresh set controller records
	public void applyFilter(){

		try{
		
			string soqlWhere = '';
			
			if (filterStage != ' -- Select Value -- '){
				if(string.isBlank(soqlWhere)){
					soqlWhere = ' where Stage__c LIKE \''+String.escapeSingleQuotes(filterStage)+'%\'';
				} else {
					soqlWhere =  soqlWhere + ' and Stage__c = LIKE \''+String.escapeSingleQuotes(filterStage)+'%\'';
				} 	
			}
	
			if (filterProductLine != ' -- Select Value -- '){
				if(string.isBlank(soqlWhere)){
					soqlWhere = ' where Product_Line__c LIKE \''+String.escapeSingleQuotes(filterProductLine)+'%\'';
				} else {
					soqlWhere = soqlWhere + ' and Product_Line__c LIKE \''+String.escapeSingleQuotes(filterProductLine)+'%\'';
				} 				
			}
			
			if (filterRole != ' -- Select Value -- '){
				if(string.isBlank(soqlWhere)){
					soqlWhere = ' where Role_name__c LIKE \''+String.escapeSingleQuotes(filterRole)+'%\'';
				} else {
					soqlWhere = soqlWhere + ' and Role_name__c LIKE \''+String.escapeSingleQuotes(filterRole)+'%\'';
				} 			
			}		
			
			if (!string.isBlank(soqlWhere)){
				string sSoql = 'SELECT Name, Role__c, Role_Name__c, Active__c, Subordinates_included__c, ';
						sSoql = sSoql + 'Product_line__c, stage__c, probability__c FROM Opportunity_Probability_Management__c ';
						sSoql = sSoql + soqlWhere;
			
				sApplySOQL = sSoql;
				sApplySOQL = sApplySOQL + ' Order By ' + sortField + ' ' + sortDir;
			} else {	
				
				sApplySOQL = 'SELECT Name, Role__c, Role_Name__c, Active__c, Subordinates_included__c,';
				sApplySOQL = sApplySOQL + ' Product_line__c, stage__c, probability__c FROM Opportunity_Probability_Management__c ';		
				sApplySOQL = sApplySOQL + ' Order By ' + sortField + ' ' + sortDir;
			}
			 
			refreshOPMList();
										
		} catch (exception e){
			system.debug(e.getMessage() + ' : ' + e.getStackTraceString());        
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
				
		}		
	}  

   public void prevPage()
    {
      
        this.currentPage--;
        setCon.setPageNumber(this.currentPage);
      
    }
    
    public void nextPage()
    {

        this.currentPage++;
        setCon.setPageNumber(this.currentPage);   
    }
    
    public void firstPage()
    {

        this.currentPage = 1;
        setCon.setPageNumber(1);
    }
    
    public void lastPage()
    {

        this.currentPage = integer.valueOf(this.totalPages);
        setCon.setPageNumber(integer.valueOf(this.totalPages));
 
    }

    public Boolean getHasNext() {
        return setCon.getHasNext();
    }
    

    public Boolean getHasPrevious() {
        return setCon.getHasPrevious();
    }
    
    // the current sort direction. defaults to ascending
    public String sortDir {
    get  { if (sortDir == null) {  sortDir = 'asc'; } return sortDir;  }
    set;
    }
 
    // the current field to sort by. defaults to role name
    public String getsortField() {
		return sortField;
	}

    // the current field to sort by. defaults to name
    public void setsortField(string value) {
		sortField = value;
	}
    	        
    // toggles the sorting of query from asc<-->desc
    public void toggleSort() {
    // simply toggle the direction
		sortDir = sortDir.equals('asc') ? 'desc' : 'asc';
		
		integer iIndex = sApplySOQL.indexOf('Order By');
		if (iIndex > -1){
			sApplySOQL = sApplySOQL.substringBefore('Order By');
			sApplySOQL = sApplySOQL + ' Order By ' + sortField + ' ' + sortDir;
		} 
		
		refreshOPMList();		
    }
	
	// Method to update all Opportunity Probability values
	public void callApplyUpdate(){
		OPMUtil.applyUpdateFuture(null); //call Utility class method
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,' A request to update Opportunity records has been made and will be processed shortly'));
	}
		
	// Method to update Opportunity Probability values that match newly created config item
	public void callApplyUpdateNew(){
		
		if (newRecId == null){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,' Please create a new configuration record before attempting to apply changes'));
		} else {
		
			// retrieve list of matching Opportunity records
			list<Opportunity> oppList = [select Id, Name, StageName, Product_Line__c, OwnerId, Owner.UserRoleId
			 								from Opportunity where 
											(StageName=:newStage and Owner.UserRoleId = :newRole and Product_Line__c = :newProductLine)];
			if (oppList != null){
				list<Id> oppIds = new list<Id>();
				for (Opportunity opp : oppList){
					oppIds.add(opp.Id);
				}
				OPMUtil.applyUpdateFuture(oppIds);
			}
											
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,' A request to update Opportunity records has been made and will be processed shortly'));
		}
	}

	public PageReference save(){

       // setup the save point for rollback
		Savepoint sp = Database.setSavepoint();
		PageReference pg =  system.currentPageReference();		
		try{
			pg = setCon.save();
			refreshOPMList();

			return null;
			
		} catch(exception e){
			Database.rollback(sp);
			system.debug(e.getMessage() + ' : ' + e.getStackTraceString());        
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
			return null;			
		}
		return null;
			
	} 
	
	//Method to toggle whether config record is Active/Inactive
	public void activation(){
		try{
			list<Opportunity_Probability_Management__c> opmList = [select name, Active__c from Opportunity_Probability_Management__c
															where Id=: selectedItem];
			
			if (!opmList.isEmpty()){
				for(Opportunity_Probability_Management__c opm :opmList){
					boolean bActive = opm.Active__c;
					if(bActive) {
						bActive = false;
					} else {
						bActive = true;
					} 
					opm.Active__c = bActive; 
				}
				update opmList;
				refreshOPMList();
			} else {
				refreshOPMList();	
			}
						
		} catch (exception e){
			system.debug(e.getMessage() + ' : ' + e.getStackTraceString());        
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));						
		}			
	} 

	public void deleteRecord(){
		
		try{
			list<Opportunity_Probability_Management__c> opm = [select name from Opportunity_Probability_Management__c
															where Id=: selectedItem];
			
			if (!opm.isEmpty()){
				delete opm;
				refreshOPMList();
			} else {
				refreshOPMList();
			}
						
		} catch (exception e){
			system.debug(e.getMessage() + ' : ' + e.getStackTraceString());        
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));						
		}	
	
	}
	
	
	
	public class customException extends Exception{}
	    
}