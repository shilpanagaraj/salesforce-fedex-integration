public class FedexRestCallout 
{
    @AuraEnabled(cacheable=true)
    public static Map<String,String> getRate(String fromCountryCode, Integer fromPostalCode,  String toCountryCode, Integer toPostalCode, Integer weightInlbs)
    {        
        Map<String, String> serviceTypeNetFedExChargeMap = new Map<String, String>();
        String responsedata;
        String jsonData = '{ "accountNumber": { "value": "740561073"},"requestedShipment": {"shipper": { "address": { "postalCode": '+fromPostalCode+', "countryCode":  "'+fromCountryCode+'"}},"recipient": { "address": { "postalCode": '+toPostalCode+','
        +'"countryCode": "'+toCountryCode+'"}},"pickupType": "DROPOFF_AT_FEDEX_LOCATION","rateRequestType": ["ACCOUNT","LIST"],"requestedPackageLineItems": [{"weight": {"units": "LB","value":'+weightInlbs+'}}]}}';
        String accesstoken ;
        String instanceURL ;        
        Http httpCls = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://apis-sandbox.fedex.com/oauth/token');
        request.setMethod('POST');
        request.setTimeout(2 * 60 * 1000);
        request.setHeader('Content-Type','application/x-www-form-urlencoded');        
        request.setBody('grant_type=client_credentials'+ 
                        '&client_id=l7723e5b915b74417eb1a3ffe04734546f'+ 
                        '&client_secret=7a099164e9b14d11877565a913fe6d4c');        
        httpResponse response = httpCls.send(request); 
        if(response.getStatusCode() == 200)
        {            
          system.debug('Successfully retrieving access token' ); 
          map<string,Object> resultMap = (map<string,Object>)JSON.deserializeUntyped(response.getBody());
          accesstoken = (String)resultMap.get('access_token');
          instanceURL = (String)resultMap.get('instance_url');            
          Http http = new Http();
          HttpRequest httpReq = new  HttpRequest();
          httpReq.setEndpoint( 'https://apis-sandbox.fedex.com/rate/v1/rates/quotes' );
          httpReq.setMethod( 'POST' );
          httpReq.setHeader( 'Content-Type', 'application/json' );
          httpReq.setHeader( 'Accept', 'application/json' );
          httpReq.setHeader( 'Authorization', 'Bearer ' + accesstoken );
          httpReq.setBody( jsonData );
          HttpResponse httpRes = http.send( httpReq );
          if(httpRes.getStatusCode() == 200)
          {   
            system.debug('Successfully retrieving httpRes:'+httpRes.getBody());               
            ResponseWrapper responseWrapperObj  = new ResponseWrapper();
            responseWrapperObj = (ResponseWrapper)JSON.deserialize(httpRes.getBody(),ResponseWrapper.class);
            for(rateReplyDetails rdet  : (responseWrapperObj.output).rateReplyDetails)
            {
              for(ratedShipmentDetails dets : rdet.ratedShipmentDetails)
              {
                serviceTypeNetFedExChargeMap.put(rdet.serviceName, dets.totalNetFedExCharge);
                break;                            
               }
            }
            return serviceTypeNetFedExChargeMap; 
            }
           else 
           {
               system.debug('## error:'+httpRes.getBody()+' code:'+httpRes.getStatusCode() );
           }
        }
        else 
        {
            system.debug('## error:'+response.getBody()+' code:'+response.getStatusCode() );
        }
        return null;
    }


    //response wrapper classes
    public class ResponseWrapper
    {
        public output output;     
    }

    public class output
    {
        public List<rateReplyDetails> rateReplyDetails;
        
    }

    public class rateReplyDetails
    {
        public String serviceType;
        public String serviceName;
        public List<ratedShipmentDetails> ratedShipmentDetails;   
    }

    public class ratedShipmentDetails
    {
        public String rateType;
        public String totalNetFedExCharge;  
    }

}






