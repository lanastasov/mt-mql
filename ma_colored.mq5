
/**
* Classic Moving Averages with colors
*
* Simple moving average
* Exponential moving average
* Smoothed moving average
* Linear weighted moving average
* Smoothed moving average
*      
* The indicator displays a colored moving average.
*
* It has three parameters:
* * Period calculation period
* * Method calculation method
* * Price applied prise used for calculation
*
* This version is faster and code is more flexible and reusable
*/


//+------------------------------------------------------------------
#property copyright   "Copyright © 2020, mplavonil"
#property description "Classic Moving Averages with colors"
#property version   "1.0"
#property indicator_chart_window

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   1

#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrLimeGreen,clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

enum enMATypes
{
   _sma,    // Simple
   _ema,    // Exponential
   _smma,   // Smoothed
   _lwma    // Linear weighted
};

input int                  MaPeriod    = 9;           // Period    
input enMATypes            MaMethod    = _sma;      // Method  
input ENUM_APPLIED_PRICE   Price       = PRICE_CLOSE;    // Price

double MaBuffer[];
double ColorBuffer[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
    SetIndexBuffer(0,MaBuffer,INDICATOR_DATA);
    SetIndexBuffer(1,ColorBuffer,INDICATOR_COLOR_INDEX);
    IndicatorSetString(INDICATOR_SHORTNAME,shortName(MaMethod));
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(
                const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &TickVolume[],
                const long &Volume[],
                const int &Spread[])
  {
      int i=(int)MathMax(prev_calculated-1,0);for (; i<rates_total && !IsStopped(); i++)
      {
         double price = getPrice(Price,open,close,high,low,i,rates_total,0);
         MaBuffer[i] = iCustomMa(MaMethod,price,MaPeriod,rates_total,i);
        
          if (i>0)
         {
            ColorBuffer[i] = ColorBuffer[i-1];
               if (MaBuffer[i]>MaBuffer[i-1]) {ColorBuffer[i]=0;}
               if (MaBuffer[i]<MaBuffer[i-1]) {ColorBuffer[i]=1; }
         } else ColorBuffer[i]=0;
      }
  
   return(rates_total);
  }
//+------------------------------------------------------------------+
string shortName(int mode)
{
      switch(mode)
     {
      case _sma   : return "Simple MA ("+(string)MaPeriod+")";
      case _ema   : return "Exponential MA ("+(string)MaPeriod+")";
      case _smma  : return "Smoothed MA ("+(string)MaPeriod+")";
      case _lwma  : return "Linear weighted  MA ("+(string)MaPeriod+")";
      default       : return "Moving Average ("+(string)MaPeriod+")";
     }
}
double iCustomMa(int mode,double price,int period,int bars,int r)
  {
   switch(mode)
     {
      case _sma   : return(iSMA(price,period,bars,r));
      case _ema   : return(iEMA(price,period,bars,r));
      case _smma  : return(iSMMA(price,period,bars,r));
      case _lwma  : return(iLWMA(price,period,bars,r));
      default       : return(price);
     }
  }
  
  
double  maArray[];
double iSMA(double price, int period, int bars, int r)
{
   if (ArraySize(maArray)!=bars) ArrayResize(maArray,bars);
  
   maArray[r] = price;

   double avg = price;
    int k=1;
   for(; k<period && (r-k)>=0; k++)
      avg += maArray[r-k];
  
   return(avg/(double)k);
}

double iEMA(double price,double period,int bars, int r)
  {
   if (ArraySize(maArray)!=bars) ArrayResize(maArray,bars);
   maArray[r]=price;
   if(r>0 && period>1)
      maArray[r]=maArray[r-1]+(2.0/(1.0+period))*(price-maArray[r-1]);
      
   return(maArray[r]);
  }
  
  double iSMMA(double price,double period,int bars, int r)
  {
   if (ArraySize(maArray)!=bars) ArrayResize(maArray,bars);

   maArray[r]=price;
   if(r>1 && period>1)
      maArray[r]=maArray[r-1]+(price-maArray[r-1])/period;
      
   return(maArray[r]);
  }
  
double iLWMA(double price,double period,int bars, int r)
  {
   if (ArraySize(maArray)!=bars) ArrayResize(maArray,bars);


   maArray[r] = price; if(period<1) return(price);
   double sumw = period;
   double sum  = period*price;

   for(int k=1; k<period && (r-k)>=0; k++)
     {
      double weight=period-k;
      sumw  += weight;
      sum   += weight*maArray[r-k];
     }
   return(sum/sumw);
  }  

//
double getPrice(ENUM_APPLIED_PRICE  tprice,const double &open[],const double &close[],const double &high[],const double &low[],int i,int _bars,int instanceNo=0)
  {
   switch(tprice)
   {
         case PRICE_CLOSE:     return(close[i]);
         case PRICE_OPEN:      return(open[i]);
         case PRICE_HIGH:      return(high[i]);
         case PRICE_LOW:       return(low[i]);
         case PRICE_MEDIAN:    return((high[i]+low[i])/2.0);
         case PRICE_TYPICAL:   return((high[i]+low[i]+close[i])/3.0);
         case PRICE_WEIGHTED:  return((high[i]+low[i]+close[i]+close[i])/4.0);
   }
   return(0);
  }
//+---------------------------------------------------------
