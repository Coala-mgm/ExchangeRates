import { LightningElement, track, wire } from 'lwc';
import getExchangeRatesSOQL from '@salesforce/apex/ExchangeRates.getExchangeRatesSOQL'
import parceObject from './index1'

export default class ExchangeRates extends LightningElement {

 base_currency = 'EUR'
 date = ''
 @track rates = {}
 datas = []
 error
 currency = []
 
       connectedCallback(){
        this.getWeatheApi(this.base_currency, this.date) 
        
      }

        getWeatheApi(base_currency, date){
        getExchangeRatesSOQL({base_currency: base_currency, rateDate:date})
        .then(result =>{    
            console.log(result);
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
           
           this.datas = parceObject(result);

           
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
          this.getWeatheApi(event.detail.value,  this.date)
        
      }
      handleChangeDate(event) {
        this.date = event.detail.value
        this.getWeatheApi(this.base_currency, event.detail.value)
    }
    handleInputDate(event){
        this.date = event.detail.value
        this.getWeatheApi(this.base_currency, event.detail.value)
    }
}


