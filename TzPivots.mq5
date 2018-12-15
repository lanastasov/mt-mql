//+------------------------------------------------------------------+
//|                                                      TzPivot.mq5 |
//|                                    Copyright 2010, EarnForex.com |
//|                                         http://www.earnforex.com |
//+------------------------------------------------------------------+
#property copyright "????, Shimodax, 2010, EarnForex.com"
#property link      "http://www.strategybuilderfx.com, http://www.earnforex.com"
#property version   "1.00"

#property indicator_chart_window

/* Introduction:

   Calculation of pivot and similar levels based on time zones.
   If you want to modify the colors, please scroll down to line
   200 and below (where it says "Calculate Levels") and change
   the colors.  Valid color names can be obtained by placing
   the curor on a color name (e.g. somewhere in the word "Orange"
   and pressing F1).
   
   Time-Zone Inputs:

   LocalTimeZone: TimeZone for which MT4 shows your local time, 
                  e.g. 1 or 2 for Europe (GMT+1 or GMT+2 (daylight 
                  savings time).  Use zero for no adjustment.
                  
                  The MetaQuotes demo server uses GMT +2.
                  
   DestTimeZone:  TimeZone for the session from which to calculate
                  the levels (e.g. 1 or 2 for the European session
                  (without or with daylight savings time).  
                  Use zero for GMT
           
                  
   Example: If your MT server is living in the EST (Eastern Standard Time, 
            GMT-5) zone and want to calculate the levels for the London trading
            session (European time in summer GMT+1), then enter -5 for 
            LocalTimeZone, 1 for Dest TimeZone. 
            
            Please understand that the LocalTimeZone setting depends on the
            time on your MetaTrader charts (for example the demo server 
            from MetaQuotes always lives in CDT (+2) or CET (+1), no matter
            what the clock on your wall says.
           
            If in doubt, leave everything to zero.
*/

input int LocalTimeZone = 0;
input int DestTimeZone = 0;

input int LineStyle = 2;
input int LineThickness = 1;

input bool ShowComment = false;
input bool ShowHighLowOpen = false;
input bool ShowSweetSpots = false;
input bool ShowPivots = true;
input bool ShowMidPitvot = true;
input bool ShowFibos = false;
input bool ShowCamarilla = false;
input bool ShowLevelPrices = true;

input int BarForLabels = 10; // Number of bars from right, where lines labels will be shown

input color VerticalTextColor = clrCadetBlue;
input color VerticalLineColor = clrDarkBlue;

input bool DebugLogger = false;

int digits; // Decimal digits for symbol's price       

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
{
	digits = _Digits;
}

void OnDeinit(const int reason)
{
   int obj_total = ObjectsTotal(0);
   string gvname;
   
   for (int i= obj_total; i>=0; i--)
   {
      string name = ObjectName(0, i);
    
      if (StringSubstr(name, 0, 7) == "[PIVOT]") ObjectDelete(0, name);
   }

   gvname = Symbol() + "st";
   GlobalVariableDel(gvname);
   gvname = Symbol() + "p";
   GlobalVariableDel(gvname);
   gvname = Symbol() + "r1";
   GlobalVariableDel(gvname);
   gvname = Symbol() + "r2";
   GlobalVariableDel(gvname);
   gvname = Symbol() + "r3";
   GlobalVariableDel(gvname);
   gvname = Symbol() + "s1";
   GlobalVariableDel(gvname);
   gvname = Symbol() + "s2";
   GlobalVariableDel(gvname);
  	gvname = Symbol() + "s3";
  	GlobalVariableDel(gvname);
  	gvname = Symbol() + "yh";
  	GlobalVariableDel(gvname);
  	gvname = Symbol() + "to";
  	GlobalVariableDel(gvname);
  	gvname = Symbol() + "yl";
  	GlobalVariableDel(gvname);
  	gvname = Symbol() + "ds1";
  	GlobalVariableDel(gvname);
  	gvname = Symbol() + "ds2";
  	GlobalVariableDel(gvname);
  	gvname = Symbol() + "flm618";
  	GlobalVariableDel(gvname);
  	gvname = Symbol() + "flm382";
  	GlobalVariableDel(gvname);
  	gvname = Symbol() + "flp382";
  	GlobalVariableDel(gvname);
  	gvname = Symbol() + "flp5";
  	GlobalVariableDel(gvname);
  	gvname = Symbol() + "fhm382";
  	GlobalVariableDel(gvname);
  	gvname = Symbol() + "fhp382";
  	GlobalVariableDel(gvname);
  	gvname = Symbol() + "fhp618";
  	GlobalVariableDel(gvname);
  	gvname = Symbol() + "h3";
  	GlobalVariableDel(gvname);
  	gvname = Symbol() + "h4";
  	GlobalVariableDel(gvname);
  	gvname = Symbol() + "l3";
  	GlobalVariableDel(gvname);
  	gvname = Symbol() + "l4";
  	GlobalVariableDel(gvname);
  	gvname = Symbol() + "mr3";
  	GlobalVariableDel(gvname);
  	gvname = Symbol() + "mr2";
  	GlobalVariableDel(gvname);
  	gvname = Symbol() + "mr1";
  	GlobalVariableDel(gvname);
  	gvname = Symbol() + "ms1";
  	GlobalVariableDel(gvname);
  	gvname = Symbol() + "ms2";
  	GlobalVariableDel(gvname);
  	gvname = Symbol() + "ms3";
  	GlobalVariableDel(gvname);

   if (ShowComment) Comment("");
}
  
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &Time[],
                const double &Open[],
                const double &High[],
                const double &Low[],
                const double &Close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   ArraySetAsSeries(High, true);
   ArraySetAsSeries(Low, true);
   ArraySetAsSeries(Open, true);
   ArraySetAsSeries(Close, true);
   ArraySetAsSeries(Time, true);

   static datetime timelastupdate = 0;
   static ENUM_TIMEFRAMES lasttimeframe = PERIOD_M1;
   
   datetime startofday = 0,
            startofyesterday = 0;

   double today_high = 0,
          today_low = 0,
          today_open = 0,
          yesterday_high = 0,
          yesterday_open = 0,
          yesterday_low = 0,
          yesterday_close = 0;

   int idxfirstbaroftoday = 0,
       idxfirstbarofyesterday = 0,
       idxlastbarofyesterday = 0;

   
   // No need to update these buggers too often   
   if ((TimeCurrent() - timelastupdate < 60) && (Period() == lasttimeframe)) return (0);
      
   lasttimeframe = Period();
   timelastupdate = TimeCurrent();
   
   // Exit if period is greater than daily charts
   if(Period() > PERIOD_D1)
   {
      Alert("Error - Chart period is greater than 1 day.");
      return(-1);
   }

   if (DebugLogger)
   {
      Print("Local time current bar: ", TimeToString(Time[0]));
      Print("Destination time current bar: ", TimeToString(Time[0] - (LocalTimeZone - DestTimeZone) * 3600), ", Timezone difference = ", LocalTimeZone - DestTimeZone);
   }

   string gvname;
   double gvval;

   // Let's find out which hour bars make today and yesterday
   ComputeDayIndices(LocalTimeZone, DestTimeZone, idxfirstbaroftoday, idxfirstbarofyesterday, idxlastbarofyesterday, Time);

   startofday = Time[idxfirstbaroftoday];  // datetime (x-value) for labes on horizontal bars
   gvname = Symbol() + "st";
   gvval = startofday;
	GlobalVariableSet(gvname, gvval);
   startofyesterday = Time[idxfirstbarofyesterday];  // Datetime (x-value) for labes on horizontal bars
  
   // Walk forward through yestday's start and collect high/lows within the same day
   yesterday_high = -99999;  // Not high enough to remain alltime high
   yesterday_low  = +99999;  // Not low enough to remain alltime low
   
   for (int idxbar = idxfirstbarofyesterday; idxbar >= idxlastbarofyesterday; idxbar--)
   {
      if (yesterday_open == 0) yesterday_open = Open[idxbar]; // Grab first value for open

      yesterday_high = MathMax(High[idxbar], yesterday_high);
      yesterday_low = MathMin(Low[idxbar], yesterday_low);
      
      // Overwrite close in loop until we leave with the last iteration's value
      yesterday_close = Close[idxbar];
   }

   // Walk forward through today and collect high/lows within the same day
   today_open = Open[idxfirstbaroftoday];  // Should be open of today start trading hour

   today_high = -99999; // Not high enough to remain alltime high
   today_low =  +99999; // Not low enough to remain alltime low
   for (int j = idxfirstbaroftoday; j >= 0; j--)
   {
      today_high = MathMax(today_high, High[j]);
      today_low = MathMin(today_low, Low[j]);
   }
      
   // Draw the vertical bars that mark the time span
   double level = (yesterday_high + yesterday_low + yesterday_close) / 3;
   SetTimeLine("YesterdayStart", "yesterday", idxfirstbarofyesterday, VerticalTextColor, level - 4 * _Point, Time);
   SetTimeLine("YesterdayEnd", "today", idxfirstbaroftoday, VerticalTextColor, level - 4 * _Point, Time);
   
   if (DebugLogger) Print("Timezoned values: yo = ", yesterday_open, ", yc = ", yesterday_close, ", yhigh = ", yesterday_high, ", ylow = ", yesterday_low, ", to = ", today_open);


   //---- Calculate Levels
   double p, q, d, r1, r2, r3, s1, s2, s3;
   
   d = (today_high - today_low);
   q = (yesterday_high - yesterday_low);
   p = (yesterday_high + yesterday_low + yesterday_close) / 3;
   p = NormalizeDouble(p, digits);
   gvname = Symbol() + "p";
   gvval = p;
   GlobalVariableSet(gvname, gvval);
   
   r1 = (2 * p) - yesterday_low;
   r1 = NormalizeDouble(r1, digits);
   gvname = Symbol() + "r1";
   gvval = r1;
   GlobalVariableSet(gvname, gvval);
   r2 = p + (yesterday_high - yesterday_low);              //	r2 = p-s1+r1;
   r2 = NormalizeDouble(r2, digits);
   gvname = Symbol() + "r2";
   gvval = r2;
   GlobalVariableSet(gvname, gvval);
	r3 = (2 * p) + (yesterday_high - 2 * yesterday_low);
   r3 = NormalizeDouble(r3, digits);
   gvname = Symbol() + "r3";
   gvval = r3;
   GlobalVariableSet(gvname, gvval);
   s1 = (2 * p) - yesterday_high;
   s1 = NormalizeDouble(s1, digits);
   gvname = Symbol() + "s1";
   gvval = s1;
   GlobalVariableSet(gvname, gvval);
   s2 = p - (yesterday_high - yesterday_low);              //	s2 = p-r1+s1;
   s2 = NormalizeDouble(s2, digits);
   gvname = Symbol() + "s2";
   gvval = s2;
   GlobalVariableSet(gvname, gvval);
	s3 = (2 * p) - (2 * yesterday_high - yesterday_low);
   s3 = NormalizeDouble(s3, digits);
   gvname = Symbol() + "s3";
   gvval = s3;
   GlobalVariableSet(gvname, gvval);

   //---- High/Low, Open
   if (ShowHighLowOpen)
   {
      SetLevel("Y\'s High", yesterday_high,  Orange, LineStyle, LineThickness, startofyesterday, Time);
      SetLevel("T\'s Open", today_open,      Orange, LineStyle, LineThickness, startofday, Time);
      SetLevel("Y\'s Low", yesterday_low,    Orange, LineStyle, LineThickness, startofyesterday, Time);

   	gvname = Symbol() + "yh";
   	gvval = yesterday_high;
   	GlobalVariableSet(gvname, gvval);
   	gvname = Symbol() + "to";
   	gvval = today_open;
   	GlobalVariableSet(gvname, gvval);
   	gvname = Symbol() + "yl";
   	gvval = yesterday_low;
   	GlobalVariableSet(gvname, gvval);
   }

   //---- High/Low, Open
   if (ShowSweetSpots)
   {
      int ssp1, ssp2;
      double ds1, ds2;
      
      ssp1 = SymbolInfoDouble(Symbol(), SYMBOL_BID) / _Point;
      ssp1 = ssp1 - ssp1 % 50;
      ssp2 = ssp1 + 50;
      
      ds1 = ssp1 * _Point;
      ds2 = ssp2 * _Point;
      
      SetLevel(DoubleToString(ds1, digits), ds1, Gold, LineStyle, LineThickness, Time[10], Time);
      SetLevel(DoubleToString(ds2, digits), ds2, Gold, LineStyle, LineThickness, Time[10], Time);

   	gvname = Symbol() + "ds1";
   	gvval = ds1;
   	GlobalVariableSet(gvname, gvval);
   	gvname = Symbol() + "ds2";
   	gvval = ds2;
   	GlobalVariableSet(gvname, gvval);
   }

   //---- Pivot Lines
   if (ShowPivots)
   {
      SetLevel("R1", r1,   Blue, LineStyle, LineThickness, startofday, Time);
      SetLevel("R2", r2,   Blue, LineStyle, LineThickness, startofday, Time);
      SetLevel("R3", r3,   Blue, LineStyle, LineThickness, startofday, Time);
      
      SetLevel("Pivot", p, Magenta, LineStyle, LineThickness, startofday, Time);

      SetLevel("S1", s1,   Red, LineStyle, LineThickness, startofday, Time);
      SetLevel("S2", s2,   Red, LineStyle, LineThickness, startofday, Time);
      SetLevel("S3", s3,   Red, LineStyle, LineThickness, startofday, Time);
   }
   
   //---- Fibos of yesterday's range
   if (ShowFibos)
   {
      // .618, .5 and .382
      SetLevel("Low - 61.8% ", yesterday_low - q * 0.618,      Yellow, LineStyle, LineThickness, startofday, Time);
      SetLevel("Low - 38.2% ", yesterday_low - q * 0.382,      Yellow, LineStyle, LineThickness, startofday, Time);
      SetLevel("Low + 38.2% ", yesterday_low + q * 0.382,      Yellow, LineStyle, LineThickness, startofday, Time);
      SetLevel("LowHigh 50% ", yesterday_low + q * 0.5,        Yellow, LineStyle, LineThickness, startofday, Time);
      SetLevel("High - 38.2% ", yesterday_high - q * 0.382,    Yellow, LineStyle, LineThickness, startofday, Time);
      SetLevel("High + 38.2% ", yesterday_high + q * 0.382,    Yellow, LineStyle, LineThickness, startofday, Time);
      SetLevel("High + 61.8% ", yesterday_high +  q * 0.618,   Yellow, LineStyle, LineThickness, startofday, Time);

   	gvname = Symbol() + "flm618";
   	gvval = yesterday_low - q * 0.618;
   	gvval=NormalizeDouble(gvval, digits);
   	GlobalVariableSet(gvname, gvval);
   	gvname = Symbol() + "flm382";
   	gvval = yesterday_low - q * 0.382;
   	gvval = NormalizeDouble(gvval, digits);
   	GlobalVariableSet(gvname, gvval);
   	gvname = Symbol() + "flp382";
   	gvval = yesterday_low + q * 0.382;
   	gvval = NormalizeDouble(gvval, digits);
   	GlobalVariableSet(gvname, gvval);
   	gvname = Symbol() + "flp5";
   	gvval = yesterday_low + q * 0.5;
   	gvval = NormalizeDouble(gvval, digits);
   	GlobalVariableSet(gvname, gvval);
   	gvname = Symbol() + "fhm382";
   	gvval = yesterday_high - q * 0.382;
   	gvval = NormalizeDouble(gvval, digits);
   	GlobalVariableSet(gvname, gvval);
   	gvname = Symbol() + "fhp382";
   	gvval = yesterday_high + q * 0.382;
   	gvval = NormalizeDouble(gvval, digits);
   	GlobalVariableSet(gvname, gvval);
   	gvname = Symbol() + "fhp618";
   	gvval = yesterday_high + q * 0.618;
   	gvval = NormalizeDouble(gvval, digits);
   	GlobalVariableSet(gvname, gvval);
   }

   //----- Camarilla Lines
   if (ShowCamarilla)
   {
      double h4, h3, l4, l3;
	   h4 = q * 0.55 + yesterday_close;
	   h3 = q * 0.27 + yesterday_close;
	   l3 = yesterday_close - q * 0.27;	
	   l4 = yesterday_close - q * 0.55;	
	   
      SetLevel("H3", h3, Khaki, LineStyle, LineThickness, startofday, Time);
      SetLevel("H4", h4, Khaki, LineStyle, LineThickness, startofday, Time);
      SetLevel("L3", l3, Khaki, LineStyle, LineThickness, startofday, Time);
      SetLevel("L4", l4, Khaki, LineStyle, LineThickness, startofday, Time);

   	gvname = Symbol() + "h3";
   	gvval = h3;
   	gvval = NormalizeDouble(gvval, digits);
   	GlobalVariableSet(gvname, gvval);
   	gvname = Symbol() + "h4";
   	gvval = h4;
   	gvval = NormalizeDouble(gvval, digits);
   	GlobalVariableSet(gvname, gvval);
   	gvname = Symbol() + "l3";
   	gvval = l3;
   	gvval = NormalizeDouble(gvval, digits);
   	GlobalVariableSet(gvname, gvval);
   	gvname = Symbol() + "l4";
   	gvval = l4;
   	gvval = NormalizeDouble(gvval, digits);
   	GlobalVariableSet(gvname, gvval);
   }

   //------ Midpoints Pivots 
   if (ShowMidPitvot)
   {
      // Mid levels between pivots
      SetLevel("MR3", (r2 + r3) / 2,    Green, LineStyle, LineThickness, startofday, Time);
      SetLevel("MR2", (r1 + r2) / 2,    Green, LineStyle, LineThickness, startofday, Time);
      SetLevel("MR1", (p + r1) / 2,     Green, LineStyle, LineThickness, startofday, Time);
      SetLevel("MS1", (p + s1) / 2,     Green, LineStyle, LineThickness, startofday, Time);
      SetLevel("MS2", (s1 + s2) / 2,    Green, LineStyle, LineThickness, startofday, Time);
      SetLevel("MS3", (s2 + s3) / 2,    Green, LineStyle, LineThickness, startofday, Time);

   	gvname = Symbol() + "mr3";
   	gvval = (r2 + r3) / 2;
   	gvval = NormalizeDouble(gvval, digits);
   	GlobalVariableSet(gvname, gvval);
   	gvname = Symbol() + "mr2";
   	gvval = (r1 + r2) / 2;
   	gvval = NormalizeDouble(gvval, digits);
   	GlobalVariableSet(gvname, gvval);
   	gvname = Symbol() + "mr1";
   	gvval = (p + r1) / 2;
   	gvval = NormalizeDouble(gvval, digits);
   	GlobalVariableSet(gvname, gvval);
   	gvname = Symbol() + "ms1";
   	gvval = (p + s1) / 2;
   	gvval = NormalizeDouble(gvval, digits);
   	GlobalVariableSet(gvname, gvval);
   	gvname = Symbol() + "ms2";
   	gvval = (p + s2) / 2;
   	gvval = NormalizeDouble(gvval, digits);
   	GlobalVariableSet(gvname, gvval);
   	gvname = Symbol() + "ms3";
   	gvval = (p + s3) / 2;
   	gvval = NormalizeDouble(gvval, digits);
   	GlobalVariableSet(gvname, gvval);
   }


   //------ Comment for upper left corner
   if (ShowComment)
   {
      string comment = ""; 
      
      comment = comment + "-- Good luck with your trading! ---\n";
      comment = comment + "Range: Yesterday " + DoubleToString(MathRound(q / _Point), 0) + " pips, Today " + DoubleToString(MathRound(d / _Point), 0) + " pips\n";
      comment = comment + "Highs: Yesterday " + DoubleToString(yesterday_high, digits)  + ", Today " + DoubleToString(today_high, digits) + "\n";
      comment = comment + "Lows:  Yesterday " + DoubleToString(yesterday_low, digits)   + ", Today " + DoubleToString(today_low, digits)  + "\n";
      comment = comment + "Close: Yesterday " + DoubleToString(yesterday_close, digits) + "\n";
   	if (ShowPivots) comment = comment + "Pivot: " + DoubleToString(p, digits) + ", S1/2/3: " + DoubleToString(s1, digits) + "/" + DoubleToString(s2, digits) + "/" + DoubleToString(s3, digits) + "\n" ;
   	if (ShowFibos) comment = comment + "Fibos: " + DoubleToString(yesterday_low + q * 0.382, digits) + ", " + DoubleToString(yesterday_high - q * 0.382, digits) + "\n";
      
      Comment(comment); 
   }

   return(rates_total);
}

//+------------------------------------------------------------------+
//| Compute index of first/last bar of yesterday and today           |
//+------------------------------------------------------------------+
void ComputeDayIndices(int tzlocal, int tzdest, int &idxfirstbaroftoday, int &idxfirstbarofyesterday, int &idxlastbarofyesterday, const datetime &Time[])
{     
   int tzdiff     = tzlocal - tzdest,
       tzdiffsec  = tzdiff * 3600,
       dayminutes = 24 * 60,
       barsperday = dayminutes / (PeriodSeconds(Period()) / 60);
   MqlDateTime dt;
   TimeToStruct((Time[0] - tzdiffsec), dt);
   int dayofweektoday  = dt.day_of_week,  // What day is today in the dest timezone?
       dayofweektofind = -1; 

   //
   // Due to gaps in the data, and shift of time around weekends (due 
   // to time zone) it is not as easy as to just look back for a bar 
   // with 00:00 time
   //
   
   idxfirstbaroftoday = 0;
   idxfirstbarofyesterday = 0;
   idxlastbarofyesterday = 0;
       
   switch (dayofweektoday)
   {
      case 6: // Sat
      case 0: // Sun
      case 1: // Mon
            dayofweektofind = 5; // Yesterday in terms of trading was previous friday
            break;
            
      default:
            dayofweektofind = dayofweektoday - 1;
            break;
   }
   
   if (DebugLogger)
   {
      Print("Dayofweektoday = ", dayofweektoday);
      Print("Dayofweekyesterday = ", dayofweektofind);
   }
       
   // Search backwards for the last occrrence (backwards) of the day today (today's first bar)
   int i;
   for (i = 1; i <= barsperday + 1; i++)
   {
      datetime timet = Time[i] - tzdiffsec;
      TimeToStruct(timet, dt);
      if (dt.day_of_week != dayofweektoday)
      {
         idxfirstbaroftoday = i - 1;
         break;
      }
   }
   
   // Search backwards for the first occrrence (backwards) of the weekday we are looking for (yesterday's last bar)
   int j;
   for (j = 0; j <= 2 * barsperday + 1; j++)
   {
      datetime timey = Time[i + j] - tzdiffsec;
      TimeToStruct(timey, dt);
      if (dt.day_of_week == dayofweektofind) // Ignore saturdays (a Sa may happen due to TZ conversion)
      {  
         idxlastbarofyesterday = i + j;
         break;
      }
   }

   // Search backwards for the first occurrence of weekday before yesterday (to determine yesterday's first bar)
   for (j = 1; j <= barsperday; j++)
   {
      datetime timey2 = Time[idxlastbarofyesterday + j] - tzdiffsec;
      TimeToStruct(timey2, dt);
      if (dt.day_of_week != dayofweektofind) // Ignore saturdays (a Sa may happen due to TZ conversion)
      {
         idxfirstbarofyesterday = idxlastbarofyesterday + j - 1;
         break;
      }
   }

   if (DebugLogger)
   {
      Print("Dest time zone\'s current day starts: ",  TimeToString(Time[idxfirstbaroftoday]),     " (local time), idxbar = ", idxfirstbaroftoday);
      Print("Dest time zone\'s previous day starts: ", TimeToString(Time[idxfirstbarofyesterday]), " (local time), idxbar = ", idxfirstbarofyesterday);
      Print("Dest time zone\'s previous day ends: ",   TimeToString(Time[idxlastbarofyesterday]),  " (local time), idxbar = ", idxlastbarofyesterday);
   }
}


//+------------------------------------------------------------------+
//| Helper                                                           |
//+------------------------------------------------------------------+
void SetLevel(string text, double level, color col1, int linestyle, int thickness, datetime startofday, const datetime &Time[])
{
   string labelname = "[PIVOT] " + text + " Label",
          linename  = "[PIVOT] " + text + " Line",
          pricelabel; 

   // Create or move the horizontal line   
   if (ObjectFind(0, linename) != 0)
   {
      ObjectCreate(0, linename, OBJ_TREND, 0, startofday, level, Time[0], level);
      ObjectSetInteger(0, linename, OBJPROP_STYLE, linestyle);
      ObjectSetInteger(0, linename, OBJPROP_COLOR, col1);
      ObjectSetInteger(0, linename, OBJPROP_WIDTH, thickness);
   }
   else
   {
      ObjectMove(0, linename, 1, Time[0], level);
      ObjectMove(0, linename, 0, startofday, level);
   }

   // Put a label on the line   
   if (ObjectFind(0, labelname) != 0) ObjectCreate(0, labelname, OBJ_TEXT, 0, MathMin(Time[BarForLabels], startofday + 2 * PeriodSeconds(Period())), level);
   else ObjectMove(0, labelname, 0, MathMin(Time[BarForLabels], startofday + 2 * PeriodSeconds(Period())), level);
   
   pricelabel = " " + text;
   if ((ShowLevelPrices) && (StringToInteger(text) == 0)) pricelabel = pricelabel + ": " + DoubleToString(level, digits);
   
   ObjectSetString(0,  labelname, OBJPROP_TEXT, pricelabel);
   ObjectSetInteger(0, labelname, OBJPROP_FONTSIZE, 8);
   ObjectSetString(0,  labelname, OBJPROP_FONT, "Arial");
   ObjectSetInteger(0, labelname, OBJPROP_COLOR, White);
}
      

//+------------------------------------------------------------------+
//| Helper                                                           |
//+------------------------------------------------------------------+
void SetTimeLine(string objname, string text, int idx, color col1, double vleveltext, const datetime &Time[]) 
{
   string name = "[PIVOT] " + objname;
   int x = Time[idx];

   if (ObjectFind(0, name) != 0) ObjectCreate(0, name, OBJ_TREND, 0, x, 0, x, 100);
   else
   {
      ObjectMove(0, name, 0, x, 0);
      ObjectMove(0, name, 1, x, 100);
   }
   
   ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_DOT);
   ObjectSetInteger(0, name, OBJPROP_COLOR, VerticalLineColor);
   
   if (ObjectFind(0, name + " Label") != 0) ObjectCreate(0, name + " Label", OBJ_TEXT, 0, x, vleveltext);
   else ObjectMove(0, name + " Label", 0, x, vleveltext);
            
   ObjectSetString(0,  name + " Label", OBJPROP_TEXT, text);
   ObjectSetInteger(0, name + " Label", OBJPROP_FONTSIZE, 8);
   ObjectSetString(0,  name + " Label", OBJPROP_FONT, "Arial");
   ObjectSetInteger(0, name + " Label", OBJPROP_COLOR, col1);
}
