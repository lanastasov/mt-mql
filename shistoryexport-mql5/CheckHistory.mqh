//+------------------------------------------------------------------+
//|                                                 CheckHistory.mqh |
//|                                   Copyright 2012-2014, komposter |
//|                                         http://www.komposter.me/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2012-2014, komposter"
#property link      "http://www.komposter.me/"
#property version   "2.0"
//---
#define MAX_WAITING_TIME	10000		// Максимальное время ожидания подкачки истории
//---
uint StartTickCount=0;
//+------------------------------------------------------------------+
//| Checks data by specified symbol's timeframe and                  |
//| downloads it from server, if necessary.                          |
//+------------------------------------------------------------------+
bool CheckLoadHistory(const string symbol,const ENUM_TIMEFRAMES period,const int size,bool print_info=true)
  {
//--- don't ask for load of its own data if it is an indicator
   if(MQL5InfoInteger(MQL5_PROGRAM_TYPE)==PROGRAM_INDICATOR && Period()==period && Symbol()==symbol) return(true);
//---
   if(size>TerminalInfoInteger(TERMINAL_MAXBARS))
     {
      //--- Definitely won't have such amount of data
      printf(__FUNCTION__+": requested too much data (%d)",size);
      return(false);
     }
//---
   StartTickCount=GetTickCount();
   if(CheckTerminalHistory(symbol,period,size) || CheckServerHistory(symbol,period,size))
     {
      if(print_info)
        {
         double length=(GetTickCount()-StartTickCount)/1000.0;
         if(length>0.1) Print(symbol,", ",EnumToString(period),": history synchronized within ",DoubleToString(length,1)," sec");
        }
      return(true);
     }
//---
   if(print_info) Print(symbol,", ",EnumToString(period),": ERROR synchronizing history!!!");
//--- failed
   return(false);
  }
//+------------------------------------------------------------------+
//| Checks data in terminal.                                         |
//+------------------------------------------------------------------+
bool CheckTerminalHistory(const string symbol,const ENUM_TIMEFRAMES period,const int size)
  {
//--- Enough data in timeseries?
   if(Bars(symbol,period)>=size) return(true);
//--- second attempt
   datetime times[1];
   long     bars=0;
//---
   if(SeriesInfoInteger(symbol,PERIOD_M1,SERIES_BARS_COUNT,bars))
     {
      //--- there is loaded data to build timeseries
      if(bars>size*PeriodSeconds(period)/60)
        {
         //--- force timeseries build
         CopyTime(symbol,period,size-1,1,times);
         //--- check date
         if(SeriesInfoInteger(symbol,period,SERIES_BARS_COUNT,bars))
           {
            //--- Timeseries generated using data from terminal
            if(bars>=size) return(true);
           }
        }
     }
//--- failed
   return(false);
  }
//+------------------------------------------------------------------+
//| Downloads missing data from server.                              |
//+------------------------------------------------------------------+
bool CheckServerHistory(const string symbol,const ENUM_TIMEFRAMES period,const int size)
  {
//--- load symbol history info
   datetime first_server_date=0;
   while(!SeriesInfoInteger(symbol,PERIOD_M1,SERIES_SERVER_FIRSTDATE,first_server_date) && !IsStoppedExt()) Sleep(5);
//--- Enough data on server?
   if(first_server_date>TimeCurrent()-size*PeriodSeconds(period)) return(false);
//--- load data step by step
   int      fail_cnt=0;
   datetime times[1];
   while(!IsStoppedExt())
     {
      //--- wait for timeseries build
      while(!SeriesInfoInteger(symbol,period,SERIES_SYNCHRONIZED) && !IsStoppedExt()) Sleep(5);
      //--- ask for built bars
      int bars=Bars(symbol,period);
      if(bars>size) return(true);
      //--- copying of next part forces data loading
      if(CopyTime(symbol,period,size-1,1,times)==1)
        {
         return(true);
        }
      else
        {
         //--- no more than 100 failed attempts
         if(++fail_cnt>=100) return(false);
         Sleep(10);
        }
     }
//--- failed
   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsStoppedExt()
  {
   if( IsStopped() ) return(true);
//---
   if( GetTickCount() - StartTickCount > MAX_WAITING_TIME ) return(true);
//---
   return(false);
  }
//+------------------------------------------------------------------+
