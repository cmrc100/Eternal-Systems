@isTest
public class AddPrimaryContactTest {

    @testSetup 
    static void setup() {
        List<Account> accounts = new List<Account>();
        // add a parent account
        accounts.add(new Account(name='Parent'));
        // add 100 child accounts
        for (Integer i = 0; i < 50; i++) {
            accounts.add(new Account(
                name='Test AccountNY'+i,
                BillingState='NY'
            ));
            accounts.add(new Account(
                name='Test AccountCA'+i,
                BillingState='CA'
            ));            
        }
        insert accounts;
    }
    
    static testmethod void testQueueable() {
		
		Contact contact = new Contact(LastName = 'Ham');
        // Create our Queueable instance
        AddPrimaryContact updater = new AddPrimaryContact(contact, 'CA');
        // startTest/stopTest block to force async processes to run
        Test.startTest();        
        System.enqueueJob(updater);
        Test.stopTest();        
        // Validate the job ran. 
        System.assertEquals(50, [select count() from Contact where Account.BillingState = 'CA']);
        System.assertEquals(0, [select count() from Contact where Account.BillingState = 'NY']);
    }
    
}