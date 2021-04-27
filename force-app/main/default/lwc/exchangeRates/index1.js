
export default function parceObject(object){
     
    let arr = []
  object.labels.forEach(element => {
      let obj = {}
      let s = 'pac_so_youn__'+element+'__c'
      for(let r in object.rates){
          if(s === r){

             obj.currency = element
              obj.rate = object.rates[r]
              switch (element) {
                  case 'USD':  obj.decryption = 'US Dollar'    
                      break;
                       case 'GBP':  obj.decryption = 'British Pound'    
                      break;
                       case 'CAD':  obj.decryption = 'Canadian Dollar'    
                      break;
                       case 'EUR':  obj.decryption = 'Euro'    
                      break;
              }
               arr.push(obj)
          }
        }
  });

  return arr;
}