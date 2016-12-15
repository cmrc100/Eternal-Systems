public class ContactPrimaryPhoneDialButtonController {
	
    @AuraEnabled
    public static string getPhone(id contactId){
        
		list<Contact> contact = [Select Phone from Contact where Id =:contactId];

		return contact.get(0).Phone;        
        
    }
    
}