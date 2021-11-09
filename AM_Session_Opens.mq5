//+------------------------------------------------------------------+
//|                                              AM_Session_Opens.mq5|
//|                               Copyright © 2021, Aurthur Musendame|
//|                         https://github.com/aurthurm/MT5Indicators|
//+------------------------------------------------------------------+
#property copyright "Copyright © 2021, Aurthur Musendame"
#property description "Session Open Horizontal Lines"
#property version   "1.1"
#property indicator_chart_window 
#property indicator_buffers 0
#property indicator_plots 0

#define RESET 0 

//+-----------------------------------+
//|  INDICATOR INPUT PARAMETERS       |
//+-----------------------------------+
input string Info  =" == LondonOpen , NewYorkOpen, ZeroGMTOpen Lines == ";
input int    NumberOfDays = 15;
input string LondonOpenBegin  ="07:00";
input string NewYorkBegin   ="13:00";
//input string CMEOpenBegin   ="14:15";
input string LondonCloseBegin   ="18:00";
input bool  Lo_OpenLineShow = true;
input bool  NY_OpenLineShow = false;
input bool  ZeroGMT_OpenLineShow = false;
input color Lo_OpenLineColor = clrBlue;
input color NY_OpenLineColor = clrBrown;
input color ZeroGMT_OpenLineColor = clrRed;

//+-----------------------------------+

// data starting point
int min_rates_total;

//+------------------------------------------------------------------+   
//| initialization function                     | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
    min_rates_total = NumberOfDays * PeriodSeconds(PERIOD_D1)/PeriodSeconds(PERIOD_CURRENT);
    IndicatorSetString(INDICATOR_SHORTNAME,"AM_Session_Opens");
    IndicatorSetInteger(INDICATOR_DIGITS,_Digits); 
    return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| deinitialization function                             |
//+------------------------------------------------------------------+    
void OnDeinit(const int reason)
  {
   for(int i = 0; i < NumberOfDays; i++)
   {
      ObjectDelete(0, "SessionOpen" + string(i) + "LO");
      ObjectDelete(0, "SessionOpen" + string(i) + "NO");
      ObjectDelete(0, "SessionOpen" + string(i) + "ZG");
      Comment("");
      ChartRedraw(0);
  }
 }
  
//+------------------------------------------------------------------+ 
//| iteration function                                    | 
//+------------------------------------------------------------------+ 
int OnCalculate(
                const int       rates_total,
                const int       prev_calculated,
                const datetime  &time[],
                const double    &open[],
                const double    &high[],
                const double    &low[],
                const double    &close[],
                const long      &tick_volume[],
                const long      &volume[],
                const int       &spread[]
                )
  {
  
   if(rates_total < min_rates_total) return (RESET);

   ArraySetAsSeries(time, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);

   datetime date_time = TimeCurrent();   
      
    if(Lo_OpenLineShow || NY_OpenLineShow || ZeroGMT_OpenLineShow) DrawOpenLines(
       date_time, "SessionOpen", NumberOfDays, 
       LondonOpenBegin, NewYorkBegin, LondonCloseBegin, 
       Lo_OpenLineColor, NY_OpenLineColor, ZeroGMT_OpenLineColor,
       Lo_OpenLineShow, NY_OpenLineShow, ZeroGMT_OpenLineShow, open); 
         
   ChartRedraw(0);
   return(rates_total);
  } //+------------------------------------------ END ITERATION FUNCTION

//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {

 }
 
 //+------------------------------------------------------------------+
//| DrawOpenLines: Draws LondonOpen and NewYorkOpen Horizontal Lines |
//+------------------------------------------------------------------+
bool DrawOpenLines(
  datetime date_time,
  string object_name,
  int days_look_back,
  string time1,
  string time2,
  string time3,       
  color LoColor,      
  color NyColor,      
  color ZgColor,
  bool LoShow,
  bool NyShow,
  bool ZgShow,
  const double &Open[]
  )
  {
    for(int i = 0; i < days_look_back; i++)
    {
      datetime time_1, time_2, time_3, time_4;
      double price_1, price_2, price_3;
      int bar_1_position, bar_2_position, bar_3_position;
      int chart_id = 0;
      string name = object_name + string(i);
   
      time_1   = StringToTime(TimeToString(date_time, TIME_DATE) + " " + time1);
      time_2   = StringToTime(TimeToString(date_time, TIME_DATE) + " " + time2);
      time_3   = StringToTime(TimeToString(date_time, TIME_DATE) + " " + time3);
      time_4   = StringToTime(TimeToString(date_time, TIME_DATE) + " " + "00:00:00");
   
      bar_1_position = iBarShift(NULL, 0, time_1);
      bar_2_position   = iBarShift(NULL, 0, time_2);
      bar_3_position   = iBarShift(NULL, 0, time_4);
   
      price_1  = iOpen(Symbol(), Period(), bar_1_position);
      price_2  = iOpen(Symbol(), Period(), bar_2_position);
      price_3  = iOpen(Symbol(), Period(), bar_3_position);
   
       if(LoShow == true){
         ResetLastError();
         if(!plotOpenLine(chart_id, name + "LO", time_1, time_3, price_1, price_1, LoColor)){
            Print(__FUNCTION__,
                  ": Failed to plot arrow ",GetLastError());
            return(false);
         }
        }
     
       if(NyShow == true){
         ResetLastError();
         if(!plotOpenLine(chart_id, name + "NO", time_2, time_3, price_2, price_2, NyColor)){
            Print(__FUNCTION__,
                  ": Failed to plot arrow ",GetLastError());
            return(false);
         }
        }
        
       if(ZgShow == true){
         ResetLastError();
         if(!plotOpenLine(chart_id, name + "ZG", time_4, time_3, price_3, price_3, ZgColor)){
            Print(__FUNCTION__,
                  ": Failed to plot arrow ",GetLastError());
            return(false);
         }
       }
        
      date_time = decDateTradeDay(date_time);        
      MqlDateTime times;
      TimeToStruct(date_time, times);
      
      while(times.day_of_week > 5)
      {
         date_time = decDateTradeDay(date_time);
         TimeToStruct(date_time, times);
      } 
         
    }
    return(true);
  }


//+------------------------------------------------------------------+
datetime decDateTradeDay(datetime date_time)
  {
   MqlDateTime times;
   TimeToStruct(date_time, times);
   int time_years  = times.year;
   int time_months = times.mon;
   int time_days   = times.day;
   int time_hours  = times.hour;
   int time_mins   = times.min;

   time_days--;
   if(time_days == 0)
     {
      time_months--;

      if(!time_months)
        {
         time_years--;
         time_months = 12;
        }

      if(time_months == 1 || time_months == 3 || time_months == 5 || time_months == 7 || time_months == 8 || time_months == 10 || time_months == 12) time_days = 31;
      if(time_months == 2) if(!MathMod(time_years, 4)) time_days = 29; else time_days = 28;
      if(time_months == 4 || time_months == 6 || time_months == 9 || time_months == 11) time_days = 30;
     }

   string text;
   StringConcatenate(text, time_years, ".", time_months, ".", time_days, " ", time_hours, ":" , time_mins);
   return(StringToTime(text));
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool plotOpenLine(int obj_id, string obj_name, datetime obj_time_1, datetime obj_time_2, double obj_price_1, double obj_price_2, color ZgColor)
  {
//--
   ResetLastError();
   if(!ObjectDelete(obj_id, obj_name)){
      Print(__FUNCTION__,
            ": Failed to delete old object ",GetLastError());
      return(false);
   }
//--
   ResetLastError();
   if(!ObjectCreate(obj_id, obj_name, OBJ_TREND, 0, obj_time_1, obj_price_1, obj_time_2, obj_price_2)){
      Print(__FUNCTION__,
            ": Failed to create arrow object ",GetLastError());
      return(false);
   }
   ObjectSetInteger(obj_id, obj_name, OBJPROP_COLOR, ZgColor);
   ObjectSetInteger(obj_id, obj_name, OBJPROP_STYLE, STYLE_DASH);
//--
   return(true);
//--
  }
//+------------------------------------------------------------------+
