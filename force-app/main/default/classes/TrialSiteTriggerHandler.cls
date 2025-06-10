public class TrialSiteTriggerHandler {
    public static Boolean processed = false;
	@future(callout=true)
    public static void updateLatLong(Map<String,String> trialSitesData) {
        System.debug('-----------updateLatLong-----------');
        Map<String,Object> addressData;
        Map<String,Object> latLongData;
        List<Trial_Site__c> trialSitesToUpdate = new List<Trial_Site__c>();
        Trial_Site__c trialSiteInst;
        for(String trialSiteInstId : trialSitesData.keySet()) {
            try {
                addressData = SearchAddressService.getAddressDetails(trialSitesData.get(trialSiteInstId));
                System.debug('---addrDetails---'+addressData);
                trialSiteInst = new Trial_Site__c(Id=trialSiteInstId);
                trialSiteInst.Geolocation_API_Error_Message__c = null;
                trialSiteInst.Geolocation__Latitude__s = null;
                            trialSiteInst.Geolocation__Longitude__s = null;
                if(Boolean.valueOf(addressData.get('IsSuccess'))) {
                    latLongData = SearchAddressService.getLatLong(String.valueOf(addressData.get('body')));
                    System.debug('--latLongData---'+latLongData);
                    if(latLongData != null && latLongData.isEmpty() == false) {
                        
                        Decimal latData = latLongData.get('lat') !=null ? (Decimal)latLongData.get('lat') : null;
                        Decimal lonData = latLongData.get('lon') !=null ? (Decimal)latLongData.get('lon') : null;
                        if(latData != null && lonData != null) {
                            trialSiteInst.Geolocation__Latitude__s = latData;
                            trialSiteInst.Geolocation__Longitude__s = lonData;
                        }
                    }
                    else {
                        trialSiteInst.Geolocation_API_Error_Message__c = 'Invalid Address, Please provide a valid address.';
                    }
                }// end of IsSuccess == true
                else {
                    trialSiteInst.Geolocation_API_Error_Message__c = String.valueOf(addressData.get('body'));  
                }
            }
            catch(Exception exp) {
                trialSiteInst.Geolocation_API_Error_Message__c = 'Something went wrong with SearchAddressService';  
            }
            trialSitesToUpdate.add(trialSiteInst);
        }
        if(trialSitesToUpdate.isEmpty() == false) {
            TrialSiteTriggerHandler.processed = true;
            update trialSitesToUpdate;
        }
    }
    
    public static void processTrialSites(List<Trial_Site__c> lstTrialSites, Map<Id,Trial_Site__c> oldMapTrialSites) {
        System.debug('-----------processTrialSites-----------');
        if(TrialSiteTriggerHandler.processed == false) {
            Map<String,String> trialSitesData = new Map<String,String>();
            String addressStr;
            for(Trial_Site__c trialSiteInst : lstTrialSites) {
                //System.debug('-----------oldMapTrialSites == null-----------'+oldMapTrialSites); 
                //System.debug('-----------trialSiteInst.Geolocation__c == null-----------'+trialSiteInst.Geolocation__c);
                if(oldMapTrialSites == null ||
                (oldMapTrialSites != null && 
                (oldMapTrialSites.get(trialSiteInst.Id).Address__c != trialSiteInst.Address__c ||
                    oldMapTrialSites.get(trialSiteInst.Id).Postal_Code__c != trialSiteInst.Postal_Code__c ||
                    oldMapTrialSites.get(trialSiteInst.Id).Country__c != trialSiteInst.Country__c ||
                    oldMapTrialSites.get(trialSiteInst.Id).City__c != trialSiteInst.City__c)) ||
                (trialSiteInst.Geolocation__Latitude__s == null && trialSiteInst.Geolocation__Longitude__s == null)){
                    addressStr = ' ';
                    addressStr += ' '+trialSiteInst.Address__c != null ? trialSiteInst.Address__c+' ' : '';
                    addressStr += ' '+trialSiteInst.City__c != null ? trialSiteInst.City__c+' ' : '';
                    addressStr += ' '+trialSiteInst.StateProvince__c != null ? trialSiteInst.StateProvince__c+' ' : '';
                    addressStr += ' '+trialSiteInst.Postal_Code__c != null ? trialSiteInst.Postal_Code__c+' ' : '';
                    addressStr += ' '+trialSiteInst.Country__c != null ? trialSiteInst.Country__c : '';
                    

                    
                    //addressStr += ' '+trialSiteInst.City__c != null ? trialSiteInst.City__c : '';
                    if(String.isNotBlank(addressStr)) {
                        trialSitesData.put(trialSiteInst.Id, addressStr);
                    }
                }
            }
            System.debug('-----------trialSitesData-----------'+trialSitesData);
            if(trialSitesData.isEmpty() == false) {
                TrialSiteTriggerHandler.updateLatLong(trialSitesData);
            }
        }
    }
    
    

    
    @future(callout=true)
    
    public static void updateformLatLong(Map<String,String> GetFormCoordinates) {
        System.debug('-----------updateLatLong-----------');
        Map<String,Object> addressData;
        Map<String,Object> latLongData;
        List<Trial_Participant_Request__c> formSubmissionToUpdate = new List<Trial_Participant_Request__c>();
        Trial_Participant_Request__c formInst;
        for(String formInstId : GetFormCoordinates.keySet()) {
            
            try {
                addressData = SearchAddressService.getAddressDetails(GetFormCoordinates.get(formInstId));
                System.debug('---addrDetails---'+addressData);
                formInst = new Trial_Participant_Request__c(Id=formInstId);
                formInst.Geolocation_API_Error_Message__c = null;
                formInst.Form_Geolocation__Latitude__s = null;
                formInst.Form_Geolocation__Longitude__s = null;
                if(Boolean.valueOf(addressData.get('IsSuccess'))) {
                    
                    latLongData = SearchAddressService.getLatLong(String.valueOf(addressData.get('body')));
                    System.debug('--latLongData---'+latLongData);
                    if(latLongData != null && latLongData.isEmpty() == false) {
                        
                        Decimal latData = latLongData.get('lat') !=null ? (Decimal)latLongData.get('lat') : null;
                        Decimal lonData = latLongData.get('lon') !=null ? (Decimal)latLongData.get('lon') : null;
                        if(latData != null && lonData != null) {
                            formInst.Form_Geolocation__Latitude__s = latData;
                            formInst.Form_Geolocation__Longitude__s = lonData;
                        }
                    }
                    else{
                        
                        formInst.Geolocation_API_Error_Message__c = 'Invalid Address, Please provide a valid address.';
                    }
                }// end of IsSuccess == true
                else{
                    
                    formInst.Geolocation_API_Error_Message__c = String.valueOf(addressData.get('body'));  
                }
            }
            catch(Exception exp) {
                
                formInst.Geolocation_API_Error_Message__c = 'Something went wrong with SearchAddressService';  
            }
            
            formSubmissionToUpdate.add(formInst);
        }
        if(formSubmissionToUpdate.isEmpty() == false) {
            
            TrialSiteTriggerHandler.processed = true;
            update formSubmissionToUpdate;
        }
    }

      public static void processFormPostalCode(List<Trial_Participant_Request__c> FormCoordinateslist) {
          
        System.debug('-----------processFormPostalCode-----------');
          
        if(TrialSiteTriggerHandler.processed == false) {
            Map<String,String> FormCoordinates = new Map<String,String>();
            String addressStr;
            
            for(Trial_Participant_Request__c Coordinates : FormCoordinateslist) {
                
                if(Coordinates.Postal_Code__c!=null && Coordinates.Country__c!=null &&  Coordinates.Form_Geolocation__Latitude__s == null && Coordinates.Form_Geolocation__Longitude__s  == null){
                    
                    addressStr = '';
                     
                    if(Coordinates.Postal_Code__c.contains(' ')||Coordinates.Postal_Code__c.contains('-')||Coordinates.Postal_Code__c.length()>6)
                    {
                        addressStr += ' '+Coordinates.Postal_Code__c != null ? Coordinates.Postal_Code__c : '';
                    
                    }
                    else{
                        
                        addressStr += ' '+Coordinates.Postal_Code__c != null ? Coordinates.Postal_Code__c +'-' : '';
                    }
                    
                        addressStr += ' '+Coordinates.Country__c != null ? Coordinates.Country__c : '';
                      if(String.isNotBlank(addressStr)) {
                        FormCoordinates.put(Coordinates.Id, addressStr);
                    }
                }
            }
            
            System.debug('-----------FormCoordinates-----------'+FormCoordinates);
            if(FormCoordinates.isEmpty() == false) {
                
                TrialSiteTriggerHandler.updateformLatLong(FormCoordinates);
            }
        }
    }
}