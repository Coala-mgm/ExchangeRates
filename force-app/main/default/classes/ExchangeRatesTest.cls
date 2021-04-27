@isTest
private class ExchangeRatesTest {
    
    
        
    @isTest static void testPrivateMethods(){
  
        pac_so_youn__Rate__mdt url_adress = [SELECT pac_so_youn__url__c, pac_so_youn__access_key__c  FROM pac_so_youn__Rate__mdt LIMIT 1];
        String s = '';
         List<String> CurrencyLabel = ExchangeRates.getBaseCyrrencyPicklistValues();
         System.assertNotEquals(null,CurrencyLabel,
            'The callout returned a null response.');
        
    
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('getRateResurces');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        // Associate the callout with a mock response
        Test.setMock(HttpCalloutMock.class, mock);
        // Call method to test
        HttpResponse result = ExchangeRates.makeAPIRestrequest(url_adress, s);
       System.debug(result);
        
         System.assertNotEquals(null,result);
         System.assertEquals(200,result.getStatusCode());
        
         Map<String, Object> results = (Map<String, Object>) 
         JSON.deserializeUntyped(result.getBody());
         System.assertEquals('EUR', results.get('base'));  
        
         JSON2Apex parcedAPIcall = JSON2Apex.parse(result.getBody());
         JSON2Apex.Rates cyrrencyRates =  parcedAPIcall.rates;  
        
         Map<String, Object>  newparApiCall = ExchangeRates.decriaseCyrrencyRatesResponsBody(parcedAPIcall,cyrrencyRates, CurrencyLabel);
         System.assertNotEquals(null,newparApiCall);
        
          String base_currency = 'EUR';
         String rateDate = '2021-04-24';
  
         ExchangeRates.Wrapper wrap = ExchangeRates.getExchangeRatesSOQL(base_currency, rateDate);
        
         System.assertNotEquals(null,wrap);
        
    }
    
    
 
    
    @isTest static void testgetExchangeRatesSOQLwithEmptyDate(){
         String base_currency = 'EUR';
         String rateDateEmpty = '';
         ExchangeRates.Wrapper wrap2 = ExchangeRates.getExchangeRatesSOQL(base_currency, rateDateEmpty);
        
         System.assertNotEquals(null,wrap2);
    }
    
      
    @isTest static void testMakeAPIRestrequest(){
     /*   pac_so_youn__Exchange_Rate__c api_Data = new pac_so_youn__Exchange_Rate__c();
        pac_so_youn__Log__c log = new pac_so_youn__Log__c();
        
        log.pac_so_youn__Status_Code__c = '202';
        log.pac_so_youn__Responsse_Body__c = '{base=EUR, date_string=2021-04-25, rates={CAD=1.509059, EUR=1.0, GBP=0.871961, USD=1.209715}}';
        insert log;
        
            api_Data.pac_so_youn__CAD__c = 1.509059;
            api_Data.pac_so_youn__EUR__c = 1.0;
            api_Data.pac_so_youn__GBP__c = 0.871961;
            api_Data.pac_so_youn__USD__c = 1.209715;
            api_Data.pac_so_youn__BaseCurrency__c = 'EUR';
            api_Data.pac_so_youn__Date__c = Date.valueOf('2021-04-25');
            api_Data.pac_so_youn__Log__c = log.Id;
        insert api_Data;
        
        
        System.assertEquals(log.Id, api_Data.pac_so_youn__Log__c);*/
        
       
        ExchangeRates.getExchangeRate(); 
    }
    

}