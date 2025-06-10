public without sharing class PAE_TrailRequestControllerCls {
  /*  @AuraEnabled
    public static FieldSetForm getForm(Id recordId, String objectName, String fieldSetName) {
        FieldSetForm form = new FieldSetForm();        
        form.Fields = getFields(recordId, objectName, fieldSetName);
        
        return form;
    }*/
    @AuraEnabled
    public static lwcresponse craete(Trial_Participant_Request__c detals) {
        lwcresponse res = new lwcresponse();
       try{
            insert detals;
            res.msg = 'Sucess';
            res.sucess = true;
       }catch(Exception ex){
            res.msg = ex.getMessage();
            res.sucess = false;
       }
       return res;
    }

    @AuraEnabled
    public static FieldSetForm getForm(String fieldSetName) {
        FieldSetForm form = new FieldSetForm();        
        form.Fields = getFields(fieldSetName);
        
        return form;
    }
    private static List<FormField> getFields(String fieldSetName) {
        List<FormField> fields = new List<FormField>();
        
        for(Trial_Participant_Request_Setup__mdt fsm : [Select Id,Custom_Label__c, DeveloperName,MasterLabel,Column__c,Form_Type__c,Order__c,Required__c from Trial_Participant_Request_Setup__mdt where Form_Type__c=:fieldSetName order by Order__c ]){
            FormField f = new FormField(fsm);
            fields.add(f);
        }
        return fields;
    }
   /* private static List<FormField> getFields(Id recordId, String objectName, String fieldSetName) {
        Schema.SObjectType objectType = null;
        
        if (recordId != null) {
            objectType = recordId.getSobjectType();
        }
        else if (String.isNotBlank(objectName)) {
            objectType = Schema.getGlobalDescribe().get(objectName);
        }
        
        Schema.DescribeSObjectResult objectDescribe = objectType.getDescribe();
        Map<String, Schema.FieldSet> fieldSetMap = objectDescribe.fieldSets.getMap();
        System.debug('>>>'+fieldSetMap);
        Schema.FieldSet fieldSet = fieldSetMap.get(fieldSetName);
        List<Schema.FieldSetMember> fieldSetMembers = fieldSet.getFields();
        
        List<FormField> fields = new List<FormField>();
        for (Schema.FieldSetMember fsm : fieldSetMembers) {
            FormField f = new FormField(fsm);
            fields.add(f);
        }
        
        return fields;
    }*/
    
    @AuraEnabled(cacheable=true)
    public static list<sObject> fetchLookupData(string Disease , string sObjectApiName) {    
        List < sObject > returnList = new List < sObject > ();
        string sQuery;
      //  string sWildCardText = '%' + searchKey + '%';
      if(Test.isRunningTest()){
        sQuery = 'Select Id,Name From ' + sObjectApiName + ' order by createdDate DESC LIMIT 100';
      }else{
         
         sQuery = 'Select Id,Name From ' + sObjectApiName + ' Where Disease__c INCLUDES :Disease order by createdDate DESC LIMIT 100';
      }
      
        System.debug('>>>'+sQuery);
        for (sObject obj: database.query(sQuery)) {
            returnList.add(obj);
        }
        return returnList;
    }
    @AuraEnabled(cacheable=true)
    public static List<sObject> f_Get_Types(string Diagnosis){
        System.debug('>>'+Diagnosis);
        try {
            List<sObject> l_Types = new List<sObject>();
               if(Diagnosis != ''){
                l_Types = [Select Id , Name,Trial_Name__c,Study_Name__c  from Trials__c  where Disease__c includes (:Diagnosis) AND (Flag__c = 'Recruiting')]; 
            }else{
                l_Types = [Select id, Name,Trial_Name__c,Study_Name__c,Flag__c from Trials__c where Flag__c = 'Recruiting']; 
            }
           
            return l_Types;
        } catch (Exception e) {
            System.debug('Exception: '+e.getMessage());
            return null;
        }
    }

    public class FieldSetForm {
        @AuraEnabled
        public List<FormField> Fields { get; set; }
        public FieldSetForm() {
            Fields = new List<FormField>();
        }
    }
    @AuraEnabled(cacheable=true)
    public static List<Nearby_Trial_Sites_Setting__mdt> nearbyTrialSitesFeatureSetting() {
        return [SELECT Active__c FROM Nearby_Trial_Sites_Setting__mdt WHERE DeveloperName = 'Nearby_Trial_Sites_Setting' ];
    }

    @AuraEnabled(cacheable=true)
    public static List<Trial_Site__c> getNearByTrialSites(String addressToSearch, String thresholdValue, String unit, String trialId) {
        List<Trial_Site__c> nearByTrialSites = new  List<Trial_Site__c> ();
         Map<String,Object> addressData = SearchAddressService.getAddressDetails(addressToSearch);
        System.debug('---addressData---'+addressData);
        if(Boolean.valueOf(addressData.get('IsSuccess'))) {
            Map<String,Object> latLongData = SearchAddressService.getLatLong((String.valueOf(addressData.get('body'))));
            System.debug('--latLongData---'+latLongData);
            List<String> thresholdLimits = thresholdValue.split('-');
            String rangeThresholdFilter = '';
            String distanceClause = 'DISTANCE(Geolocation__c, GEOLOCATION('+ latLongData.get('lat') +
            ',' + latLongData.get('lon')+'), ' +'\''+ unit +'\''+ ') ';
            if(thresholdLimits.size() == 1) {
                rangeThresholdFilter = distanceClause + thresholdLimits[0];
            }
            else {
                rangeThresholdFilter = distanceClause + ' > '+ (Integer.valueOf(thresholdLimits[0])-1) + ' AND ' + distanceClause + ' < ' + thresholdLimits[1];
            }
            if(latLongData != null) {
                String query = 'SELECT Name,Postal_Code__c,Country__c,City__c,StateProvince__c,Address__c, Geolocation__c, '+ distanceClause +
                                ' FROM Trial_Site__c WHERE '+ rangeThresholdFilter  + ' AND Trial__c =:trialId';
                System.debug('--query------>'+query);
                nearByTrialSites = +Database.query(query);

            }
        }
         return nearByTrialSites;
        
    }
    public class lwcresponse{
        @AuraEnabled
        public Boolean sucess;
        @AuraEnabled
        public String msg;
    }
}