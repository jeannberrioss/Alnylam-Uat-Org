public class GeoLocationZipCode {
     
    @InvocableMethod
    public static List<ReturnVariables> myMethod(List<inputVariables> inputVariables){
    
	  string Latt = inputVariables[0].Lat;
      string Lonn= inputVariables[0].Lon;
	  ID Trialname=inputVariables[0].TrialName;
      ID recordId = inputVariables[0].recId;
      
        
        System.debug(Trialname);
        
      list<Trial_Participant_Request__c> formidanddistance= [Select Id, Case__c, Miles_You_are_Prepared_To_Travel__c FROM Trial_Participant_Request__c where Case__c=: recordId];
        
         string        distance ;
		 String PreparedToTravel; 
         String      queryString;
         
        for( Trial_Participant_Request__c dis :formidanddistance ){
            PreparedToTravel=dis.Miles_You_are_Prepared_To_Travel__c;
            System.debug(PreparedToTravel);
            if(PreparedToTravel=='Less than 20'){
                distance = 'DISTANCE(Geolocation__c, GEOLOCATION('+Latt+','+Lonn+'), \'mi\')<20 ';
                 
            }
            else if(PreparedToTravel=='21-40')
            {
                 distance = 'DISTANCE(Geolocation__c, GEOLOCATION('+Latt+','+Lonn+'), \'mi\')>19 AND DISTANCE(Geolocation__c, GEOLOCATION('+Latt+','+Lonn+'), \'mi\')<40';
            }
            else if(PreparedToTravel=='41-80'){
                
                 distance = 'DISTANCE(Geolocation__c, GEOLOCATION('+Latt+','+Lonn+'), \'mi\')>39 AND DISTANCE(Geolocation__c, GEOLOCATION('+Latt+','+Lonn+'), \'mi\')<80';
           		
            }
            else if(PreparedToTravel=='Over 81'){
                 distance = 'DISTANCE(Geolocation__c, GEOLOCATION('+Latt+','+Lonn+'), \'mi\')>79';
            }
            else if(String.isBlank(PreparedToTravel)){
                 
                 distance=null;
            }
         
        }
       
        
   // Querying trial sites to display in screen flow
        if(distance==null)
        {
          queryString ='SELECT Id,name, Flag_Site__c, Site_Name__c,Site_Status__c, Distance__c, Address__c, Postal_Code__c, Geolocation_API_Error_Message__c, City__c, Country__c, StateProvince__c, Phone_Number__c'+
              ' FROM Trial_Site__c Where Trial__c = \''+ Trialname + '\''+
              ' ORDER BY DISTANCE(Geolocation__c, GEOLOCATION('+Latt+','+Lonn+'), \'mi\')  ' ;
        }
        else 
        {
            System.debug('Line no 146 : '+distance);
          queryString ='SELECT Id,name, Flag_Site__c, Site_Name__c,Site_Status__c, Distance__c, Address__c, Postal_Code__c, Geolocation_API_Error_Message__c, City__c, Country__c, StateProvince__c, Phone_Number__c'+
              ' FROM Trial_Site__c Where Trial__c = \''+ Trialname + '\''+
              ' AND ' +distance+
              ' ORDER BY DISTANCE(Geolocation__c, GEOLOCATION('+Latt+','+Lonn+'), \'mi\')  ' ;
        }
        System.debug('Line no 143 : '+distance);
        List<Trial_Site__c> Siterelativedistance =Database.query(queryString);
        System.debug('Line no 144 : '+Siterelativedistance.size());
        Decimal latt1=Decimal.valueOf(Latt);
        Decimal long1=Decimal.valueOf(Lonn);
        System.debug(latt1 + ' ' + long1);
        //get location of form subission
        Location Loc1 = Location.newInstance(latt1, long1);         
          
        // map(trialsite id,calculated distance between form submission and trial site locations)
        Map<id,Integer> dist2=new Map<id,Integer>();
        
        //list of trial sites for the calculation of distance
        List<Trial_Site__c> ListOfsite=[SELECT Id, Address__c, City__c, Country__c, StateProvince__c,  Geolocation__Latitude__s, Geolocation__Longitude__s FROM Trial_Site__c Where Trial__c =: Trialname ];
       
        for(Trial_Site__c Sitelist:ListOfsite)
        {    
             System.debug(Sitelist.Geolocation__Latitude__s + ' ' + Sitelist.Geolocation__Longitude__s);
        //get location of the trial sites
        Location Loc2 = Location.newInstance(Sitelist.Geolocation__Latitude__s, Sitelist.Geolocation__Longitude__s);
            
        //add values to the map
        dist2.Put(Sitelist.id,(Integer) loc1.getDistance(loc2, 'mi')); 
        System.debug(loc1.getDistance(loc2, 'mi'));
        }
        
        for(Trial_Site__c trialSiteID : Siterelativedistance)
        {
           if(dist2.containskey(trialSiteID.id))
            trialSiteID.Distance__c=dist2.get(trialSiteID.id);
           
        } 
      List<ReturnVariables> newList= new List<ReturnVariables>();
      ReturnVariables returnVars= new ReturnVariables();
      returnVars.trialSitesSorted= Siterelativedistance; 
      newList.add(returnVars);
        System.debug('Line no 185 : '+newList.size());
       return newList;
    }
    
     //Obtain the Latt,Long and TrialName from Flow of the form submission   
      public class inputVariables{
            @InvocableVariable
            public string Lat;
            @InvocableVariable
            public string Lon;
            @InvocableVariable
            public ID TrialName;
            @InvocableVariable
            public ID recId;
        }

     //Returns filterd list of trial sites with distance   
      public class ReturnVariables{
            @InvocableVariable
            public List<Trial_Site__c> trialSitesSorted;
          
        }

}