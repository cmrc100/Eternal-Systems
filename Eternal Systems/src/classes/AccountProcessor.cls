
public class AccountProcessor {
	
	@future
    public static void countContacts(list<Id> AccountIds) {
        
        list<Account> accountList = [select Id,Number_Of_Contacts__c, (select Id from Contacts) from Account where Id in:AccountIds];
        
        for (Account acc :accountList){
        	acc.Number_Of_Contacts__c = acc.Contacts.size();        	
        }
        update accountList;
        
    }
}