public with sharing class ExchangeRates {
    
   
  public class Wrapper{
     @AuraEnabled() public  pac_so_youn__Exchange_Rate__c rates {get;set;}
     @AuraEnabled() public List<pac_so_youn__Exchange_Rate__c> dates {get;set;}
     @AuraEnabled() public List<String> labels {get;set;}
    }
    
    @future(callout = true)
    public static void getExchangeRate(){
      
        List<String> CurrencyLabel = getBaseCyrrencyPicklistValues();  
       
        
        pac_so_youn__Rate__mdt url_adress = [SELECT pac_so_youn__url__c, pac_so_youn__access_key__c  FROM pac_so_youn__Rate__mdt LIMIT 1];
        List<pac_so_youn__Exchange_Rate__c> list_API_Calls = new  List<pac_so_youn__Exchange_Rate__c>();
        List<pac_so_youn__Log__c> log_List = new List<pac_so_youn__Log__c>();
        List<pac_so_youn__Exchange_Rate__c> upd_Exch_List = new List<pac_so_youn__Exchange_Rate__c>(); 
        
        // make HTTP Callout 
        HttpResponse response = makeAPIRestrequest(url_adress, 'latest');
        
        if(response.getStatusCode() == 200) {
        JSON2Apex result = JSON2Apex.parse(response.getBody());
        JSON2Apex.Rates rates =  result.rates;
           
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(rates));
        Map<String, Object>  newparApiCall = decriaseCyrrencyRatesResponsBody(result, rates, CurrencyLabel);
        
        pac_so_youn__Log__c log = new pac_so_youn__Log__c();
        log.pac_so_youn__Status_Code__c = String.valueOf(response.getStatusCode());
        log.pac_so_youn__Responsse_Body__c = String.valueOf(newparApiCall);    
       
              
        
             pac_so_youn__Exchange_Rate__c api_Data = new pac_so_youn__Exchange_Rate__c();
             List<pac_so_youn__Exchange_Rate__c> dates_Arr = [SELECT  pac_so_youn__Date__c,pac_so_youn__CAD__c,pac_so_youn__USD__c, pac_so_youn__GBP__c,pac_so_youn__EUR__c,pac_so_youn__BaseCurrency__c,
                                                              pac_so_youn__Log__r.pac_so_youn__Status_Code__c,pac_so_youn__Log__r.pac_so_youn__Responsse_Body__c 
                                                              FROM pac_so_youn__Exchange_Rate__c]; 
         
                  // if database is empty creating record
                  if(dates_Arr.isEmpty()){
                  
                          try{  
                          insert log;  
                          } catch(DmlException e){
                          System.debug('A DML exception has occurred in LOG: ' +
                          e.getMessage());
                          }      
                              
                                 for(String exchField:CurrencyLabel){
                                  for(String c : m.keySet()){
                                      if(exchField==c){
                                      api_Data.put('pac_so_youn__'+exchField+'__c', m.get(c)); 
                                      }
                                  }
                              }
                          api_Data.pac_so_youn__BaseCurrency__c = result.base;    
                          api_Data.pac_so_youn__Date__c = Date.valueOf(result.date_string);
                          api_Data.pac_so_youn__Log__c = log.Id;
                
                          try{ 
                          insert api_Data;  
                          } catch(DmlException e){
                          System.debug('A DML exception has occurred in api_DaTA: ' +
                          e.getMessage());
                          }  
                
                 } else{
                 // Here just checking log records with status cod '404' if it true, making HTTP Call and creating records  for every log with the same status 
                          for(pac_so_youn__Exchange_Rate__c dates : dates_Arr){
                  
                          if(dates.pac_so_youn__Log__r.pac_so_youn__Status_Code__c == '404'){
                          String s = String.valueOf(dates.pac_so_youn__Date__c);
                          HttpResponse up_Response = makeAPIRestrequest(url_adress, s);

                          if(up_Response.getStatusCode() == 200) {
                          JSON2Apex up_Result = JSON2Apex.parse(up_Response.getBody());
                          JSON2Apex.Rates up_rates =  up_Result.rates; 
                            
                           Map<String, Object> m2 = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(up_rates));
                           Map<String, Object>  newparApiCall2 = decriaseCyrrencyRatesResponsBody(up_Result, up_rates, CurrencyLabel);
                                 
                                
                          dates.pac_so_youn__Log__r.pac_so_youn__Status_Code__c = String.valueOf(up_Response.getStatusCode());
                          dates.pac_so_youn__Log__r.pac_so_youn__Responsse_Body__c = String.valueOf(newparApiCall2);
                         
                           for(String exchField:CurrencyLabel){
                                  for(String c : m.keySet()){
                                      if(exchField==c){
                                      dates.put('pac_so_youn__'+exchField+'__c', m.get(c)); 
                                      }
                                  }
                              }      
          
                          dates.pac_so_youn__BaseCurrency__c = up_Result.base;
                          log_List.add(dates.pac_so_youn__Log__r);
                          upd_Exch_List.add(dates);   
                          }
                }else {
                    // If we dont have null Objects and Log status '404' just creating new record
                          if(dates.pac_so_youn__Date__c == Date.valueOf(result.date_string)) return;
                   
                           try{  
                           insert log;  
                           } catch(DmlException e){
                           System.debug('A DML exception has occurred in LOG: ' +
                           e.getMessage());
                           }  
                   
                             for(String exchField:CurrencyLabel){
                                  for(String c : m.keySet()){
                                      if(exchField==c){
                                      api_Data.put('pac_so_youn__'+exchField+'__c', m.get(c)); 
                                      }
                                  }
                              }  
                          api_Data.pac_so_youn__BaseCurrency__c = result.base;    
                          api_Data.pac_so_youn__Date__c = Date.valueOf(result.date_string);
                          api_Data.pac_so_youn__Log__c = log.Id;     
                          
                      }
                     }
                    }
                          
         list_API_Calls.add(api_Data); 
        }
       
                 try{ 
                 update log_List; 
                 update upd_Exch_List;
                 insert list_API_Calls;
                 } catch(DmlException e){
                  System.debug('A DML exception has occurred in api_DaTA: ' +e.getMessage());
                 }  
        
           
          if(response.getStatusCode() == 404) {
                    pac_so_youn__Log__c log = new pac_so_youn__Log__c();
                    log.pac_so_youn__Status_Code__c = String.valueOf(response.getStatusCode());
                    insert log; 
                    Date tDate = Date.today();
                    pac_so_youn__Exchange_Rate__c api_Data = new pac_so_youn__Exchange_Rate__c();    
                    api_Data.pac_so_youn__Date__c = tDate;
                    api_Data.pac_so_youn__Log__c = log.Id;
                    insert api_Data;    
                }
       
 }
    
    
    
    
    
    
    
    
    @AuraEnabled(/*cacheable=true*/)
    public static Wrapper getExchangeRatesSOQL(String base_currency, String rateDate){
                          
        List<String> CurrencyLabel = getBaseCyrrencyPicklistValues();
        Date rate_date = Date.today();  
        Boolean condision = true;
        String b_currency = 'EUR';
        
        pac_so_youn__Exchange_Rate__c instanceExhRate = new pac_so_youn__Exchange_Rate__c();
        pac_so_youn__Log__c logInstanse = new pac_so_youn__Log__c(); 
        pac_so_youn__Rate__mdt url_adress = [SELECT pac_so_youn__url__c, pac_so_youn__access_key__c  FROM pac_so_youn__Rate__mdt LIMIT 1];
        
        
         pac_so_youn__Exchange_Rate__c rates;
         List<pac_so_youn__Exchange_Rate__c> dates;
       
         
            if(rateDate != ''){
                for(pac_so_youn__Exchange_Rate__c d: [SELECT  pac_so_youn__Date__c FROM pac_so_youn__Exchange_Rate__c]){
                     if(d.pac_so_youn__Date__c ==  Date.valueOf(rateDate)){
                         rate_date = d.pac_so_youn__Date__c;
                         condision = false;
                         System.debug('record exist--------'+ rate_date);
                        } 
                }
                
                if(condision){
                    System.debug('record are not exist--------so we are need to create one');
                      HttpResponse getRetesThruAPIRequest = makeAPIRestrequest(url_adress, rateDate);

                          if(getRetesThruAPIRequest.getStatusCode() == 200) {
                          JSON2Apex parcedAPIcall = JSON2Apex.parse(getRetesThruAPIRequest.getBody());
                          JSON2Apex.Rates cyrrencyRates =  parcedAPIcall.rates;  
                              
                          Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(cyrrencyRates));                
                          Map<String, Object>  newparApiCall = decriaseCyrrencyRatesResponsBody(parcedAPIcall, cyrrencyRates, CurrencyLabel);    
                          
                           logInstanse.pac_so_youn__Status_Code__c = String.valueOf(getRetesThruAPIRequest.getStatusCode());
                           logInstanse.pac_so_youn__Responsse_Body__c = String.valueOf(newparApiCall);
                          
                               try{
                               insert logInstanse;     
                               } catch(DmlException e){
                               System.debug('A DML exception has occurred in LOG: '+e.getMessage());
                               }  
                                
                              
                                 for(String exchField:CurrencyLabel){
                                  for(String c : m.keySet()){
                                      if(exchField==c){
                                      instanceExhRate.put('pac_so_youn__'+exchField+'__c', m.get(c)); 
                                      }
                                  }
                              }
                              
                          instanceExhRate.pac_so_youn__BaseCurrency__c = parcedAPIcall.base;
                          instanceExhRate.pac_so_youn__Date__c = Date.valueOf(parcedAPIcall.date_string);
                          instanceExhRate.pac_so_youn__Log__c = logInstanse.Id;
            
                }
                    
                       try{
                insert instanceExhRate;
                rate_date = instanceExhRate.pac_so_youn__Date__c;
             } catch(DmlException e){
                           System.debug('A DML exception has occurred in LOG: '+e.getMessage());
            }  
                    
          } 
        }
            
        
        if(rateDate != ''){
        List<pac_so_youn__Exchange_Rate__c> rateList = dinamicSOQlquery(b_currency, rate_date);
                rates =(rateList != null && rateList.size()>0)?rateList.get(0):null;
                dates = [SELECT  pac_so_youn__Date__c FROM pac_so_youn__Exchange_Rate__c LIMIT 5];         
        } else{
                b_currency = base_currency;
                List<pac_so_youn__Exchange_Rate__c> rateList = dinamicSOQlquery(b_currency, rate_date);
                rates =(rateList != null && rateList.size()>0)?rateList.get(0):null;
                dates = [SELECT  pac_so_youn__Date__c FROM pac_so_youn__Exchange_Rate__c LIMIT 5];
       
            
          
        }
                Wrapper wrapper = new Wrapper(); 
                wrapper.rates = rates;
                wrapper.dates = dates;
                wrapper.labels = CurrencyLabel;
                return wrapper;
    }
    
    
    // get BaseCurrency__c picklist values
    @testvisible private static List<String> getBaseCyrrencyPicklistValues(){
          List<String> CurrencyLabel = new List<String>();
           List<Schema.PicklistEntry> picklistValues = pac_so_youn__Exchange_Rate__c.pac_so_youn__BaseCurrency__c.getDescribe().getPicklistValues();
  
          for(Schema.PicklistEntry p:picklistValues) {
          CurrencyLabel.add(p.getLabel());
          } 
        return CurrencyLabel;
    }
    
    // JSON2APEX.parce method returning too  larg APIbody that doesn`t fit pac_so_youn__Log__c.pac_so_youn__Responsse_Body__c field, so we need to make it  a little shorter!
    @testvisible private static  Map<String, Object> decriaseCyrrencyRatesResponsBody(JSON2Apex parcedAPIcall, JSON2Apex.Rates cyrrencyRates, List<String> CurrencyLabel){
                          Map<String, Object> ApiCallResult = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(parcedAPIcall));
                          Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(cyrrencyRates));    
                                      
                          Map<String, Object>  newparApiCall = new  Map<String,Object>();
                          Map<String, Object>  newRateMap = new  Map<String,Object>();

                             for(String exchField:ApiCallResult.keySet()){
                                  if(exchField != 'rates'){
                                     newparApiCall.put(exchField, ApiCallResult.get(exchField));
                                  }
                               }
                            
                             for(String exchField:CurrencyLabel){
                                  for(String c : m.keySet()){
                                      if(exchField==c){
                                          newRateMap.put(c,m.get(c));
                                     
                                      }
                                  }
                              }
                              newparApiCall.put('rates', newRateMap); 
        return newparApiCall;
    }  
    
    @testvisible private static HttpResponse makeAPIRestrequest(pac_so_youn__Rate__mdt url_adress, String s ){
         Http up_Http = new Http();
         HttpRequest newHttpRequest = new HttpRequest();
         newHttpRequest.setEndpoint(url_adress.pac_so_youn__url__c+s+'?access_key='+url_adress.pac_so_youn__access_key__c);
         newHttpRequest.setMethod('GET');
         HttpResponse newHttpRespons = up_Http.send(newHttpRequest);
         return newHttpRespons;
    }
    
    @testvisible private static List<pac_so_youn__Exchange_Rate__c> dinamicSOQlquery(String b_currency, Date rate_date){
     Map<String, Schema.SobjectField> M = Schema.SObjectType.pac_so_youn__Exchange_Rate__c.fields.getMap();
     String result = '';
    
     List<String> piclist = getBaseCyrrencyPicklistValues();
         for(String p:piclist){
          String newP = 'pac_so_youn__'+p+'__c'; 
             for(Schema.SobjectField s:M.values()){
                 if(newP==String.valueOf(s)){
                     result += s+', ';
                 }
              }
         }
        
        String cur = b_currency;
        Date  d = rate_date;
        List<pac_so_youn__Exchange_Rate__c> res = 
         Database.query('SELECT '+result+' pac_so_youn__BaseCurrency__c, pac_so_youn__Date__c, pac_so_youn__Log__c '+
                        'FROM pac_so_youn__Exchange_Rate__c WHERE pac_so_youn__BaseCurrency__c =: cur AND pac_so_youn__Date__c =: d LIMIT 1'); 
       
        return res;

}
    
}