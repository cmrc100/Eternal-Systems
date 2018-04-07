({
    

    sendToVF : function(component, helper) {
      
        //Prepare message in the format required in VF page
        var message = {
			            "loadGoogleMap" : true,
            			"mapData": component.get('v.mapData'), 
            			"mapOptions": component.get('v.mapOptions'),  
                       	'mapOptionsCenter': component.get('v.mapOptionsCenter'),
            			'googleMapApiKey': component.get('v.googleMapApiKey'),
            			'mapItApiKey': component.get('v.mapItApiKey'),
            			'vfHost':  component.get("v.vfHost"),
            			'editMode': component.get("v.editMode"),
            			'defaultLocationPostcode' : component.get("v.defaultLocationPostcode"),
            			'ward' : component.get("v.ward"),
            			'wardCode': component.get("v.wardCode"),
            			'borough': component.get("v.borough")
        		};

        

        //Send message to VF
        helper.sendMessage(component, helper, message);

    },

    sendMessage: function(component, helper, message){

        //Send message to VF
        try {
            message.origin = window.location.hostname;
            var vfWindow = component.find("vfFrame").getElement().contentWindow;
            vfWindow.postMessage(JSON.parse(JSON.stringify(message)), component.get("v.vfHost"));
        } catch (e) {
        	console.log(e.message);    
        }
    },
    
    navigateToParent: function(component, event, helper, state){
        if (state === 'UPDATE'){
            var navEvt = $A.get("e.force:navigateToSObject");
            var recId = component.get("v.parentId");
            navEvt.setParams({
                "recordId": recId      		
            });
            navEvt.fire();        
        }
    },
    loadMap: function(component, event, helper){

        //Set vfHost which will be used later to send message        
        component.set('v.vfHost', event.data.vfHost);
        
        var parentObject = component.get("v.sObjectName");
        console.log('@@@@@ parentObject  ..  ' + parentObject);
        if (parentObject){
            if (parentObject === component.get("v.objectName")){
                var currentLatLng = component.get("v.simpleRecord.Latitude_Longitude__c");
               
                if (currentLatLng){
                    var lat = currentLatLng.split(',')[0].trim();
                    var lng = currentLatLng.split(',')[1].trim();
                    var mapData = [];
                    var latLngData = {};
                    latLngData["lat"] = lat;
                    latLngData["lng"] = lng;
                    mapData.push(latLngData);
                    component.set("v.mapData", mapData);
                    console.log(JSON.stringify(mapData));                    
                }
 
            }                    
        }
	},
    
    saveNewRecord: function(component, event, helper){
        var latLng =  component.get("v.lngLat");               
        var recTypeId = component.get("v.recordTypeId");                
        var parentIdField = component.get("v.parentIdField");
        var address = component.get("v.address");
        var city = component.get("v.city");                
        var postCode = component.get("v.postCode");
        var localAuthority = component.get("v.localAuthority");
        var ward = component.get("v.ward");
        var wardCode = component.get("v.wardCode");
        var borough = component.get("v.borough");
        var LSOAName = component.get("v.lsoa");
        var LSOACode = component.get("v.lsoaCode");               
        var MSOAName = component.get("v.msoa");
        var MSOACode = component.get("v.msoaCode");
        var locationUrl = component.get("v.locationUrl");
        var mapUrl = ''; // eg. 'http://maps.google.co.uk/?q=51.582029929065825,-0.08934974670410156&z=10'
        
        if (event.data.lat){
            mapUrl = 'https://maps.google.co.uk/?q=' + event.data.lat.split(',')[0] + ',' + event.data.lat.split(',')[1] + '&z=10';
        }
        
        var objValues= {};
        objValues[parentIdField] = component.get("v.parentId");                
        if (latLng) objValues[latLng] = event.data.lat;                 
        if (address) objValues[address] = event.data.address;
        if (city) objValues[city] = event.data.city;
        if (localAuthority) objValues[localAuthority] = event.data.localAuthority;                
        if (postCode) objValues[postCode] = event.data.postcode;
        if (ward) objValues[ward] = event.data.ward;                
        if (wardCode) objValues[ward] = event.data.wardCode;
        if (borough) objValues[ward] = event.data.borough;
        if (LSOAName) objValues[LSOAName] = event.data.LSOAName;
        if (LSOACode) objValues[LSOACode] = event.data.LSOACode;                
        if (MSOAName) objValues[MSOAName] = event.data.MSOAName;
        if (MSOACode) objValues[MSOACode] = event.data.MSOACode;
        if (locationUrl) objValues[locationUrl] = mapUrl;
        
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": component.get('v.objectName'),   
            "recordTypeId" : recTypeId,
            "defaultFieldValues": objValues
        });
        createRecordEvent.fire();
                       
    },
    saveEditRecord: function(component, event, helper){
        try {
            var latLng =  component.get("v.lngLat");               
            var recTypeId = component.get("v.recordTypeId");                
            var parentIdField = component.get("v.parentIdField");
            var address = component.get("v.address");
            var city = component.get("v.city");                
            var postCode = component.get("v.postCode");
            var localAuthority = component.get("v.localAuthority");
            var ward = component.get("v.ward");
            var wardCode = component.get("v.wardCode");
            var borough = component.get("v.borough");
            var LSOAName = component.get("v.lsoa");
            var LSOACode = component.get("v.lsoaCode");               
            var MSOAName = component.get("v.msoa");
            var MSOACode = component.get("v.msoaCode");
            var locationUrl = component.get("v.locationUrl");
            var mapUrl = ''; // eg. 'http://maps.google.co.uk/?q=51.582029929065825,-0.08934974670410156&z=10'
    		
            if (event.data.lat){
                mapUrl = 'https://maps.google.co.uk/?q=' + event.data.lat.split(',')[0] + ',' + event.data.lat.split(',')[1] + '&z=10';
            }
            // edit record
            var editRecordEvent = $A.get("e.force:editRecord");
            var objEdit = component.get("v.simpleRecord");
            if (latLng) objEdit[latLng] = event.data.lat;                 
            if (address) objEdit[address] = event.data.address;
            if (city) objEdit[city] = event.data.city;
            if (localAuthority) objEdit[localAuthority] = event.data.localAuthority;                
            if (postCode) objEdit[postCode] = event.data.postcode;
            if (ward) objEdit[ward] = event.data.ward;
            if (wardCode) objEdit[wardCode] = event.data.wardCode;
            if (borough) objEdit[borough] = event.data.borough;
            if (LSOAName) objEdit[LSOAName] = event.data.LSOAName;
            if (LSOACode) objEdit[LSOACode] = event.data.LSOACode;                
            if (MSOAName) objEdit[MSOAName] = event.data.MSOAName;
            if (MSOACode) objEdit[MSOACode] = event.data.MSOACode;
            if (locationUrl) objEdit[locationUrl] = mapUrl;
            
            objEdit.Id = component.get("v.recordId");
            component.find("recordLoader").saveRecord($A.getCallback(function(saveResult) {
                if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                    console.log("Save completed successfully.");
                    console.log('@@@@@@  saveResult   ' + JSON.stringify(saveResult));
                    //editRecordEvent.setParams({
                    //    "recordId": component.get("v.recordId")
                    //});                            
                    //editRecordEvent.fire();
                    
                    var navEvt = $A.get("e.force:navigateToSObject");
                        navEvt.setParams({
                          "recordId": objEdit.Id
                        });
                        navEvt.fire();                    
                   
                } else if (saveResult.state === "INCOMPLETE") {
                    console.log("User is offline, device doesn't support drafts.");
                } else if (saveResult.state === "ERROR") {
                    console.log('Problem saving record, error: ' + 
                                JSON.stringify(saveResult.error));
                } else {
                    console.log('Unknown problem, state: ' + saveResult.state + ', error: ' + JSON.stringify(saveResult.error));
                }
            }));
        } catch(e){
            console.log('@@@@ ERROR ... ' + e.message);
        }                    
        
    },
    
})