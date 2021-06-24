//+------------------------------------------------------------------+
//|                                       Average Day Range v1.0.mq4 |
//|                                         Copyright � 2006, Ogeima |
//|                                             ph_bresson@yahoo.com |
//+------------------------------------------------------------------+
//Please find some notes at the end of the script
#property copyright "Copyright � 2006, Ogeima"
#property link      "ph_bresson@yahoo.com"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Brown
#property indicator_minimum 0

double   ADR[];
int      cur_day;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   IndicatorShortName("Average Day Range " + Symbol() + " ");
   IndicatorBuffers(1);
   SetIndexBuffer(0,ADR);
   SetIndexStyle(0,DRAW_LINE,EMPTY,3,Brown);
   SetIndexEmptyValue(0,EMPTY_VALUE);
   SetIndexLabel(0,"ADR " + Symbol() + " " + Period());
/*
   cur_day = TimeDayOfWeek(Time[0]);
   ADR[0]   =  AvgDayRange(1);
*/
   cur_day = 6;
}
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
{
   return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
   int      nth_day,shift;
   int      counted_bars = IndicatorCounted();
   if(counted_bars<0) counted_bars=0;
   if(counted_bars>0) counted_bars--;
   int      limit = Bars-counted_bars - 21;

   for( shift=0 ; shift < limit; shift++ )
   {
      if(cur_day != TimeDayOfWeek(Time[shift]))                         //New Day: compute the ADR
      {
         cur_day  = TimeDayOfWeek(Time[shift]);
         nth_day  ++;
         ADR[shift] = AvgDayRange(nth_day);
      }                                                                 //if(cur_day != TimeDayOfWeek(Time[shift]))
      else  ADR[shift]  =  ADR[shift-1];                                //Not a new day
   }                                                                    //for(shift=limit ; shift >= 0 ; shift--)
   return(0);
}
//+---------------------------------------------------------------------------+
double AvgDayRange(int nth_day)
{
   double   R1,R5,R10,R20;
   int   i;  

   R1 =  (iHigh(NULL,PERIOD_D1,nth_day)-iLow(NULL,PERIOD_D1,nth_day));
   for(i=0;i<5;i++)  R5    =  R5  +  (iHigh(NULL,PERIOD_D1,nth_day+i)-iLow(NULL,PERIOD_D1,nth_day+i));
   for(i=0;i<10;i++) R10   =  R10 +  (iHigh(NULL,PERIOD_D1,nth_day+i)-iLow(NULL,PERIOD_D1,nth_day+i));
   for(i=0;i<20;i++) R20   =  R20 +  (iHigh(NULL,PERIOD_D1,nth_day+i)-iLow(NULL,PERIOD_D1,nth_day+i));

   R5          = R5/5;
   R10         = R10/10;
   R20         = R20/20;

   return((R1+R5+R10+R20)/4);
}
//+---------------------------------------------------------------------------+

/*
It computes yesterday's range (range= high - low), the previous 5, 10 and 20 days ranges. And it calculates the "Average Day Range" of these four ranges (yesterday's+ Prev 5 Day Range + Prev 10 Day Range + Prev 20 Day Range)/4.
So, if yesterday's Day Range was 80, the Previous 5 Day Range was 110, the Previous 10 Day Range was 90 and the Previous 20 Day Range was 120, then the Average Day Range would be 100.
ADR is therefore a kind of weighted Day Range.


For FXIGOR's DBO system, Divide_Factor is 2.
For more information regarding the DBO system, read the "FXiGoR-(T_S_R) very effective Trend Slope Retracement system" thread opened by iGoR at StrategyBuilderfx or Forex-tsd.
For FXIGOR's TSR method, use Divide_Factor = 1. 
For more information regarding the T_S_R method, read the "FXiGoR-(T_S_R) very effective Trend Slope Retracement system" thread opened by iGoR at StrategyBuilderfx or Forex-tsd.

Ogeima.
*/

