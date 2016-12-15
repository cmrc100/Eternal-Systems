public with sharing class PanicButtonServerController {

    @AuraEnabled
    public static list<SoundClip__c> getMedia(){
        
        return [select Name, fileUrl__c from SoundClip__c];
        
    }
    
    
}