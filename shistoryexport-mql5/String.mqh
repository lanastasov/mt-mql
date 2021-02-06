//+------------------------------------------------------------------+
//|                                                       String.mqh |
//|                                   Copyright 2012-2014, komposter |
//|                                         http://www.komposter.me/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2012-2014, komposter"
#property link      "http://www.komposter.me/"
#property version   "2.0"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int StringSplitTrim(string str_from,ushort delimiter,string &array[])
  {
   int size=StringSplit(str_from,delimiter,array);
//---
   if(size>0 && array[size-1]=="")
     {
      size --;
      ArrayResize(array,size);
     }
//---
   return( size );
  }
//+------------------------------------------------------------------+
//| StringToArray (string)
//+------------------------------------------------------------------+
int StringToArray(string str_from,string &array[],string delimiter=",")
  {
   return( StringSplitTrim( str_from, StringGetCharacter( delimiter, 0 ), array ) );
  }
//+------------------------------------------------------------------+
//| StringToArray (int)
//+------------------------------------------------------------------+
int StringToArray(string str_from,int &array[],string delimiter=",")
  {
   string str_array[];
   int size=StringSplitTrim(str_from,StringGetCharacter(delimiter,0),str_array);
//---
   if(size>0)
     {
      ArrayResize(array,size);
      for(int s=0; s<size; s++) array[s]=(int)StringToInteger(str_array[s]);
     }
//---
   return( size );
  }
//+------------------------------------------------------------------+
//| StringToArray (double)
//+------------------------------------------------------------------+
int StringToArray(string str_from,double &array[],string delimiter=",")
  {
   string str_array[];
   int size=StringSplitTrim(str_from,StringGetCharacter(delimiter,0),str_array);
//---
   if(size>0)
     {
      ArrayResize(array,size);
      for(int s=0; s<size; s++) array[s]=StringToDouble(str_array[s]);
     }
//---
   return( size );
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_TIMEFRAMES StringToPeriod(string str_tf)
  {
   if( str_tf == "M1"   ) return( PERIOD_M1   );
   if( str_tf == "M2"   ) return( PERIOD_M2   );
   if( str_tf == "M3"   ) return( PERIOD_M3   );
   if( str_tf == "M4"   ) return( PERIOD_M4   );
   if( str_tf == "M5"   ) return( PERIOD_M5   );
   if( str_tf == "M6"   ) return( PERIOD_M6   );
   if( str_tf == "M10"   ) return( PERIOD_M10   );
   if( str_tf == "M12"   ) return( PERIOD_M12   );
   if( str_tf == "M15"   ) return( PERIOD_M15   );
   if( str_tf == "M20"   ) return( PERIOD_M20   );
   if( str_tf == "M30"   ) return( PERIOD_M30   );
//---
   if( str_tf == "H1"   ) return( PERIOD_H1   );
   if( str_tf == "H2"   ) return( PERIOD_H2   );
   if( str_tf == "H3"   ) return( PERIOD_H3   );
   if( str_tf == "H4"   ) return( PERIOD_H4   );
   if( str_tf == "H6"   ) return( PERIOD_H6   );
   if( str_tf == "H8"   ) return( PERIOD_H8   );
   if( str_tf == "H12"   ) return( PERIOD_H12   );
//---
   if( str_tf == "D1"   ) return( PERIOD_D1   );
   if( str_tf == "W1"   ) return( PERIOD_W1   );
   if( str_tf == "MN1"   ) return( PERIOD_MN1   );
//---
   return( PERIOD_CURRENT );
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#ifdef __MQL4__
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string PeriodToString(int tf=PERIOD_CURRENT)
  {
   if(tf==PERIOD_CURRENT) tf=_Period;
//---
   switch(tf)
     {
      case PERIOD_M1:   return( "M1"   );
      case PERIOD_M2:   return( "M2"   );
      case PERIOD_M3:   return( "M3"   );
      case PERIOD_M4:   return( "M4"   );
      case PERIOD_M5:   return( "M5"   );
      case PERIOD_M6:   return( "M6"   );
      case PERIOD_M10:   return( "M10"   );
      case PERIOD_M12:   return( "M12"   );
      case PERIOD_M15:   return( "M15"   );
      case PERIOD_M20:   return( "M20"   );
      case PERIOD_M30:   return( "M30"   );
      //---
      case PERIOD_H1:   return( "H1"   );
      case PERIOD_H2:   return( "H2"   );
      case PERIOD_H3:   return( "H3"   );
      case PERIOD_H4:   return( "H4"   );
      case PERIOD_H6:   return( "H6"   );
      case PERIOD_H8:   return( "H8"   );
      case PERIOD_H12:   return( "H12"   );
      //---
      case PERIOD_D1:   return( "D1"   );
      case PERIOD_W1:   return( "W1"   );
      case PERIOD_MN1:   return( "MN1"   );
     }
//---
   return( "M" + (string)tf );
  }
#endif
//---
#ifdef __MQL5__
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string PeriodToString(ENUM_TIMEFRAMES tf=PERIOD_CURRENT)
  {
   if(tf==PERIOD_CURRENT) tf=_Period;
//---
   switch(tf)
     {
      case PERIOD_M1:   return( "M1"   );
      case PERIOD_M2:   return( "M2"   );
      case PERIOD_M3:   return( "M3"   );
      case PERIOD_M4:   return( "M4"   );
      case PERIOD_M5:   return( "M5"   );
      case PERIOD_M6:   return( "M6"   );
      case PERIOD_M10:   return( "M10"   );
      case PERIOD_M12:   return( "M12"   );
      case PERIOD_M15:   return( "M15"   );
      case PERIOD_M20:   return( "M20"   );
      case PERIOD_M30:   return( "M30"   );
      //---
      case PERIOD_H1:   return( "H1"   );
      case PERIOD_H2:   return( "H2"   );
      case PERIOD_H3:   return( "H3"   );
      case PERIOD_H4:   return( "H4"   );
      case PERIOD_H6:   return( "H6"   );
      case PERIOD_H8:   return( "H8"   );
      case PERIOD_H12:   return( "H12"   );
      //---
      case PERIOD_D1:   return( "D1"   );
      case PERIOD_W1:   return( "W1"   );
      case PERIOD_MN1:   return( "MN1"   );
     }
//---
   return( "" );
  }
#endif
//+------------------------------------------------------------------+
