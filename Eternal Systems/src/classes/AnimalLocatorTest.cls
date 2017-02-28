@isTest
private class AnimalLocatorTest {
	
    @isTest
    static void unitTest() {
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new AnimalLocatorMock()); 
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        string animal = AnimalLocator.getAnimalNameById(1);
system.debug('@@@ animal  ' + animal);       
        // Verify that the response received contains fake values
        System.assertEquals(animal, 'penguin');
    }
    
}