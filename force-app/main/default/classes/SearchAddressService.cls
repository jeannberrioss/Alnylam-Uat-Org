public with sharing class SearchAddressService {
    public static Map<String,Object> getAddressDetails(String addressToSearch) {
        Map<String,Object> returnBody = new Map<String,Object>();
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        String endpointURL = Label.MicrosoftAtlasAddressSearchURL;
        endpointURL += '/json?subscription-key='+Label.MicrosoftAtlasSubsKey;
        endpointURL += '&api-version=1.0&language=en-US';
        endpointURL += '&query='+EncodingUtil.urlEncode(addressToSearch, 'UTF-8');
        req.setEndpoint(endpointURL);
        req.setMethod('GET');
        system.debug('req--> '+req);
        HttpResponse res = h.send(req);
        system.debug('res.getStatusCode()--> '+res.getStatusCode());
        if(res.getStatusCode() == 200) {
            returnBody.put('IsSuccess', true);
            system.debug('res.getBody()--> '+res.getBody());
            returnBody.put('body', res.getBody());

        }
        else {
            returnBody.put('IsSuccess', false);
            returnBody.put('body', res.getStatus());
        }
        system.debug('returnBody--> '+returnBody);
        system.debug('returnBody--> '+JSON.serialize(returnBody));
        return returnBody;
       
    }
    
    public static Map<String,Object> getLatLong(String responseBody){
        Map<String,Object> respData = (Map<String,Object>)Json.deserializeUntyped(responseBody);
        List<Object> addressesLst;
        Map<String,Object> adderssData;
        if(respData.containsKey('results')){
            addressesLst = (List<Object>) respData.get('results');
            
            if(addressesLst.isEmpty() == false) {
                adderssData = (Map<String,Object>) addressesLst[0];
                if(adderssData.containsKey('position')){
                    return ((Map<String,Object>)adderssData.get('position'));
                }
            }
            
        }
        return null;
    }

}