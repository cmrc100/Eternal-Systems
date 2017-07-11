public class AddPrimaryContact implements Queueable {
    
    private Contact contact;
    private string state;
    
    public AddPrimaryContact(Contact c, string theState) {
        this.contact = c;
        this.state = theState;
    }

    public void execute(QueueableContext context) {
        
        list<Account> accountList = [select Id from Account where BillingState = :state];
        list <Contact> contactList = new list<Contact>();
        
        for (Account account : accountList) {
			Contact c = this.contact.clone();
			c.AccountId = account.Id;
			contactList.add(c);
        }
        
        insert contactList;
    }
    
}