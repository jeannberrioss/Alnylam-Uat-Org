@isTest
public class GeoLocationZipCodeTest {

    @IsTest
    static void setupTestData() {
        
        
        Trials__c trials1=new Trials__c();
        trials1.Protocol_ID__c ='ALN-AGT01-002';
        insert trials1;
      Case Case1=new Case();
        Case1.Status ='Form Submitted';
        Case1.Origin = 'Web';
        insert Case1;
        //List Of Form Submission Record
        List<Trial_Participant_Request__c> ListForm=new List<Trial_Participant_Request__c>();
        
        //Create Form submission Records 
        
        Trial_Participant_Request__c Form1=new Trial_Participant_Request__c();
        Form1.Birth_Month_and_Year__c ='08/1999';
        Form1.Form_Geolocation__Latitude__s=37.7749;
        Form1.Form_Geolocation__Longitude__s=-122.4194;
        Form1.Miles_You_are_Prepared_To_Travel__c='Less than 20';
        Form1.Case__c=Case1.id;
		ListForm.add(Form1);  
        
        Trial_Participant_Request__c Form2=new Trial_Participant_Request__c();
        Form2.Birth_Month_and_Year__c ='08/1999';
        Form2.Form_Geolocation__Latitude__s=37.7749;
        Form2.Form_Geolocation__Longitude__s=-122.4194;
        Form2.Miles_You_are_Prepared_To_Travel__c='21-40';
        Form2.Case__c=Case1.id;
        ListForm.add(Form2); 
        
        Trial_Participant_Request__c Form3=new Trial_Participant_Request__c();
        Form3.Birth_Month_and_Year__c ='08/1999';
        Form3.Form_Geolocation__Latitude__s=37.7749;
        Form3.Form_Geolocation__Longitude__s=-122.4194;
        Form3.Miles_You_are_Prepared_To_Travel__c='41-80';
        Form3.Case__c=Case1.id;
        ListForm.add(Form3);
        
        Trial_Participant_Request__c Form4=new Trial_Participant_Request__c();
        Form4.Birth_Month_and_Year__c ='08/1999';
        Form4.Form_Geolocation__Latitude__s=37.7749;
        Form4.Form_Geolocation__Longitude__s=-122.4194;
        Form4.Miles_You_are_Prepared_To_Travel__c='Over 81';
        Form4.Case__c=Case1.id;
        ListForm.add(Form4); 
        
        Trial_Participant_Request__c Form5=new Trial_Participant_Request__c();
        Form5.Birth_Month_and_Year__c ='08/1999';
        Form5.Form_Geolocation__Latitude__s=37.7749;
        Form5.Form_Geolocation__Longitude__s=-122.4194;
        Form5.Case__c=Case1.id;
        ListForm.add(Form5);
        
        insert ListForm;
        
        //Create Trial Site Records
        Trial_Site__c  trialSites=new Trial_Site__c();
        trialSites.Trial__c = trials1.Id;
        trialSites.Flag_Site__c='possibly enrolling';
        trialSites.Geolocation__Latitude__s = 40.697329; // Test latitude value
        trialSites.Geolocation__Longitude__s = -74.2914952; // Test longitude value
        
       	insert trialSites;
        Trial_Site__c  trialSites1=new Trial_Site__c();
        trialSites1.Trial__c = trials1.Id;
        trialSites1.Flag_Site__c='not enrolling';
        trialSites1.Geolocation__Latitude__s = 40.697329; // Test latitude value
        trialSites1.Geolocation__Longitude__s = -74.2914952; // Test longitude value
        
        insert trialSites1;
        GeoLocationZipCode.inputVariables inputVar = new GeoLocationZipCode.inputVariables();
       
        inputVar.Lat = String.valueOf(Form1.Form_Geolocation__Latitude__s);
        inputVar.Lon = String.valueOf(Form1.Form_Geolocation__Longitude__s);
        inputVar.TrialName = trials1.Id;
        inputVar.recId = Case1.Id;
              
       	List<GeoLocationZipCode.inputVariables> inputList = new List<GeoLocationZipCode.inputVariables>();
       	inputList.add(inputVar);
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new SearchAddressServiceMock());
		GeoLocationZipCode.myMethod(inputList);
        Test.stopTest();


    
    }
}