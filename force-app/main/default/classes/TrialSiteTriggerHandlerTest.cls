@isTest
private class TrialSiteTriggerHandlerTest {    
    @isTest
    static void testUpdate() {
         Trials__c trials1=new Trials__c();
        trials1.Protocol_ID__c ='ALN-AGT01-002';
        insert trials1;
        Trial_Site__c trialRec =  new Trial_Site__c();
        trialRec.Trial__c = trials1.id;
        trialRec.CRO__c = 'MedpaceTest';
        trialRec.Address__c = 'Medical Center Blvd';
        trialRec.Postal_Code__c = '123456';
        trialRec.Country__c = 'United States';
        trialRec.City__c = 'Winston-Salem';
        
        list<Trial_Participant_Request__c> FormList=new List<Trial_Participant_Request__c>();
        Trial_Participant_Request__c FormRec1 =  new Trial_Participant_Request__c();
        FormRec1.First_Name__c = 'test 1';
        FormRec1.Last_Name__c = 'Form';
        FormRec1.Birth_Month_and_Year__c='06/2000';
        FormRec1.Which_study_are_you_interested_in__c = trials1.id;
        FormRec1.Country__c = 'United States';
        FormRec1.Postal_Code__c = '123456';
        FormList.add(FormRec1);
        Trial_Participant_Request__c FormRec2 =  new Trial_Participant_Request__c();
        FormRec2.First_Name__c = 'test 1';
        FormRec2.Last_Name__c = 'Form';
        FormRec2.Birth_Month_and_Year__c='06/2000';
        FormRec2.Which_study_are_you_interested_in__c = trials1.id;
        FormRec2.Country__c = 'United States';
        FormRec2.Postal_Code__c = '585-222';
        FormList.add(FormRec2);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SearchAddressServiceMock());
        insert trialRec;
        insert FormList;
        trialRec.Address__c = 'Medical Center Blvd Test';       
        update trialRec;
        Test.stopTest();        
    }
    
     @isTest
    static void testUpdate1() {
        Trials__c trials1=new Trials__c();
        trials1.Protocol_ID__c ='ALN-AGT01-002';
        insert trials1;
        list<Trial_Participant_Request__c> FormList=new List<Trial_Participant_Request__c>();
        Trial_Participant_Request__c FormRec3 =  new Trial_Participant_Request__c();
        FormRec3.First_Name__c = 'test 1';
        FormRec3.Last_Name__c = 'Form';
        FormRec3.Birth_Month_and_Year__c='06/2001';
        FormRec3.Which_study_are_you_interested_in__c = trials1.id;
        FormRec3.Country__c = 'afghanistan';
        FormRec3.Postal_Code__c = '1654842625';
        FormList.add(FormRec3);
        Trial_Participant_Request__c FormRec2 =  new Trial_Participant_Request__c();
        FormRec2.First_Name__c = 'test 1';
        FormRec2.Last_Name__c = 'Form';
        FormRec2.Birth_Month_and_Year__c='06/2000';
        FormRec2.Which_study_are_you_interested_in__c = trials1.id;
        FormRec2.Country__c = 'United States';
        FormRec2.Postal_Code__c = 'sz15151651';
        FormList.add(FormRec2);
        insert FormList;
        
        Test.startTest();
        //Test.setMock(HttpCalloutMock.class, new SearchAddressServiceMock());
        Test.setMock(HttpCalloutMock.class, new SearchAddressServiceMock());        
        Test.stopTest();    
        
    }
    
}