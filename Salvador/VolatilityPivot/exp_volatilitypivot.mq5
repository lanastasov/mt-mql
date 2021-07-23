//+------------------------------------------------------------------+
//|                                          Exp_VolatilityPivot.mq5 |
//|                               Copyright � 2014, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
#property copyright "Copyright � 2014, Nikolay Kositsin"
#property link      "farria@mail.redcom.ru"
#property version   "1.00"
//+----------------------------------------------+
//| Trading algorithms                           |
//+----------------------------------------------+
#include <TradeAlgorithms.mqh>
//+----------------------------------------------+
//| Enumeration for lot calculation options      |
//+----------------------------------------------+
/*enum MarginMode  - enumeration is declared in TradeAlgorithms.mqh
  {
   FREEMARGIN=0,     //MM considering account free funds
   BALANCE,          //MM considering account balance
   LOSSFREEMARGIN,   //MM for losses share from an account free funds
   LOSSBALANCE,      //MM for losses share from an account balance
   LOT               //Lot should be unchanged
  }; */
//+----------------------------------------------+
//| Declaration of enumeration                   |
//+----------------------------------------------+
enum Mode
  {
   FalshDirect=0,   //against the signal
   TrueDirect       //with the signal
  };
//+----------------------------------------------+
//| Declaration of enumeration                   |
//+----------------------------------------------+
enum Mode_
  {
   Mode_ATR=0,   //ATR
   Mode_Price    //price deviation
  };
//+----------------------------------------------+
//| Input parameters of the EA indicator         |
//+----------------------------------------------+
input double MM=0.1;              // Share of a deposit in a deal
input MarginMode MMMode=LOT;      // Lot value detection method
input int    StopLoss_=1000;      // Stop Loss in points
input int    TakeProfit_=2000;    // Take Profit in points
input int    Deviation_=10;       // Max. price deviation in points
input bool   BuyPosOpen=true;     // Permission to buy
input bool   SellPosOpen=true;    // Permission to sell
input bool   BuyPosClose=true;    // Permission to exit long positions
input bool   SellPosClose=true;   // Permission to exit short positions
input Mode   Direct=TrueDirect;   // Trade direction
//+----------------------------------------------+
//| VolatilityPivot indicator input parameters   |
//+----------------------------------------------+
input ENUM_TIMEFRAMES InpInd_Timeframe=PERIOD_H4; // Indicator timeframe
input uint   atr_range=100;
input uint   ima_range=10;
input double atr_factor=3;
input Mode_  IndMode=Mode_ATR;
input  uint  DeltaPrice=200;
input uint SignalBar=1;  // Bar number for getting an entry signal
//+----------------------------------------------+
int TimeShiftSec;
//--- declaration of integer variables for the indicators handles
int InpInd_Handle;
//--- declaration of integer variables for the start of data calculation
int min_rates_total;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- getting the handle of the VolatilityPivot indicator
   InpInd_Handle=iCustom(Symbol(),InpInd_Timeframe,"VolatilityPivot",atr_range,ima_range,atr_factor,IndMode,DeltaPrice,0);
   if(InpInd_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get the handle of VolatilityPivot");
      return(INIT_FAILED);
     }
//--- initialization of a variable for storing the chart period in seconds  
   TimeShiftSec=PeriodSeconds(InpInd_Timeframe);
//--- initialization of variables of the start of data calculation
   if(IndMode==Mode_ATR) min_rates_total=int(atr_range+ima_range)+1;
   else min_rates_total=3;
   min_rates_total+=int(3+SignalBar);
//--- initialization end
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   GlobalVariableDel_(Symbol());
//---
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//--- checking if the number of bars is enough for the calculation
   if(BarsCalculated(InpInd_Handle)<min_rates_total) return;
//---- uploading history for IsNewBar() and SeriesInfoInteger() functions normal operation  
   LoadHistory(TimeCurrent()-PeriodSeconds(InpInd_Timeframe)-1,Symbol(),InpInd_Timeframe);
//---- declaration of local variables
   double DnSignal[1],UpSignal[1];
   double DnTrend[1],UpTrend[1];
//---- declaration of static variables
   int LastTrend;
   static bool Recount=true;
   static bool BUY_Open=false,BUY_Close=false;
   static bool SELL_Open=false,SELL_Close=false;
   static datetime UpSignalTime,DnSignalTime;
   static CIsNewBar NB;
//--- determining signals for deals
   if(!SignalBar || NB.IsNewBar(Symbol(),InpInd_Timeframe) || Recount) // checking for a new bar
     {
      //---- zeroing out trading signals
      BUY_Open=false;
      SELL_Open=false;
      BUY_Close=false;
      SELL_Close=false;
      LastTrend=0;
      Recount=false;
      //--- search for the last trade direction
      int Bars_=Bars(Symbol(),InpInd_Timeframe);
      if(Bars_<min_rates_total) {Recount=true; return;}
      Bars_-=min_rates_total+3;
      //---
      if(Direct==FalshDirect)
        {
         //--- copy newly appeared data in the arrays
         if(CopyBuffer(InpInd_Handle,1 ,SignalBar,1,UpTrend)<=0) {Recount=true; return;}
         if(CopyBuffer(InpInd_Handle,3,SignalBar,1,UpSignal)<=0) {Recount=true; return;}
         //--- copy newly appeared data in the arrays
         if(CopyBuffer(InpInd_Handle,0,SignalBar,1,DnTrend)<=0) {Recount=true; return;}
         if(CopyBuffer(InpInd_Handle,2,SignalBar,1,DnSignal)<=0) {Recount=true; return;}
        }
      else
        {
         //--- copy newly appeared data in the arrays
         if(CopyBuffer(InpInd_Handle,0 ,SignalBar,1,UpTrend)<=0) {Recount=true; return;}
         if(CopyBuffer(InpInd_Handle,2,SignalBar,1,UpSignal)<=0) {Recount=true; return;}
         //--- copy newly appeared data in the arrays
         if(CopyBuffer(InpInd_Handle,1,SignalBar,1,DnTrend)<=0) {Recount=true; return;}
         if(CopyBuffer(InpInd_Handle,3,SignalBar,1,DnSignal)<=0) {Recount=true; return;}
        }
      //---- getting buy signals
      if(UpSignal[0] && UpSignal[0]!=EMPTY_VALUE)
        {
         if(BuyPosOpen) BUY_Open=true;
         if(SellPosClose) SELL_Close=true;
         UpSignalTime=datetime(SeriesInfoInteger(Symbol(),InpInd_Timeframe,SERIES_LASTBAR_DATE))+TimeShiftSec;
        }
      else if(UpTrend[0] && UpTrend[0]!=EMPTY_VALUE) SELL_Close=true;
      //---- Getting sell signals
      if(DnSignal[0] && DnSignal[0]!=EMPTY_VALUE)
        {
         if(SellPosOpen) SELL_Open=true;
         if(BuyPosClose) BUY_Close=true;
         DnSignalTime=datetime(SeriesInfoInteger(Symbol(),InpInd_Timeframe,SERIES_LASTBAR_DATE))+TimeShiftSec;
        }
      else if(DnTrend[0] && DnTrend[0]!=EMPTY_VALUE) BUY_Close=true;
     }
//--- trading
//---- Closing a long position
   BuyPositionClose(BUY_Close,Symbol(),Deviation_);
//---- Closing a short position   
   SellPositionClose(SELL_Close,Symbol(),Deviation_);
//--- Open a long position
   BuyPositionOpen(BUY_Open,Symbol(),UpSignalTime,MM,MMMode,Deviation_,StopLoss_,TakeProfit_);
//--- Open a short position
   SellPositionOpen(SELL_Open,Symbol(),DnSignalTime,MM,MMMode,Deviation_,StopLoss_,TakeProfit_);
//---
  }
//+------------------------------------------------------------------+
