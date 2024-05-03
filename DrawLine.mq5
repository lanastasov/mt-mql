//+------------------------------------------------------------------+
//|                                                      DrawLine.mq5 |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Your Name"
#property link      "http://www.yourwebsite.com"
#property version   "1.00"
#property indicator_chart_window

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   datetime prevDayStart, prevDayEnd, currDayEnd;
   double highPrice;
   int err;

   // Find the start and end of the previous day based on the server time
   prevDayStart = iTime(_Symbol, PERIOD_D1, 1);
   prevDayEnd = iTime(_Symbol, PERIOD_D1, 0) - 1;
   currDayEnd = TimeCurrent();

   // Get the high of the previous day
   highPrice = iHigh(_Symbol, PERIOD_D1, 1);

   // Create a line from previous day high to the end of the current day
   string lineName = "PrevDayHighLine";
   if(!ObjectCreate(0, lineName, OBJ_TREND, 0, prevDayStart, highPrice, currDayEnd, highPrice))
     {
      err = GetLastError();
      Print("Error creating line object: ", err);
      return(INIT_FAILED);
     }

   // Set the properties of the line
   ObjectSetInteger(0, lineName, OBJPROP_COLOR, clrRed);
   ObjectSetInteger(0, lineName, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSetInteger(0, lineName, OBJPROP_WIDTH, 2);

   // Success
   return(INIT_SUCCEEDED);
  }
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
  {
    // Indicator calculation logic here
    for(int i = 0; i < rates_total; i++)
    {
        // Example: Simply copy close prices to a buffer
        // Make sure you have defined and mapped a buffer at the top
    }

    return(rates_total);
  }

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   // Remove the graphical object when the indicator is removed
   ObjectDelete(0, "PrevDayHighLine");
  }

//+------------------------------------------------------------------+
