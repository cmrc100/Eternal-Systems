public with sharing class RoleTreeViewController {

    public Boolean selectable {get; set;}
    
    public String selectNodeKeys {get; set;}

    {
        selectable = false;
        selectNodeKeys = 'No value selected';
    }
    
    public String JsonData {get; set;}
    
    public String getJsonString() 
    {

        return JsonData;
    }


//////////////////////////////////////////////////////////////////////////////////

    /************************/
    /***** TEST METHODS *****/
    /************************/
	@isTest(seeAllData=true)
	
	static void TestProductTreeViewController() {
   
		RoleTreeViewController  testController = new RoleTreeViewController();   		
   		testController.selectable = true;
   		system.assertEquals(true, testController.selectable);

   		testController.selectable = true;
   		system.assertEquals( 'No value selected', testController.selectNodeKeys);   		
   		
   		testController.JsonData = 'test';
   		system.assertEquals('test', testController.getJsonString());
   	
   }

}