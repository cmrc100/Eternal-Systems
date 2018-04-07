public with sharing class myDataCollectorController{


    @AuraEnabled
    public static list<Sobject> getTheRecs(){
    
        list<Sobject> theRecs= [select Id, FirstName, LastName, Email from Contact];
        
        return theRecs;
    
    
    }

    @AuraEnabled
    public static list<string> getTheFlds(){
    
        list<string> theFields= new list<string>{'Id','FirstName','LastName','Email'};
        
        return theFields;
    
    
    }    
    

}