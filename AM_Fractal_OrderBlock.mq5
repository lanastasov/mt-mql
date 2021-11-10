//+------------------------------------------------------------------+
//|                                         AM_Fractal_OrderBlock.mq5|
//|                               Copyright © 2021, Aurthur Musendame|
//|                         https://github.com/aurthurm/MT5Indicators|
//+------------------------------------------------------------------+
#property copyright "Copyright © 2021, Aurthur Musendame"
#property description "OrderBlock Seeker"
#property version   "1.3"
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots 0

#define RESET 0

//+-----------------------------------+
//|  INDICATOR INPUT PARAMETERS       |
//+-----------------------------------+
input string Info0  =" == + General Settings + == ";
input int HistoryLookBack = 1000; // Look Back candle count (0 for all)
input int CandleCount = 10; // Candles around Fractal (High/Low)
//
input string Info1  =" == + OrderBlock + == ";
input bool ShowBullishOrderBlocks = true; // Show Bearish OrderBlocks
input color beOColor = clrOrangeRed;  // Bearish OrderBlock color
input bool ShowBearishOrderBlocks = true; // Show Bullish OrderBlocks
input color buOColor = clrGreenYellow;  // Bulish OrderBlock color

//+-----------------------------------+
string obj_str = "AM_OrderBlock";
int    min_bars, rates_total_new;

//+------------------------------------------------------------------+
//| initialization function                     |
//+------------------------------------------------------------------+
int OnInit()
  {
   IndicatorSetString(INDICATOR_SHORTNAME, obj_str);
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
   min_bars = CandleCount*2 + 1;
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| deinitialization function                             |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0, obj_str, -1, -1); // this must delete everything but its not working
   int obj_total = ObjectsTotal(0, -1, -1);
   for(int i=0; i < obj_total; i++)
     {
      ObjectDelete(0, obj_str + string(i) + "-BuOBH");
      ObjectDelete(0, obj_str + string(i) + "-BeOBH");
      ObjectDelete(0, obj_str + string(i) + "-BuOBL");
      ObjectDelete(0, obj_str + string(i) + "-BeOBL");
     }
   Comment("");
   ChartRedraw(0);
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

   if(HistoryLookBack == 0){
      rates_total_new = rates_total;
   } else {
      rates_total_new = HistoryLookBack;
   }
  
   if(rates_total_new < min_bars + 1) {
      Print("Not enough candles");
      return(0);
   }

   int start;
   start = CandleCount;
      
   ArraySetAsSeries(time, true);
   ArraySetAsSeries(open, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);

   datetime date_time = TimeCurrent();
     
     for(int i = start; i < rates_total_new - CandleCount*2 && !IsStopped(); i++)
     {
     
      double price_high, price_low, this_high, this_low;
      int chart_id = 0, bar_far_right_position, num_elements;
      
      // get current candle i high and low
      this_high = iHigh(NULL, 0, i);
      this_low  = iLow(NULL, 0, i);

      // Candle range Low and high ::   [bar_far_left_position, ..., i , ..., bar_far_right_position]
      num_elements = CandleCount*2 + 1; // range of bars to check
      bar_far_right_position = i - CandleCount;
      price_high = high[iHighest(Symbol(), Period(), MODE_HIGH, num_elements, bar_far_right_position)];
      price_low  = low[iLowest(Symbol(), Period(), MODE_LOW, num_elements, bar_far_right_position)];

      // high fractal
      if(this_high == price_high)
        {
         if(ShowBearishOrderBlocks)
           {
            //Bearish OrderBlock Search search range = 4
            double bulls_array[4];
            int bulls_indexes[4];
            for(int x=0; x<4; x++)
              {
               bulls_array[x]=0.0;
               bulls_indexes[x]=0.0;
              }

            int s_arr[1];
            for(int s = i + 4; s>=i; s--)
              {
               s_arr[0] = s;
               int arrSize = ArraySize(open);
               if(s >= arrSize) return(0);
               if(IsBullishCandle(open[s], close[s]))
                 {
                  ArrayInsert(bulls_indexes, s_arr, 0, 0, 1); // copy/insert the corresponding price index
                  ArrayInsert(bulls_array, high, 0, s, 1); // copy/insert the price_high
                  // plot all bearish orderblocks within the search range.
                  //plotArrow(chart_id, obj_name + (string)s + "-BuOB", time[s], high[s], OBJ_ARROW_DOWN, ANCHOR_BOTTOM, clrDarkCyan);
                 }
               //
              }
            int idx = bulls_indexes[ArrayMaximum(bulls_array)];
            // plot the highest orderblock
            ResetLastError();
            if(!plotArrow(chart_id, obj_str + (string)idx+ "-BeOBH", time[idx], high[idx], OBJ_ARROW_DOWN, ANCHOR_BOTTOM, beOColor)){
               Print(__FUNCTION__,
                     ": Failed to plot arrow ",GetLastError());
               return(false);
            }
            ResetLastError();
            if(!plotArrow(chart_id, obj_str + (string)idx+ "-BeOBL", time[idx], low[idx], OBJ_ARROW_UP, ANCHOR_TOP, beOColor)){
               Print(__FUNCTION__,
                     ": Failed to plot arrow ",GetLastError());
               return(false);
            }
           }
        }

      // low fractal
      if(this_low == price_low)
        {
         if(ShowBullishOrderBlocks)
           {
            //Bullish OrderBlock Search search range = 4
            double bears_array[4];
            int bears_indexes[4];
            for(int x=0; x<4; x++)
              {
               bears_array[x]=99999999999999.99;
               bears_indexes[x]=0.0;
              }

            int s_arr[1];
            for(int s = i + 4; s>=i; s--)
              {
               s_arr[0] = s;
               
               int arrSize2 = ArraySize(open);
               if(s >= arrSize2) return(0);
               if(IsBearishCandle(open[s], close[s]))
                 {
                  ArrayInsert(bears_indexes, s_arr, 0, 0, 1); // copy/insert the corresponding price index
                  ArrayInsert(bears_array, low, 0, s, 1); // copy/insert the price_low
                  // plot all bearish orderblocks within the search range.
                  // plotArrow(chart_id, obj_name + (string)s + "-BeOBL", time[s], low[s], OBJ_ARROW_UP, ANCHOR_TOP, clrDarkCyan);
                 }
               //
              }
            int idx = bears_indexes[ArrayMinimum(bears_array)];
            // plot the lowest orderblock
            ResetLastError();
            if(!plotArrow(chart_id, obj_str + (string)idx+ "-BuOBH", time[idx], high[idx], OBJ_ARROW_DOWN, ANCHOR_BOTTOM, buOColor)){
               Print(__FUNCTION__,
                     ": Failed to plot arrow ",GetLastError());
               return(false);
            }
            ResetLastError();
            if(!plotArrow(chart_id, obj_str + (string)idx+ "-BuOBL", time[idx], low[idx], OBJ_ARROW_UP, ANCHOR_TOP, buOColor)){
               Print(__FUNCTION__,
                     ": Failed to plot arrow ",GetLastError());
               return(false);
            }
           }
        }
     }
     
   ChartRedraw(0);
   //--- return value of prev_calculated for next call
   return(rates_total_new);
  }
//+------------------------------------------ END ITERATION FUNCTION


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsBullishCandle(double open_price, double close_price)
  {
   if(open_price == close_price) //doji
      return false;
   return close_price > open_price;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsBearishCandle(double open_price, double close_price)
  {
   if(open_price == close_price) //doji
      return false;
   return close_price < open_price;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool plotArrow(int obj_id, string obj_name, datetime obj_time, double obj_price, ENUM_OBJECT obj_arrow, ENUM_ARROW_ANCHOR obj_anchor, color obj_clr)
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
   if(!ObjectCreate(obj_id, obj_name, obj_arrow, 0, obj_time, obj_price)){
      Print(__FUNCTION__,
            ": Failed to create arrow object ",GetLastError());
      return(false);
   }
   ObjectSetInteger(obj_id, obj_name, OBJPROP_ANCHOR, obj_anchor);
   ObjectSetInteger(obj_id, obj_name, OBJPROP_COLOR, obj_clr);
   ObjectSetInteger(obj_id, obj_name, OBJPROP_WIDTH, 2);
   return(true);
//--
//if(ObjectFind(obj_id, obj_name) == -1)
// {
// }
  }
//+------------------------------------------------------------------+
