public class AnimalLocator {

    public static string getAnimalNameById(integer animalId){
		
        string returnVal = '';
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(' https://th-apex-http-callout.herokuapp.com/animals/' + animalId);
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        // If the request is successful, parse the JSON response.
        if (response.getStatusCode() == 200) {
            // Deserializes the JSON string into collections of primitive data types.
            TrailheadAnimal t = TrailheadAnimal.parse(response.getBody());
            // Cast the values 
            returnVal = t.animal.name;
        }
        return returnVal;        
        
    }
    
}