@isTest
private class ParkLocatorTest {

    @isTest static void testCallout() {              
        // This causes a fake response to be generated
        Test.setMock(WebServiceMock.class, new ParkServiceMock());
        // Call the method that invokes a callout

        list<string> result = ParkLocator.country('England');
        // Verify that a fake result is returned
        System.assertEquals(result.size(), 2);
        
    }    
    
}