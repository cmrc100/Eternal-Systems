public class RecordTypeSelectorController {

	public static Map<Id, String> recordtypemap {get;set;}
    
   	@AuraEnabled        
    public static map<Id, string> fetchRecordTypeValues(string objName){
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        List<Schema.RecordTypeInfo> recordtypes = schemaMap.get(objName).getDescribe().getRecordTypeInfos();    
        recordtypemap = new Map<Id, string>();
        for(RecordTypeInfo rt : recordtypes){
            if(rt.getName() != 'Master' && rt.isActive() && rt.isAvailable())
            	recordtypemap.put(rt.getRecordTypeId(), rt.getName());
        }        
        return recordtypemap;
    }

}