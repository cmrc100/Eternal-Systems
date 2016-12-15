public with sharing class StudentQBEForm {

	@AuraEnabled
	public static List<Course__c> getCourses(){
		
		return [select Id, Name from Course__c order by name];
		
	}
    
}