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
private class TestDocusign {

	static testMethod void TestAccessToken() {
		
		PageReference pageRef = page.DocusignAppAuthorization;
		DocusignAPI controller = null;
		test.setMock(HttpCalloutMock.class, new MockDocusignAPI());
			
		test.startTest();
		controller = new DocusignAPI();
		controller.integrationKey = '1234';
		controller.userName = 'TestUser';
		controller.password = 'TestPassword';
		controller.getOAuthToken();
		
		test.stopTest();
		
		system.assertEquals(controller.accessToken, 'test_token_from_MockDocusignAPI_class');
		
    }
    
	static testMethod void TestSingleBatchUpdate() {
		
		Account a = new Account(Name='Test1');
		insert a;
		list<Opportunity> oList = new list<Opportunity>();
		for (integer i=0; i < 5; i++){
			Opportunity o = new Opportunity(Name='opp-docusign' + i, AccountId=a.id, StageName='Prospecting', CloseDate=system.today());
			oList.add(o);
		}
		insert oList;
		
		
		
		DocusignAPI controller = null;
		test.setMock(HttpCalloutMock.class, new MockDocusignAPI());
			
		test.startTest();
		
		controller = new DocusignAPI();
		
		DocusignSearch.updateObjectDocusignStatus(a.Id, null, null);
		
		test.stopTest();
		
		oList = [select Docusign_status__c from Opportunity where name like 'opp-docusign%'];
		
		for (opportunity op :oList){
			system.assertEquals(op.Docusign_status__c, 'sent');
		}
		
    } 


	static testMethod void TestBulkBatchUpdate() {
		
		Account a = new Account(Name='Test1');
		insert a;
		list<Opportunity> oList = new list<Opportunity>();
		for (integer i=0; i < 13; i++){
			Opportunity o = new Opportunity(Name='opp-docusign' + i, AccountId=a.id, StageName='Prospecting', CloseDate=system.today());
			oList.add(o);
		}
		insert oList;
	
		DocusignAPI controller = null;
		test.setMock(HttpCalloutMock.class, new MockDocusignAPI());
			
		test.startTest();
		
		controller = new DocusignAPI();
		string s = DocusignSearch.updateObjectDocusignStatus('bulkparent', null, null);
		system.assert(s.indexOf(';') > 0);
		s = DocusignSearch.updateObjectDocusignStatus('bulkparent', null, s);
		
		test.stopTest();
		
		oList = [select Docusign_status__c from Opportunity where name like 'opp-docusign%'];
		
		for (opportunity op :oList){
			system.assertEquals(op.Docusign_status__c, 'sent');
		}
		

		
    } 
    
    static testMethod void TestErrorResponse() {

		test.setMock(HttpCalloutMock.class, new MockDocusignAPI());
			
		test.startTest();
		
		string s = DocusignSearch.updateObjectDocusignStatus('badparent', null, null);
		
		test.stopTest();
		
		system.assertEquals('An error has occurred retrieving the Docusign Status : 400 - Server down' , s);    	
    	
    }   
}