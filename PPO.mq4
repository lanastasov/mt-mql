//+------------------------------------------------------------------+
//|                                                          PPO.mq4 |
//|                                       Copyright © 2007 Tom Balfe |
//|                                                                  |
//| Percentage Price Oscillator                                      |
//| This is a momentum indicator.                                    |
//| Signal line is EMA of PPO.                                       |
//|                                                                  |
//| Follows formula: (FastEMA-SlowEMA)/SlowEMA                       |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007 Tom Balfe"
#property link      "redcarsarasota@yahoo.com"
//----
#property indicator_separate_window
#property indicator_buffers 2
//----
#property indicator_color1 SkyBlue
#property indicator_color2 Red
#property indicator_width1 2
#property indicator_width2 1
#property indicator_style2 2
//---- user changeable stuff
extern int FastEMA=12;
extern int SlowEMA=26;
extern int SignalEMA=9;
//---- two buffers
double     PPOBuffer[];
double     SignalBuffer[];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexDrawBegin(1,SignalEMA);
   IndicatorDigits(Digits+1);
   SetIndexBuffer(0,PPOBuffer);
   SetIndexBuffer(1,SignalBuffer);
//----
   IndicatorShortName("PPO ("+FastEMA+","+SlowEMA+","+SignalEMA+")");
   SetIndexLabel(0,"PPO");
   SetIndexLabel(1,"Signal");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   int limit;
   int counted_bars=IndicatorCounted();
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
//---- (FastEMA-SlowEMA)/SlowEMA
//---- PPO counted in the 1st buffer
   for(int i=0; i<limit; i++)
      PPOBuffer[i]=(iMA(NULL,0,FastEMA,0,MODE_EMA,PRICE_CLOSE,i)-iMA(NULL,0,SlowEMA,0,MODE_EMA,PRICE_CLOSE,i))/
      iMA(NULL,0,SlowEMA,0,MODE_EMA,PRICE_CLOSE,i);
//---- signal line counted in the 2nd buffer
   for(i=0; i<limit; i++)
      SignalBuffer[i]=iMAOnArray(PPOBuffer,Bars,SignalEMA,0,MODE_EMA,i);
   return(0);
  }
//+------------------------------------------------------------------+
