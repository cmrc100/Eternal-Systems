/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TestOPM {

	//Setup some test data ..
	static User usrA;
	static User usrB;
	static User usrC;
	
	static UserRole urA;
	static UserRole urB;
	static UserRole urC;
	
	static Opportunity oppA;
	static Opportunity oppB;
	static Opportunity oppC;
	
	static string prodLine;

	static PageReference pageRef = page.OPM;
	static OPMController  controller = new OPMController();	

	static void initData(){		
		// sets up test data and performs initial tests on static data values (picklists and roles)

		User thisUser = [ select Id from User where Id = :UserInfo.getUserId()];
		system.runAs(thisUser){	// to avoid DML error	
			// Create roles ... root -> A -> B -> C
			list <UserRole> root = [select Id, parentRoleId from UserRole where parentRoleId = null];
			UserRole urRoot = root[0];
			
			urA = new UserRole(Name = 'Role A', parentRoleId = urRoot.Id);
			insert urA;
			urA = [select Id, Name from UserRole where Name = 'Role A'];
			
			urB = new UserRole(Name = 'Role B', parentRoleId = urA.Id);
			insert urB;
			urB = [select Id, Name from UserRole where Name = 'Role B'];
			
			urC = new UserRole(Name = 'Role C', parentRoleId = urB.Id);
			insert urC;
			urC = [select Id, Name from UserRole where Name = 'Role C'];
					
			// create User
			Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
			  
			usrA = new User(Alias = 'uA', Email='u1@testorg.com', 
			EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
			LocaleSidKey='en_US', ProfileId = p.Id, UserRoleId=urA.Id,
			TimeZoneSidKey='America/Los_Angeles', UserName='uATest@testorg.com');
	      
			insert usrA;
	
	
			usrB = new User(Alias = 'uB', Email='u1@testorg.com', 
			EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
			LocaleSidKey='en_US', ProfileId = p.Id, UserRoleId=urB.Id,
			TimeZoneSidKey='America/Los_Angeles', UserName='uBTest@testorg.com');
	      
			insert usrB;
			
			usrC = new User(Alias = 'uC', Email='u1@testorg.com', 
			EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
			LocaleSidKey='en_US', ProfileId = p.Id, UserRoleId=urC.Id,
			TimeZoneSidKey='America/Los_Angeles', UserName='ucTest@testorg.com');
	      
			insert usrC;
		}
		// get product lines
		list<SelectOption> pl = controller.getProductLines();
		system.assertEquals(pl[0].getLabel(), ' -- Select Value -- ');
		
		prodLine = pl[1].getValue();
		
		// Test other picklist values
		list<SelectOption> stg = controller.getStages();
		system.assertEquals(stg[0].getLabel(), ' -- Select Value -- ');
		
		// Test tree construction and role retrieval
		
		string sJSON = controller.getJsonString();
		system.assert(!string.isEmpty(sJSON));
		
		list<SelectOption> rl = controller.getRoles();
		system.assertEquals(rl[0].getLabel(), ' -- Select Value -- ');		
		

		
		oppA = new Opportunity (Name= 'OppA' ,  StageName = 'Needs Analysis', 
									CloseDate = Date.today() + 1, Probability = 1, 
									Product_Line__c = prodLine, OwnerId = usrA.Id);
									
		insert oppA;
		oppA = [select Owner.UserRoleId from Opportunity where Name = 'OppA'];

		oppB = new Opportunity (Name= 'OppB' ,  StageName = 'Needs Analysis', 
									CloseDate = Date.today() + 1, Probability = 1, 
									Product_Line__c = prodLine, OwnerId = usrB.Id);
		insert oppB;
									
		oppC = new Opportunity (Name= 'OppC' ,  StageName = 'Needs Analysis', 
									CloseDate = Date.today() + 1, Probability = 1, 
									Product_Line__c = prodLine, OwnerId = usrC.Id);									
		insert oppC;

	}

    static testMethod void testCreateRecord() {

		test.setCurrentPage(pageRef);
		
		test.startTest();
		initData();		
			
		controller.newRole = urA.Id;
		controller.newProductLine = prodLine;
		controller.newStage = 'Needs Analysis';
		controller.newSubordinates = false;
		controller.newProbability = 25;
		controller.saveNew();
		
		list<Opportunity_Probability_Management__c> opmList = [select Probability__c, composite_key__c from Opportunity_Probability_Management__c 
														where Role__c = :urA.Id];
													
		system.assertEquals(1, opmList.size());
		system.assertEquals(25, opmList[0].Probability__c);
		
		controller.setselectedValues(urA.Id);
		system.assertEquals(controller.getselectedValues(), urA.Id );	

		// force error
		controller.newRole = null;
		controller.newProductLine = prodLine;
		controller.newStage = 'Needs Analysis';
		controller.newSubordinates = false;
		controller.newProbability = 25;
		controller.saveNew();

		// check record not created
		opmList = [select Probability__c, composite_key__c from Opportunity_Probability_Management__c 
														where Stage__c = 'Needs Analysis'];
													
		system.assertEquals(1, opmList.size());

		// force error
		controller.newRole = urA.Id;
		controller.newProductLine = ' -- Select Value -- ';
		controller.newStage = 'Needs Analysis';
		controller.newSubordinates = false;
		controller.newProbability = 25;
		controller.saveNew();

		// check record not created
		opmList = [select Probability__c, composite_key__c from Opportunity_Probability_Management__c 
														where Stage__c = 'Needs Analysis'];
													
		system.assertEquals(1, opmList.size());
		
		// check duplicate can't be created..
		controller.newRole = urA.Id;
		controller.newProductLine = prodLine;
		controller.newStage = 'Needs Analysis';
		controller.newSubordinates = false;
		controller.newProbability = 25;
		controller.saveNew();
		
		// check another record not created		
		opmList = [select Probability__c, composite_key__c from Opportunity_Probability_Management__c 
														where Role__c = :urA.Id];
													
		system.assertEquals(1, opmList.size());
					
		test.stopTest();														
    }
    
    
   static testMethod void testUpdateProbabilityNoSubordinates() {
	// Simple test of single parent role with no subordinates 
	
		test.setCurrentPage(pageRef);
		test.startTest();
		initData();		

			
		controller.newRole = urA.Id;
		controller.newProductLine = prodLine;
		controller.newStage = 'Needs Analysis';
		controller.newSubordinates = false;
		controller.newProbability = 25;
		controller.saveNew();
		
		list<Opportunity_Probability_Management__c> opmList = [select Probability__c from Opportunity_Probability_Management__c 
														where Role__c = :urA.Id];
														
		system.assertEquals(1, opmList.size());
		system.assertEquals(25, opmList[0].Probability__c);
		
		controller.callApplyUpdateNew();
		
		test.stopTest();
	
		oppA = [select Probability, Owner.UserRoleId from Opportunity where Name = 'OppA'];		
		system.assertEquals(25, oppA.Probability);
		
		//check that others are untouched
		oppB = [select Probability, Owner.UserRoleId from Opportunity where Name = 'OppB'];
		system.assertEquals(1, oppB.Probability);
		
		oppC = [select Probability, Owner.UserRoleId from Opportunity where Name = 'OppC'];
		system.assertEquals(1, oppC.Probability);
												
    }

  static testMethod void testUpdateProbabilityWithSubordinates() {
	// test parent role with subordinates, where no configuration exists for subordinate
	
		test.setCurrentPage(pageRef);
		test.startTest();
		initData();		
		
			
		controller.newRole = urA.Id;
		controller.newProductLine = prodLine;
		controller.newStage = 'Needs Analysis';
		controller.newSubordinates = true;
		controller.newProbability = 25;
		controller.saveNew();
		
		list<Opportunity_Probability_Management__c> opmList = [select Probability__c from Opportunity_Probability_Management__c 
														where Role__c = :urA.Id];
														
		system.assertEquals(1, opmList.size());
		system.assertEquals(25, opmList[0].Probability__c);
		
		controller.callApplyUpdate();
		
		test.stopTest();

		oppA = [select Probability, Owner.UserRoleId from Opportunity where Name = 'OppA'];		
		system.assertEquals(25, oppA.Probability);
		
		//chck subordinates also changed
		oppB = [select Probability, Owner.UserRoleId from Opportunity where Name = 'OppB'];
		system.assertEquals(25, oppB.Probability);
		
		oppC = [select Probability, Owner.UserRoleId from Opportunity where Name = 'OppC'];
		system.assertEquals(25, oppC.Probability);
												
    }

  static testMethod void testUpdateProbabilityForSubordinates() {
	// test parent role with subordinates where subordinate has a config record which should take precedent
	
		test.setCurrentPage(pageRef);
		test.startTest();
		initData();		
		
			
		controller.newRole = urA.Id;
		controller.newProductLine = prodLine;
		controller.newStage = 'Needs Analysis';
		controller.newSubordinates = true;
		controller.newProbability = 25;
		controller.saveNew();
		
		list<Opportunity_Probability_Management__c> opmListA = [select Probability__c from Opportunity_Probability_Management__c 
														where Role__c = :urA.Id];
														
		system.assertEquals(1, opmListA.size());
		system.assertEquals(25, opmListA[0].Probability__c);

		// create config record for subordinate
		controller.newRole = urB.Id;
		controller.newProductLine = prodLine;
		controller.newStage = 'Needs Analysis';
		controller.newSubordinates = true;
		controller.newProbability = 35;
		controller.saveNew();
		
		list<Opportunity_Probability_Management__c> opmListB = [select Probability__c from Opportunity_Probability_Management__c 
														where Role__c = :urB.Id];
														
		system.assertEquals(1, opmListB.size());
		system.assertEquals(35, opmListB[0].Probability__c);
		
		controller.callApplyUpdate();
		test.stopTest();	

		oppA = [select Probability, Owner.UserRoleId from Opportunity where Name = 'OppA'];		
		system.assertEquals(25, oppA.Probability);
		
		//check subordinate value changed to subordinate config value (not parent's)
		oppB = [select Probability, Owner.UserRoleId from Opportunity where Name = 'OppB'];
		system.assertEquals(35, oppB.Probability);
		
		//check subordinate value changed to subordinate config value of immediate parent
		// for record with no matching config
		oppC = [select Probability, Owner.UserRoleId from Opportunity where Name = 'OppC'];
		system.assertEquals(35, oppC.Probability);
													
    }

	static testMethod void testRecordSummaryNavigation() {
       // Test for querying and display of configuration records, this test method
       // covers many of the UI aspects, such as filtering and sorting records

		test.setCurrentPage(pageRef);
		test.startTest();
		initData();		
		
			
		controller.newRole = urA.Id;
		controller.newProductLine = prodLine;
		controller.newStage = 'Needs Analysis';
		controller.newSubordinates = true;
		controller.newProbability = 25;
		controller.saveNew();

		list<Opportunity_Probability_Management__c> opmListA = [select Probability__c from Opportunity_Probability_Management__c 
														where Role__c = :urA.Id];
														
		system.assertEquals(1, opmListA.size());
		system.assertEquals(25, opmListA[0].Probability__c);

		// create config record for subordinate
		controller.newRole = urB.Id;
		controller.newProductLine = prodLine;
		controller.newStage = 'Needs Analysis';
		controller.newSubordinates = true;
		controller.newProbability = 35;
		controller.saveNew();
		
		list<Opportunity_Probability_Management__c> opmListB = [select Probability__c from Opportunity_Probability_Management__c 
														where Role__c = :urB.Id];
														
		system.assertEquals(1, opmListB.size());
		system.assertEquals(35, opmListB[0].Probability__c);       

		// create config record for subordinate
		controller.newRole = urC.Id;
		controller.newProductLine = prodLine;
		controller.newStage = 'Needs Analysis';
		controller.newSubordinates = true;
		controller.newProbability = 45;
		controller.saveNew();
		
		list<Opportunity_Probability_Management__c> opmListC = [select Probability__c from Opportunity_Probability_Management__c 
														where Role__c = :urC.Id];
														
		system.assertEquals(1, opmListC.size());
		system.assertEquals(45, opmListC[0].Probability__c);
	
		list<Opportunity_Probability_Management__c> opmList = controller.getOPMList();
		
		system.assertEquals(3, opmList.size());
		
		//check no errors
		controller.firstPage();
		controller.nextPage();
		controller.prevPage();
		controller.lastPage();
		controller.getHasNext();
		controller.getHasPrevious();
		string s = controller.selectedValues;
		
		// set sorting
		// check first value is currently Role A
		system.assertEquals(opmList[0].Role_Name__c, 'Role A');
		controller.setsortField('Role_Name__c');
		controller.toggleSort();
		system.assertEquals(controller.getsortField(), 'Role_Name__c');
		opmList = controller.getOPMList();
		// Check records now sorted descending order
		system.assertEquals(opmList[0].Role_Name__c, 'Role C');
		
		// apply filter
		controller.filterRole = 'Role C';
		controller.filterStage = ' -- Select Value -- ';
		controller.filterProductLine = prodLine;
		controller.applyFilter();
		
		opmList = controller.getOPMList();
		system.assertEquals(1, opmList.size());
		
		//reset filters
		controller.filterRole = ' -- Select Value -- ';
		controller.filterStage = ' -- Select Value -- ';
		controller.filterProductLine = ' -- Select Value -- ';
		controller.applyFilter();
		
		opmList = controller.getOPMList();
		system.assertEquals(3, opmList.size());

		// set all filters to something random
		//reset filters
		controller.filterRole = ' xxx ';
		controller.filterStage = ' xxx ';
		controller.filterProductLine = ' xxx ';
		controller.applyFilter();
		
		opmList = controller.getOPMList();
		system.assertEquals(0, opmList.size());		
				
		test.stopTest();

	}
	
	static testMethod void testRecordUpdate(){
		// tests updating/deactivating config record

		test.setCurrentPage(pageRef);
		test.startTest();
		initData();		
		
			
		controller.newRole = urA.Id;
		controller.newProductLine = prodLine;
		controller.newStage = 'Needs Analysis';
		controller.newSubordinates = true;
		controller.newProbability = 25;
		controller.saveNew();
		
		list<Opportunity_Probability_Management__c> opmListA = [select Probability__c from Opportunity_Probability_Management__c 
														where Role__c = :urA.Id];
														
		system.assertEquals(1, opmListA.size());
		system.assertEquals(25, opmListA[0].Probability__c);

		// create config record for subordinate
		controller.newRole = urB.Id;
		controller.newProductLine = prodLine;
		controller.newStage = 'Needs Analysis';
		controller.newSubordinates = true;
		controller.newProbability = 35;
		controller.saveNew();
		
		list<Opportunity_Probability_Management__c> opmListB = [select Probability__c from Opportunity_Probability_Management__c 
														where Role__c = :urB.Id];
														
		system.assertEquals(1, opmListB.size());
		system.assertEquals(35, opmListB[0].Probability__c);       

		// create config record for subordinate
		controller.newRole = urC.Id;
		controller.newProductLine = prodLine;
		controller.newStage = 'Needs Analysis';
		controller.newSubordinates = true;
		controller.newProbability = 45;
		controller.saveNew();
		
		list<Opportunity_Probability_Management__c> opmListC = [select Probability__c from Opportunity_Probability_Management__c 
														where Role__c = :urC.Id];
														
		system.assertEquals(1, opmListC.size());
		system.assertEquals(45, opmListC[0].Probability__c);		
		
		// deactivate B
		controller.selectedItem = opmListB[0].Id;
		controller.activation();

		opmListB = [select Probability__c, Active__c from Opportunity_Probability_Management__c 
														where Role__c = :urB.Id];		
		system.assertEquals(false, opmListB[0].Active__c);
		
		// update C
		controller.selectedItem = opmListC[0].Id;
		list<Opportunity_Probability_Management__c> opmList = controller.getOPMList();
		for(Opportunity_Probability_Management__c opm :opmList){
			string sRole = opm.role_name__c;
			if (sRole == 'Role C'){
				opm.Probability__c = 55;
				controller.save();
				break;
			}
		}
		
		opmListC = [select Probability__c from Opportunity_Probability_Management__c 
														where Role__c = :urC.Id];
		system.assertEquals(55, opmListC[0].Probability__c);														
		
		controller.callApplyUpdate();
						
		test.stopTest();	
					
		oppA = [select Probability, Owner.UserRoleId from Opportunity where Name = 'OppA'];		
		system.assertEquals(25, oppA.Probability);
		
		//check subordinate value changed to parent's values because config record is inactive
		oppB = [select Probability, Owner.UserRoleId from Opportunity where Name = 'OppB'];
		system.assertEquals(25, oppB.Probability);
		
		//check subordinate value changed to updated subordinate config value (not parent's)
		oppC = [select Probability, Owner.UserRoleId from Opportunity where Name = 'OppC'];
		system.assertEquals(55, oppC.Probability);

	}
	
	static testMethod void testRecordDeletion(){
		
		//test deleting record
		test.setCurrentPage(pageRef);
		test.startTest();
		initData();		
		
			
		controller.newRole = urA.Id;
		controller.newProductLine = prodLine;
		controller.newStage = 'Needs Analysis';
		controller.newSubordinates = true;
		controller.newProbability = 25;
		controller.saveNew();

		list<Opportunity_Probability_Management__c> opmListA = [select Probability__c from Opportunity_Probability_Management__c 
														where Role__c = :urA.Id];
														
		system.assertEquals(1, opmListA.size());
		system.assertEquals(25, opmListA[0].Probability__c);

		// create config record for subordinate
		controller.newRole = urB.Id;
		controller.newProductLine = prodLine;
		controller.newStage = 'Needs Analysis';
		controller.newSubordinates = true;
		controller.newProbability = 35;
		controller.saveNew();
		
		list<Opportunity_Probability_Management__c> opmListB = [select Probability__c from Opportunity_Probability_Management__c 
														where Role__c = :urB.Id];
														
		system.assertEquals(1, opmListB.size());
		system.assertEquals(35, opmListB[0].Probability__c);       

		// create config record for subordinate
		controller.newRole = urC.Id;
		controller.newProductLine = prodLine;
		controller.newStage = 'Needs Analysis';
		controller.newSubordinates = true;
		controller.newProbability = 45;
		controller.saveNew();
		
		list<Opportunity_Probability_Management__c> opmListC = [select Probability__c from Opportunity_Probability_Management__c 
														where Role__c = :urC.Id];
														
		system.assertEquals(1, opmListC.size());
		system.assertEquals(45, opmListC[0].Probability__c);
		
		list<Opportunity_Probability_Management__c> opmList = controller.getOPMList();
		system.assertEquals(3, opmList.size());				
		
		// delete record C
		controller.selectedItem = opmListC[0].Id;
		controller.deleteRecord();

		opmList = controller.getOPMList();
		system.assertEquals(2, opmList.size());				
		
		// test that record C inherits B settings
		controller.callApplyUpdate();
		test.stopTest();	
					
		oppA = [select Probability, Owner.UserRoleId from Opportunity where Name = 'OppA'];		
		system.assertEquals(25, oppA.Probability);
		
		//check subordinate value changed to subordinate config value (not parent's)
		oppB = [select Probability, Owner.UserRoleId from Opportunity where Name = 'OppB'];
		system.assertEquals(35, oppB.Probability);
		
		//check subordinate value changed to subordinate config value of immediate parent
		// for record with no matching config
		oppC = [select Probability, Owner.UserRoleId from Opportunity where Name = 'OppC'];
		system.assertEquals(35, oppC.Probability);		

	}

	static testMethod void testOpportunityUpsert(){
		
		//test Opportunity updates/insert
		
		test.setCurrentPage(pageRef);
		test.startTest();
		initData();		
		
			
		controller.newRole = urA.Id;
		controller.newProductLine = prodLine;
		controller.newStage = 'Needs Analysis';
		controller.newSubordinates = true;
		controller.newProbability = 25;
		controller.saveNew();

		list<Opportunity_Probability_Management__c> opmListA1 = [select Probability__c from Opportunity_Probability_Management__c 
														where Role__c = :urA.Id];
														
		system.assertEquals(1, opmListA1.size());
		system.assertEquals(25, opmListA1[0].Probability__c);

		// create config record for subordinate
		controller.newRole = urA.Id;
		controller.newProductLine = prodLine;
		controller.newStage = 'Prospecting';
		controller.newSubordinates = true;
		controller.newProbability = 35;
		controller.saveNew();
		
		list<Opportunity_Probability_Management__c> opmListA2 = [select Probability__c from Opportunity_Probability_Management__c 
														where Role__c = :urA.Id];
														
		system.assertEquals(2, opmListA2.size());
      
		Opportunity opp1 = new Opportunity (Name= 'Opp1' ,  StageName = 'Needs Analysis', 
									CloseDate = Date.today() + 1, Probability = 1, 
									Product_Line__c = prodLine, OwnerId = usrA.Id);
									
		insert opp1;
		
		opp1 = [Select Probability, StageName from Opportunity where Name='Opp1'];
		
		// Check inserted value matches config
		system.assertEquals(Opp1.Probability, 25);
		
		opp1.StageName = 'Prospecting';
		update opp1;

		opp1 = [Select Probability, StageName from Opportunity where Name='Opp1'];
		
		// Check inserted value matches config
		system.assertEquals(opp1.Probability, 35);		
		
		test.stopTest();
	}

	static testMethod void testBulkOperations(){
		
		//test handling of bulk volumes
		
		test.setCurrentPage(pageRef);
		test.startTest();
		initData();	
		
		// create 200 config records .. first need 200 roles
		User thisUser = [ select Id from User where Id = :UserInfo.getUserId()];
		list<UserRole> urList = new list<UserRole>();
		list<User> usrList = new list<User>();
		system.runAs(thisUser){	// to avoid DML error	
			// Create roles ... 
			list <UserRole> root = [select Id, parentRoleId from UserRole where parentRoleId = null];
			UserRole urRoot = root[0];
			
			for (integer i = 0; i < 200; i++ ) {
			
				UserRole urTest = new UserRole(Name = 'Role ' + i, parentRoleId = urRoot.Id);
				urList.add(urTest);
			}		
			insert urList;
			
			Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
			for (UserRole ur :urList){			
						// create User
				User usr = new User(Alias = 'uA', Email='u1@testorg.com', 
				EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
				LocaleSidKey='en_US', ProfileId = p.Id, UserRoleId=ur.Id,
				TimeZoneSidKey='America/Los_Angeles', UserName=ur.Id +'@testorg.com');
				
				usrList.add(usr);
			}
			insert usrList;
			usrList = [select Id from User where UserRoleId in:urList];
			system.assertequals(usrList.size(), 200);
		}	
		// now create config records..Probability = 50
		list<Opportunity_Probability_Management__c> ompList = new list<Opportunity_Probability_Management__c>(); 
		for (UserRole ur :urList){
			Opportunity_Probability_Management__c omp = new Opportunity_Probability_Management__c
																			(Stage__c = 'Needs Analysis',
															 				Product_Line__c = prodLine,
															 				Role__c = ur.Id,
															 				Role_Name__c = ur.Name,
															 				Probability__c = 50,
															 				Subordinates_included__c = false);
			ompList.add(omp);												 				
		}			
		insert ompList;			

		// Test tree construction and role retrieval
		string sJSON = controller.getJsonString();
		system.assert(!string.isEmpty(sJSON));
		
		// create 200 opportunities which match config items for each user/role, with Probability value of 1
		list<Opportunity> oppList = new list<Opportunity>();
		for (User usr :usrList){
			Opportunity opp = new Opportunity(Name= 'Opp' + usr.Id ,  StageName = 'Needs Analysis', 
									CloseDate = Date.today() + 1, Probability = 1, 
									Product_Line__c = prodLine, OwnerId = usr.Id);
			oppList.add(opp);		
		}
		insert oppList; //test trigger
		
		// check probability values have been updated after insert
		oppList = [select name, probability from Opportunity where OwnerId in:usrList];		
		for (Opportunity opp :oppList){
			system.assertEquals(opp.Probability, 50);
		}
	
		// amend config records ..
		ompList = [select Probability__c from Opportunity_Probability_Management__c];
		for (Opportunity_Probability_Management__c omp :ompList){
			omp.Probability__c = 25;
		}
		update ompList;
		
		controller.callApplyUpdate(); //test UI controller class
		test.stopTest();
		// check probability values have been updated after insert
		oppList = [select name, probability from Opportunity where OwnerId in:usrList];		
		for (Opportunity opp :oppList){
			system.assertEquals(opp.Probability, 25);
		}		
		
	}
		        
}