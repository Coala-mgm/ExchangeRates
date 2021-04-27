global class ScheduleExchangeRates implements Schedulable  {   
    global void execute(SchedulableContext ctx){
      ExchangeRates.getExchangeRate();
    }  
}