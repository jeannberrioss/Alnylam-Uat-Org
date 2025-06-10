@isTest
public with sharing class PAE_QuestionnaireConfigurationTest {
    @isTest
    static void testUpdate() {
        
        /*Trial_Participant_Request_Setup__mdt setting = new Trial_Participant_Request_Setup__mdt();
        setting.Form_Type__c = 'Investigator';
        setting.Column__c = 1;
        setting.Order__c = 1;
        setting.Required__c = false;
        Setting.MasterLabel = 'First_Name__c';
        setting.DeveloperName  = 'First_Name_c';*/
        //insert setting;
        


        Trial_Site__c trialRec =  new Trial_Site__c();
        trialRec.CRO__c = 'MedpaceTest';
        trialRec.Address__c = 'Medical Center Blvd';
        trialRec.Postal_Code__c = '123456';
        trialRec.Country__c = 'United States';
        trialRec.City__c = 'Winston-Salem';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SearchAddressServiceMock());
        insert trialRec;
        trialRec.Address__c = 'Medical Center Blvd Test';       
        update trialRec;
        Test.stopTest();   
        
        //this._country +' '+this._postalCode
        List<Trial_Site__c>  T = PAE_TrailRequestControllerCls.getNearByTrialSites('us'+' '+trialRec.Postal_Code__c,'51-100','mi',trialRec.Id);
    }
    @isTest
    static void testCreate() {
        Trials__c Trial =  new Trials__c();
        Trial.Disease__c = 'Acute Hepatic Porphyria (AHP);ATTR amyloidosis w/ polyneuropathy;ATTR amyloidosis w/cardiomyopathy';
        Trial.Name  = 'AGT01 FIH';
        Trial.Protocol_ID__c = 'ALN-AGT01-001';
        insert Trial;

        Trial_Participant_Request__c obj = new Trial_Participant_Request__c();
        obj.First_Name__c = 'Test';
        obj.Last_Name__c = 'Test';
        
        PAE_TrailRequestControllerCls.lwcresponse res = PAE_TrailRequestControllerCls.craete(obj);

        PAE_TrailRequestControllerCls.FieldSetForm res1 = PAE_TrailRequestControllerCls.getForm('Investigator');

        //list<sObject> fetchLookupData(string Disease , string sObjectApiName) {    
            list<sObject> data = PAE_TrailRequestControllerCls.fetchLookupData('ATTR amyloidosis w/cardiomyopathy', 'Trials__c');
            data = PAE_TrailRequestControllerCls.f_Get_Types('ATTR amyloidosis w/cardiomyopathy');
    }
}