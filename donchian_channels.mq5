//+------------------------------------------------------------------+
//|                      Donchian Channels - Generalized version.mq4 |
//|                         Copyright ? 2005, Luis Guilherme Damiani |
//|                                      http://www.damianifx.com.br |
//+------------------------------------------------------------------+
#property copyright "Copyright ? 2005, Luis Guilherme Damiani"
#property link      "http://www.damianifx.com.br"
//---- indicator version number
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window
//---- number of indicator buffers
#property indicator_buffers 3
//---- 3 plots are used
#property indicator_plots   3
//+-----------------------------------+
//|  parameters of indicator drawing  |
//+-----------------------------------+
//---- drawing of the indicator as a line
#property indicator_type1   DRAW_LINE
//---- use olive color for the indicator line
#property indicator_color1 OliveDrab
//---- indicator line is a solid curve
#property indicator_style1  STYLE_SOLID
//---- indicator line width is equal to 1
#property indicator_width1  1
//---- indicator label display
#property indicator_label1  "Upper Donchian"

//---- drawing of the indicator as a line
#property indicator_type2   DRAW_LINE
//---- use gray color for the indicator line
#property indicator_color2 Gray
//---- indicator line is a solid curve
#property indicator_style2  STYLE_SOLID
//---- indicator line width is equal to 1
#property indicator_width2  1
//---- indicator label display
#property indicator_label2  "Middle Donchian"

//---- drawing of the indicator as a line
#property indicator_type3   DRAW_LINE
//---- use pale violet red color for the indicator line
#property indicator_color3 PaleVioletRed
//---- indicator line is a solid curve
#property indicator_style3  STYLE_SOLID
//---- indicator line width is equal to 1
#property indicator_width3  1
//---- indicator label display
#property indicator_label3  "Lower Donchian"
//+-----------------------------------+
//|  Enumeration declaration          |
//+-----------------------------------+
enum Applied_Extrem //Type of extreme points
  {
   HIGH_LOW,
   HIGH_LOW_OPEN,
   HIGH_LOW_CLOSE,
   OPEN_HIGH_LOW,
   CLOSE_HIGH_LOW
  };
//+-----------------------------------+
//|  INPUT PARAMETERS OF THE INDICATOR|
//+-----------------------------------+
input int DonchianPeriod=20;            //Period of averaging
input Applied_Extrem Extremes=HIGH_LOW; //Type of extreme points
input int Margins=-2;
input int Shift=0;                      //Horizontal shift of the indicator in bars
//+-----------------------------------+
//---- indicator buffers
double UpperBuffer[];
double MiddleBuffer[];
double LowerBuffer[];
//+------------------------------------------------------------------+
//|  searching index of the highest bar                              |
//+------------------------------------------------------------------+
int iHighest(
             const double &array[],   // array for searching for maximum element index
             int count,               // the number of the array elements (from a current bar to the index descending),
                                      // along which the searching must be performed.
             int startPos             // the initial bar index (shift relative to a current bar),
                                      // the search for the greatest value begins from
             )
  {
//----
   int index=startPos;

//----checking correctness of the initial index
   if(startPos<0)
     {
      Print("Bad value in the function iHighest, startPos = ",startPos);
      return(0);
     }
//---- checking correctness of startPos value
   if(startPos-count<0)
      count=startPos;

   double max=array[startPos];
//---- searching for an index
   for(int i=startPos; i>startPos-count; i--)
     {
      if(array[i]>max)
        {
         index=i;
         max=array[i];
        }
     }
//---- returning of the greatest bar index
   return(index);
  }
//+------------------------------------------------------------------+
//|  searching index of the lowest bar                               |
//+------------------------------------------------------------------+
int iLowest(
            const double &array[],// array for searching for minimum element index
            int count,// the number of the array elements (from a current bar to the index descending),
            // along which the searching must be performed.
            int startPos //the initial bar index (shift relative to a current bar),
            // the search for the lowest value begins from
            )
  {
//----
   int index=startPos;

//----checking correctness of the initial index
   if(startPos<0)
     {
      Print("Bad value in the function iLowest, startPos = ",startPos);
      return(0);
     }

//---- checking correctness of startPos value
   if(startPos-count<0)
      count=startPos;

   double min=array[startPos];

//---- searching for an index
   for(int i=startPos; i>startPos-count; i--)
     {
      if(array[i]<min)
        {
         index=i;
         min=array[i];
        }
     }
//---- returning of the lowest bar index
   return(index);
  }
//+------------------------------------------------------------------+    
//| Donchian Channel indicator initialization function               |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- turning a dynamic array into an indicator buffer
   SetIndexBuffer(0,UpperBuffer,INDICATOR_DATA);
//---- shifting the indicator 1 horizontally by AroonShift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- shifting the start of drawing of the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,DonchianPeriod-1);
//--- create label to display in DataWindow
   PlotIndexSetString(0,PLOT_LABEL,"Upper Donchian");
//---- setting values of the indicator that won't be visible on the chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- turning a dynamic array into an indicator buffer
   SetIndexBuffer(1,MiddleBuffer,INDICATOR_DATA);
//---- shifting the indicator 2 horizontally
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- shifting the start of drawing of the indicator 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,DonchianPeriod-1);
//--- create label to display in DataWindow
   PlotIndexSetString(1,PLOT_LABEL,"Middle Donchian");
//---- setting values of the indicator that won't be visible on the chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- turning a dynamic array into an indicator buffer
   SetIndexBuffer(2,LowerBuffer,INDICATOR_DATA);
//---- shifting the indicator 3 horizontally
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//---- shifting the start of drawing of the indicator 3
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,DonchianPeriod-1);
//--- create label to display in DataWindow
   PlotIndexSetString(2,PLOT_LABEL,"Lower Donchian");
//---- setting values of the indicator that won't be visible on the chart
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- initialization of variable for indicator short name
   string shortname;
   StringConcatenate(shortname,"Donchian( DonchianPeriod = ",DonchianPeriod,")");
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determination of accuracy of displaying of the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- end of initialization
  }
//+------------------------------------------------------------------+  
//| Donchian Channel iteration function                              |
//+------------------------------------------------------------------+  
int OnCalculate(const int rates_total,    // amount of history in bars at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- checking the number of bars to be enough for the calculation
   if(rates_total<DonchianPeriod+1) return(0);

//---- declaration of variables with a floating point  
   double smin,smax,SsMax=0,SsMin=0;
//---- declaration of integer variables
   int first,bar;

//---- calculation of the starting number 'first' for the cycle of recalculation of bars
   if(prev_calculated==0)      // checking for the first start of the indicator calculation
     {
      first=DonchianPeriod;    // starting number for calculation of all bars
     }
   else
     {
      first=prev_calculated-1; // starting number for calculation of new bars
     }

//---- Main cycle of calculation of the channel
   for(bar=first; bar<rates_total; bar++)
     {
      switch(Extremes)
        {
         case HIGH_LOW:
            SsMax=high[iHighest(high,DonchianPeriod,bar)];
            SsMin=low[iLowest(low,DonchianPeriod,bar)];
            break;

         case HIGH_LOW_OPEN:
            SsMax=(open[iHighest(open,DonchianPeriod,bar)]+high[iHighest(high,DonchianPeriod,bar)])/2;
            SsMin=(open[iLowest(open,DonchianPeriod,bar)]+low[iLowest(low,DonchianPeriod,bar)])/2;
            break;

         case HIGH_LOW_CLOSE:
            SsMax=(close[iHighest(close,DonchianPeriod,bar)]+high[iHighest(high,DonchianPeriod,bar)])/2;
            SsMin=(close[iLowest(close,DonchianPeriod,bar)]+low[iLowest(low,DonchianPeriod,bar)])/2;
            break;

         case OPEN_HIGH_LOW:
            SsMax=open[iHighest(open,DonchianPeriod,bar)];
            SsMin=open[iLowest(open,DonchianPeriod,bar)];
            break;

         case CLOSE_HIGH_LOW:
            SsMax=close[iHighest(close,DonchianPeriod,bar)];
            SsMin=close[iLowest(close,DonchianPeriod,bar)];
            break;
        }

      smin=SsMin+(SsMax-SsMin)*Margins/100;
      smax=SsMax-(SsMax-SsMin)*Margins/100;
      UpperBuffer[bar]=smax;
      LowerBuffer[bar]=smin;
      MiddleBuffer[bar]=(smax+smin)/2.0;
     }
//----    
   return(rates_total);
  }
//+------------------------------------------------------------------+
