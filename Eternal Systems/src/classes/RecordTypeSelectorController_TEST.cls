@isTest
public class RecordTypeSelectorController_TEST {

    static testMethod void unitTest(){
        
		test.startTest();        
        map<Id, string> recTypes =  RecordTypeSelectorController.fetchRecordTypeValues('Account');
        test.stopTest();
        
        system.assert(recTypes.values().size() > 0);
        
        
    }
    
}