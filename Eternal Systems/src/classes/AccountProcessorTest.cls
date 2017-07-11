@isTest
private class AccountProcessorTest {

	@testSetup static void setup() {
        // Create common test accounts
        List<Account> testAccts = new List<Account>();
        for(Integer i=0;i<10;i++) {
            testAccts.add(new Account(Name = 'TestAcct'+i));
        }
        insert testAccts;   
        
        integer iCounter = 10;
        list<Contact> testContacts = new list<Contact>();
        for(Account acc :testAccts){
        	for (integer i=0; i < iCounter; i++){
        		Contact c = new Contact(LastName = 'Test'+i, AccountId = acc.Id);
        		testContacts.add(c);
        	}
        }
        insert testContacts;     
    }
    
    static testMethod void unitTest() {
        
        test.startTest();
        	list<Id> accIds = new list<Id>();
        	list<Account> accList = [select Id from Account where Name like 'TestAcct%'];
        	for (Account a :accList){
        		accIds.add(a.Id);
        	}
        	AccountProcessor.countContacts(accIds);

        	
        test.stopTest();
        
        	accList = [select Id, Number_Of_Contacts__c from Account where Name like 'TestAcct%'];
        	system.assertEquals(accList[0].Number_Of_Contacts__c, 10);        
        
    }
    
    
}