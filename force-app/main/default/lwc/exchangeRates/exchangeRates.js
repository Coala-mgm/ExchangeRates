import { LightningElement, track, wire } from 'lwc';
import getExchangeRatesSOQL from '@salesforce/apex/ExchangeRates.getExchangeRatesSOQL'
import parceObject from './index1'
import parceObjectArrayDates from './index2'

export default class ExchangeRates extends LightningElement {

 base_currency = 'EUR'
 date = ''
 startDate = ''// '2021-04-28'
 endDate =  ''// '2021-04-30'
 @track rates = {}
 datas = []
 dates = []
 error
 currency = []
 showDateRows = false

 
       connectedCallback(){
        this.getWeatheApi(this.base_currency, this.date, this.startDate, this.endDate) 
        
      }

        getWeatheApi(base_currency, date, startdate, enddate){
        getExchangeRatesSOQL({base_currency: base_currency, rateDate:date, startDate:startdate, endDate:enddate})
        .then(result =>{    
           
            this.rates.USD = result.rates.pac_so_youn__USD__c.toFixed(4);
            this.rates.CAD = result.rates.pac_so_youn__CAD__c.toFixed(4);
            this.rates.GBP = result.rates.pac_so_youn__GBP__c.toFixed(4);
            this.rates.EUR = result.rates.pac_so_youn__EUR__c.toFixed(4) ;   
            this.rates.BaseCurrency = result.rates.pac_so_youn__BaseCurrency__c;
            this.rates.Date = result.rates.pac_so_youn__Date__c;
            this.rates.labels = result.labels;
  
            this.currency = result.labels.map(item =>({
            label: item,
            value: item
            }))       
           if(result.dates){
             this.showDateRows = true
               this.dates = parceObjectArrayDates(result);
           } else {
            this.datas = parceObject(result);
           }
           
            this.error = undefined
        }).catch(error=>{
            this.error = error
            console.log(error);
            this.rates = undefined
        })
      }

     get options() {
        return this.currency
      }
    
      handleChangeBase(event) {
          this.base_currency = event.detail.value
          this.getWeatheApi(event.detail.value,  this.date, this.startDate, this.endDate)
        
      }
    handleInputDate(event){
      this.startDate = ''
      this.endDate = ''
      this.showDateRows = false
        this.getWeatheApi(this.base_currency, event.detail.value, this.startDate, this.endDate)
    }
    handleInputstartDate(event){
       this.startDate = event.detail.value
    }
    handleInputendDate(event){
      console.log(event.detail.placeholder);
       this.endDate = event.detail.value

    }
    handlePress(){
     
         this.getWeatheApi(this.base_currency, this.date,  this.startDate, this.endDate)
    }
}


