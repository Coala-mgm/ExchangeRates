
export default function parceObjectArrayDates(object){
    let finalarray = []
      for(let i=0;i<object.dates.length;i++){
        let finalobj = {}
        finalobj.arrs = []
        finalobj.date = object.dates[i].pac_so_youn__Date__c
          for(let r in object.dates[i]){
         
          object.labels.forEach(element => {
          let s = 'pac_so_youn__'+element+'__c'
           
          if(s === r){
            let obj = {} 
             obj.currency = element
              obj.rate = object.dates[i][r]
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
               finalobj.arrs.push(obj)
          }
   });
        }
       finalarray.push(finalobj)
      }
  return finalarray;
}




/*

 let finalarray = []
    let arr = []
  object.labels.forEach(element => {
      let s = 'pac_so_youn__'+element+'__c'
      for(let i=0;i<object.dates.length;i++){
        let finalobj = {}
        finalobj.arr = []
        finalobj.date = object.dates[i].pac_so_youn__Date__c
          for(let r in object.dates[i]){
          let obj = {}  
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
               finalobj.arr.push(obj)
          }
        }
       finalarray.push(finalobj)
      }
  });
console.log(finalarray);
  return arr;

*/ 