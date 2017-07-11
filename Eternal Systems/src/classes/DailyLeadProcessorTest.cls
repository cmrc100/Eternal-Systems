@isTest
private class DailyLeadProcessorTest {
   
   // Dummy CRON expression: midnight on March 15.
    // Because this is a test, job executes
    // immediately after Test.stopTest().
    public static String CRON_EXP = '0 0 0 15 3 ? 2022';

    static testmethod void testScheduledJob() {

        // Create some lead records with blank lead source
        List<Lead> leads = new List<Lead>();

        for (Integer i=0; i<200; i++) {
            Lead l = new Lead(				
				FirstName='A'+ i, 
				LastName='B' + i, 
				Company = 'Test' + i 
            );
            leads.add(l);
        }
        insert leads;
        
        // Get the IDs of the leads we just inserted
        Map<Id, Lead> leadMap = new Map<Id, Lead>(leads);
        list<Id> leadIds = new list<Id>(leadMap.keySet());

        Test.startTest();
        // Schedule the test job
        String jobId = System.schedule('ScheduledApexTest',
            CRON_EXP, 
            new DailyLeadProcessor());         
        // Verify the scheduled job has not run yet.
        list<Lead> lt = [SELECT Id, LeadSource 
            FROM Lead 
            WHERE Id IN :leadIds
            and LeadSource = 'DreamForce'];
        System.assertEquals(0, lt.size(), 'No Dreamforce Leads exist before job has run');
        // Stopping the test will run the job synchronously
        Test.stopTest();
        
        // Now that the scheduled job has executed,
        // check that our leads were updated
        lt = [SELECT Id, LeadSource 
            FROM Lead
            WHERE Id IN :leadIds
            and LeadSource = 'Dreamforce'];
        System.assertEquals(200, 
            lt.size(), 
            'Leads updated');

    }
}