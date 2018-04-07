@isTest
public class StreetContactMapController_TEST {

    static testMethod void unitTest() {

        MockLocationAPI mockResponse = new MockLocationAPI();
        mockResponse.borough = 'Westminster';
        
        test.setMock(HttpCalloutMock.class, mockResponse);   
        test.startTest();
        StreetContactMapController  testController = new StreetContactMapController(); 

        string latlng = '50000,-1.55555';
		string href = 'http://test';
        string address = '1 High Street';

        string slaId = StreetContactMapController.getMapPoint(href, address,  latlng);

        list<string> laList = slaId.split('\\^');
    	system.AssertEquals(laList[0], 'Test Council');      


        //mockResponse.borough = 'not found';        
        //test.setMock(HttpCalloutMock.class, mockResponse);  
        //slaId = StreetContactMapUtility.getMapPoint('test', '', latlng);
        //testController.saveLocation();        
        
        test.stopTest();

    }    
    
    
    
}