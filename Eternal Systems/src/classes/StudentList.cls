public with sharing class StudentList {
  
  @AuraEnabled
  public static List<Course_Attendee__c> getStudents(String studentName,String courseId,String startDate,String endDate) {
      
     String query = 'SELECT ';
     query = query + 'Course_Delivery__r.Start_Date__c, ' ;
     query = query + 'Course_Delivery__r.Course__r.Name, ';
     query = query + 'Course_Delivery__r.Course__r.id, ';
     query = query + 'name,  Student__r.name, Student__r.email, Student__r.mobilePhone, Student__r.title, student__r.Account.Name ';
     query = query + 'from Course_Attendee__c ';
     query = query + 'WHERE name <> \'\'';
     
     if (studentName != '') {
       query = query + ' and Student__r.name like ' +  '\'%'+ String.escapeSingleQuotes(studentName) + '%\'';
     }
        
     if (courseId != '') {
       query = query + ' and Course_Delivery__r.Course__r.id = \'' + String.escapeSingleQuotes(courseId) + '\'';   
     } 
     
     if (startDate != '') {
       query = query + ' and Course_Delivery__r.Start_Date__c >= '  + String.escapeSingleQuotes(startDate);
     }
      
     if (endDate != '') {
       query = query + ' and Course_Delivery__r.Start_Date__c < '  + String.escapeSingleQuotes(endDate);
     } 
      
     query = query + ' order by Student__r.name';
      
     List<sObject> sobjList = Database.query(query);
      
     return sobjList;
  }  
}