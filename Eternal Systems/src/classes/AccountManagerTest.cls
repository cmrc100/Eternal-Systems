
@isTest
private class AccountManagerTest {

    @isTest static void testGetAccountIdContacts() {
        Id recordId = createTestRecord();
        // Set up a test request
        RestRequest request = new RestRequest();
        request.requestUri =
            'https://yourInstance.salesforce.com/services/apexrest/Account/' + recordId + '/contacts';
        request.httpMethod = 'GET';
        RestContext.request = request;
        // Call the method to test
        Account acc = AccountManager.getAccount();
        // Verify results
        System.assert(acc != null);
        System.assertEquals('Test Account 1', acc.Name);
        System.assertEquals(acc.Contacts.size(), 1);
    }
    
    // Helper method
    static Id createTestRecord() {
        // Create test record
        Account accTest = new Account(
			Name = 'Test Account 1');
        insert accTest;
        
        Contact contact = new Contact(FirstName = 'Test', LastName = 'Contact 1', AccountId = accTest.Id);
        insert contact;
        
        return accTest.Id;
    }             
}