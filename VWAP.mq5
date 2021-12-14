//+------------------------------------------------------------------+
//|                                                         VWAP.mq5 |
//|                     Copyright 2015, SOL Digital Consultoria LTDA |
//|                          http://www.soldigitalconsultoria.com.br |
//+------------------------------------------------------------------+
#property copyright         "Copyright 2015, SOL Digital Consultoria LTDA"
#property link              "http://www.soldigitalconsultoria.com.br"
#property version           "1.47"

#property indicator_chart_window
#property indicator_buffers 8
#property indicator_plots   8

//--- plot VWAP
#property indicator_label1  "VWAP Daily"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_DASH
#property indicator_width1  2

#property indicator_label2  "VWAP Weekly"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrBlue
#property indicator_style2  STYLE_DASH
#property indicator_width2  2

#property indicator_label3  "VWAP Monthly"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrGreen
#property indicator_style3  STYLE_DASH
#property indicator_width3  2

#property indicator_label4  "VWAP Level 01"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrGray
#property indicator_style4  STYLE_DASH
#property indicator_width4  2

#property indicator_label5  "VWAP Level 02"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrYellow
#property indicator_style5  STYLE_DASH
#property indicator_width5  2

#property indicator_label6  "VWAP Level 03"
#property indicator_type6   DRAW_LINE
#property indicator_color6  clrGreen
#property indicator_style6  STYLE_DASH
#property indicator_width6  2

#property indicator_label7  "VWAP Level 04"
#property indicator_type7   DRAW_LINE
#property indicator_color7  clrBlack
#property indicator_style7  STYLE_DASH
#property indicator_width7  2

#property indicator_label8  "VWAP Level 05"
#property indicator_type8   DRAW_LINE
#property indicator_color8  clrBlue
#property indicator_style8  STYLE_DASH
#property indicator_width8  2
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum DATE_TYPE
  {
   DAILY,
   WEEKLY,
   MONTHLY
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum PRICE_TYPE
  {
   OPEN,
   CLOSE,
   HIGH,
   LOW,
   OPEN_CLOSE,
   HIGH_LOW,
   CLOSE_HIGH_LOW,
   OPEN_CLOSE_HIGH_LOW
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime CreateDateTime(DATE_TYPE nReturnType=DAILY,datetime dtDay=D'2000.01.01 00:00:00',int pHour=0,int pMinute=0,int pSecond=0)
  {
   datetime    dtReturnDate;
   MqlDateTime timeStruct;

   TimeToStruct(dtDay,timeStruct);
   timeStruct.hour = pHour;
   timeStruct.min  = pMinute;
   timeStruct.sec  = pSecond;
   dtReturnDate=(StructToTime(timeStruct));

   if(nReturnType==WEEKLY)
     {
      while(timeStruct.day_of_week!=0)
        {
         dtReturnDate=(dtReturnDate-86400);
         TimeToStruct(dtReturnDate,timeStruct);
        }
     }

   if(nReturnType==MONTHLY)
     {
      timeStruct.day=1;
      dtReturnDate=(StructToTime(timeStruct));
     }

   return dtReturnDate;
  }

sinput  string              Indicator_Name="Volume Weighted Average Price (VWAP)";
input   PRICE_TYPE          Price_Type              = CLOSE_HIGH_LOW;
input   bool                Enable_Daily            = true;
input   bool                Enable_Weekly           = true;
input   bool                Enable_Monthly          = true;
input   bool                Enable_Level_01         = false;
input   int                 VWAP_Level_01_Period    = 5;
input   bool                Enable_Level_02         = false;
input   int                 VWAP_Level_02_Period    = 13;
input   bool                Enable_Level_03         = false;
input   int                 VWAP_Level_03_Period    = 20;
input   bool                Enable_Level_04         = false;
input   int                 VWAP_Level_04_Period    = 30;
input   bool                Enable_Level_05         = false;
input   int                 VWAP_Level_05_Period    = 40;

bool        Show_Daily_Value    = true;
bool        Show_Weekly_Value   = true;
bool        Show_Monthly_Value  = true;

double      VWAP_Buffer_Daily[];
double      VWAP_Buffer_Weekly[];
double      VWAP_Buffer_Monthly[];
double      VWAP_Buffer_01[];
double      VWAP_Buffer_02[];
double      VWAP_Buffer_03[];
double      VWAP_Buffer_04[];
double      VWAP_Buffer_05[];

double      nPriceArr[];
double      nTotalTPV[];
double      nTotalVol[];
double      nSumDailyTPV = 0, nSumWeeklyTPV = 0, nSumMonthlyTPV = 0;
double      nSumDailyVol = 0, nSumWeeklyVol = 0, nSumMonthlyVol = 0;

int         nIdxDaily=0,nIdxWeekly=0,nIdxMonthly=0,nIdx=0;

bool        bIsFirstRun=true;

ENUM_TIMEFRAMES LastTimePeriod=PERIOD_MN1;

string      sDailyStr   = "";
string      sWeeklyStr  = "";
string      sMonthlyStr = "";
string      sLevel01Str = "";
string      sLevel02Str = "";
string      sLevel03Str = "";
string      sLevel04Str = "";
string      sLevel05Str = "";
datetime    dtLastDay=CreateDateTime(DAILY),dtLastWeek=CreateDateTime(WEEKLY),dtLastMonth=CreateDateTime(MONTHLY);
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);

   SetIndexBuffer(0,VWAP_Buffer_Daily,INDICATOR_DATA);
   SetIndexBuffer(1,VWAP_Buffer_Weekly,INDICATOR_DATA);
   SetIndexBuffer(2,VWAP_Buffer_Monthly,INDICATOR_DATA);
   SetIndexBuffer(3,VWAP_Buffer_01,INDICATOR_DATA);
   SetIndexBuffer(4,VWAP_Buffer_02,INDICATOR_DATA);
   SetIndexBuffer(5,VWAP_Buffer_03,INDICATOR_DATA);
   SetIndexBuffer(6,VWAP_Buffer_04,INDICATOR_DATA);
   SetIndexBuffer(7,VWAP_Buffer_05,INDICATOR_DATA);

   ObjectCreate(0,"VWAP_Daily",OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,"VWAP_Daily",OBJPROP_CORNER,3);
   ObjectSetInteger(0,"VWAP_Daily",OBJPROP_XDISTANCE,180);
   ObjectSetInteger(0,"VWAP_Daily",OBJPROP_YDISTANCE,40);
   ObjectSetInteger(0,"VWAP_Daily",OBJPROP_COLOR,indicator_color1);
   ObjectSetInteger(0,"VWAP_Daily",OBJPROP_FONTSIZE,7);
   ObjectSetString(0,"VWAP_Daily",OBJPROP_FONT,"Verdana");
   ObjectSetString(0,"VWAP_Daily",OBJPROP_TEXT," ");

   ObjectCreate(0,"VWAP_Weekly",OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,"VWAP_Weekly",OBJPROP_CORNER,3);
   ObjectSetInteger(0,"VWAP_Weekly",OBJPROP_XDISTANCE,180);
   ObjectSetInteger(0,"VWAP_Weekly",OBJPROP_YDISTANCE,60);
   ObjectSetInteger(0,"VWAP_Weekly",OBJPROP_COLOR,indicator_color2);
   ObjectSetInteger(0,"VWAP_Weekly",OBJPROP_FONTSIZE,7);
   ObjectSetString(0,"VWAP_Weekly",OBJPROP_FONT,"Verdana");
   ObjectSetString(0,"VWAP_Weekly",OBJPROP_TEXT," ");

   ObjectCreate(0,"VWAP_Monthly",OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,"VWAP_Monthly",OBJPROP_CORNER,3);
   ObjectSetInteger(0,"VWAP_Monthly",OBJPROP_XDISTANCE,180);
   ObjectSetInteger(0,"VWAP_Monthly",OBJPROP_YDISTANCE,80);
   ObjectSetInteger(0,"VWAP_Monthly",OBJPROP_COLOR,indicator_color3);
   ObjectSetInteger(0,"VWAP_Monthly",OBJPROP_FONTSIZE,7);
   ObjectSetString(0,"VWAP_Monthly",OBJPROP_FONT,"Verdana");
   ObjectSetString(0,"VWAP_Monthly",OBJPROP_TEXT," ");

   ObjectCreate(0,"VWAP_Level_01",OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,"VWAP_Level_01",OBJPROP_CORNER,3);
   ObjectSetInteger(0,"VWAP_Level_01",OBJPROP_XDISTANCE,180);
   ObjectSetInteger(0,"VWAP_Level_01",OBJPROP_YDISTANCE,100);
   ObjectSetInteger(0,"VWAP_Level_01",OBJPROP_COLOR,indicator_color4);
   ObjectSetInteger(0,"VWAP_Level_01",OBJPROP_FONTSIZE,7);
   ObjectSetString(0,"VWAP_Level_01",OBJPROP_FONT,"Verdana");
   ObjectSetString(0,"VWAP_Level_01",OBJPROP_TEXT," ");

   ObjectCreate(0,"VWAP_Level_02",OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,"VWAP_Level_02",OBJPROP_CORNER,3);
   ObjectSetInteger(0,"VWAP_Level_02",OBJPROP_XDISTANCE,180);
   ObjectSetInteger(0,"VWAP_Level_02",OBJPROP_YDISTANCE,120);
   ObjectSetInteger(0,"VWAP_Level_02",OBJPROP_COLOR,indicator_color5);
   ObjectSetInteger(0,"VWAP_Level_02",OBJPROP_FONTSIZE,7);
   ObjectSetString(0,"VWAP_Level_02",OBJPROP_FONT,"Verdana");
   ObjectSetString(0,"VWAP_Level_02",OBJPROP_TEXT," ");

   ObjectCreate(0,"VWAP_Level_03",OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,"VWAP_Level_03",OBJPROP_CORNER,3);
   ObjectSetInteger(0,"VWAP_Level_03",OBJPROP_XDISTANCE,180);
   ObjectSetInteger(0,"VWAP_Level_03",OBJPROP_YDISTANCE,140);
   ObjectSetInteger(0,"VWAP_Level_03",OBJPROP_COLOR,indicator_color6);
   ObjectSetInteger(0,"VWAP_Level_03",OBJPROP_FONTSIZE,7);
   ObjectSetString(0,"VWAP_Level_03",OBJPROP_FONT,"Verdana");
   ObjectSetString(0,"VWAP_Level_03",OBJPROP_TEXT," ");

   ObjectCreate(0,"VWAP_Level_04",OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,"VWAP_Level_04",OBJPROP_CORNER,3);
   ObjectSetInteger(0,"VWAP_Level_04",OBJPROP_XDISTANCE,180);
   ObjectSetInteger(0,"VWAP_Level_04",OBJPROP_YDISTANCE,160);
   ObjectSetInteger(0,"VWAP_Level_04",OBJPROP_COLOR,indicator_color7);
   ObjectSetInteger(0,"VWAP_Level_04",OBJPROP_FONTSIZE,7);
   ObjectSetString(0,"VWAP_Level_04",OBJPROP_FONT,"Verdana");
   ObjectSetString(0,"VWAP_Level_04",OBJPROP_TEXT," ");

   ObjectCreate(0,"VWAP_Level_05",OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,"VWAP_Level_05",OBJPROP_CORNER,3);
   ObjectSetInteger(0,"VWAP_Level_05",OBJPROP_XDISTANCE,180);
   ObjectSetInteger(0,"VWAP_Level_05",OBJPROP_YDISTANCE,180);
   ObjectSetInteger(0,"VWAP_Level_05",OBJPROP_COLOR,indicator_color8);
   ObjectSetInteger(0,"VWAP_Level_05",OBJPROP_FONTSIZE,7);
   ObjectSetString(0,"VWAP_Level_05",OBJPROP_FONT,"Verdana");
   ObjectSetString(0,"VWAP_Level_05",OBJPROP_TEXT," ");

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int pReason)
  {
   ObjectDelete(0,"VWAP_Daily");
   ObjectDelete(0,"VWAP_Weekly");
   ObjectDelete(0,"VWAP_Monthly");
   ObjectDelete(0,"VWAP_Level_01");
   ObjectDelete(0,"VWAP_Level_02");
   ObjectDelete(0,"VWAP_Level_03");
   ObjectDelete(0,"VWAP_Level_04");
   ObjectDelete(0,"VWAP_Level_05");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnCalculate(const int       rates_total,
                const int       prev_calculated,
                const datetime  &time[],
                const double    &open[],
                const double    &high[],
                const double    &low[],
                const double    &close[],
                const long      &tick_volume[],
                const long      &volume[],
                const int       &spread[])
  {

   if(PERIOD_CURRENT!=LastTimePeriod)
     {
      bIsFirstRun=true;
      LastTimePeriod=PERIOD_CURRENT;
     }

   if(rates_total>prev_calculated || bIsFirstRun)
     {
      ArrayResize(nPriceArr,rates_total);
      ArrayResize(nTotalTPV,rates_total);
      ArrayResize(nTotalVol,rates_total);

      if(Enable_Daily)   {nIdx = nIdxDaily;   nSumDailyTPV = 0;   nSumDailyVol = 0;}
      if(Enable_Weekly)  {nIdx = nIdxWeekly;  nSumWeeklyTPV = 0;  nSumWeeklyVol = 0;}
      if(Enable_Monthly) {nIdx = nIdxMonthly; nSumMonthlyTPV = 0; nSumMonthlyVol = 0;}

      for(; nIdx<rates_total; nIdx++)
        {
         if(CreateDateTime(DAILY,time[nIdx])!=dtLastDay)
           {
            nIdxDaily=nIdx;
            nSumDailyTPV = 0;
            nSumDailyVol = 0;
           }
         if(CreateDateTime(WEEKLY,time[nIdx])!=dtLastWeek)
           {
            nIdxWeekly=nIdx;
            nSumWeeklyTPV = 0;
            nSumWeeklyVol = 0;
           }
         if(CreateDateTime(MONTHLY,time[nIdx])!=dtLastMonth)
           {
            nIdxMonthly=nIdx;
            nSumMonthlyTPV = 0;
            nSumMonthlyVol = 0;
           }

         nPriceArr[nIdx] = 0;
         nTotalTPV[nIdx] = 0;
         nTotalVol[nIdx] = 0;

         switch(Price_Type)
           {
            case OPEN:
               nPriceArr[nIdx]=open[nIdx];
               break;
            case CLOSE:
               nPriceArr[nIdx]=close[nIdx];
               break;
            case HIGH:
               nPriceArr[nIdx]=high[nIdx];
               break;
            case LOW:
               nPriceArr[nIdx]=low[nIdx];
               break;
            case HIGH_LOW:
               nPriceArr[nIdx]=(high[nIdx]+low[nIdx])/2;
               break;
            case OPEN_CLOSE:
               nPriceArr[nIdx]=(open[nIdx]+close[nIdx])/2;
               break;
            case CLOSE_HIGH_LOW:
               nPriceArr[nIdx]=(close[nIdx]+high[nIdx]+low[nIdx])/3;
               break;
            case OPEN_CLOSE_HIGH_LOW:
               nPriceArr[nIdx]=(open[nIdx]+close[nIdx]+high[nIdx]+low[nIdx])/4;
               break;
            default:
               nPriceArr[nIdx]=(close[nIdx]+high[nIdx]+low[nIdx])/3;
               break;
           }

         if(tick_volume[nIdx])
           {
            nTotalTPV[nIdx] = (nPriceArr[nIdx] * tick_volume[nIdx]);
            nTotalVol[nIdx] = (double)tick_volume[nIdx];
              } else if(volume[nIdx]) {
            nTotalTPV[nIdx] = (nPriceArr[nIdx] * volume[nIdx]);
            nTotalVol[nIdx] = (double)volume[nIdx];
           }

         if(Enable_Daily && (nIdx>=nIdxDaily))
           {
            nSumDailyTPV += nTotalTPV[nIdx];
            nSumDailyVol += nTotalVol[nIdx];

            if(nSumDailyVol)
               VWAP_Buffer_Daily[nIdx]=(nSumDailyTPV/nSumDailyVol);

            if((sDailyStr!="VWAP Daily: "+(string)NormalizeDouble(VWAP_Buffer_Daily[nIdx],_Digits)) && Show_Daily_Value)
              {
               sDailyStr="VWAP Daily: "+(string)NormalizeDouble(VWAP_Buffer_Daily[nIdx],_Digits);
               ObjectSetString(0,"VWAP_Daily",OBJPROP_TEXT,sDailyStr);
              }
           }

         if(Enable_Weekly && (nIdx>=nIdxWeekly))
           {
            nSumWeeklyTPV += nTotalTPV[nIdx];
            nSumWeeklyVol += nTotalVol[nIdx];

            if(nSumWeeklyVol)
               VWAP_Buffer_Weekly[nIdx]=(nSumWeeklyTPV/nSumWeeklyVol);

            if((sWeeklyStr!="VWAP Weekly: "+(string)NormalizeDouble(VWAP_Buffer_Weekly[nIdx],_Digits)) && Show_Weekly_Value)
              {
               sWeeklyStr="VWAP Weekly: "+(string)NormalizeDouble(VWAP_Buffer_Weekly[nIdx],_Digits);
               ObjectSetString(0,"VWAP_Weekly",OBJPROP_TEXT,sWeeklyStr);
              }
           }

         if(Enable_Monthly && (nIdx>=nIdxMonthly))
           {
            nSumMonthlyTPV += nTotalTPV[nIdx];
            nSumMonthlyVol += nTotalVol[nIdx];

            if(nSumMonthlyVol)
               VWAP_Buffer_Monthly[nIdx]=(nSumMonthlyTPV/nSumMonthlyVol);

            if((sMonthlyStr!="VWAP Monthly: "+(string)NormalizeDouble(VWAP_Buffer_Monthly[nIdx],_Digits)) && Show_Monthly_Value)
              {
               sMonthlyStr="VWAP Monthly: "+(string)NormalizeDouble(VWAP_Buffer_Monthly[nIdx],_Digits);
               ObjectSetString(0,"VWAP_Monthly",OBJPROP_TEXT,sMonthlyStr);
              }
           }

         dtLastDay=CreateDateTime(DAILY,time[nIdx]);
         dtLastWeek=CreateDateTime(WEEKLY,time[nIdx]);
         dtLastMonth=CreateDateTime(MONTHLY,time[nIdx]);
        }

      if(Enable_Level_01)
        {
         int nStartPos=(prev_calculated>VWAP_Level_01_Period) ?(prev_calculated-VWAP_Level_01_Period) : VWAP_Level_01_Period;
         for(nIdx=nStartPos; nIdx<rates_total; nIdx++)
           {
            double nSumTotalTPV     = 0;
            double nSumTotalVol     = 0;
            VWAP_Buffer_01[nIdx]    = EMPTY_VALUE;

            for(int nSubIdx=1; nSubIdx<VWAP_Level_01_Period; nSubIdx++)
              {
               nSumTotalTPV += nTotalTPV[nIdx - nSubIdx];
               nSumTotalVol += nTotalVol[nIdx - nSubIdx];
              }
            if(nSumTotalVol)
               VWAP_Buffer_01[nIdx]=(nSumTotalTPV/nSumTotalVol);
            else
               VWAP_Buffer_01[nIdx]=0;
            if(sLevel01Str!="VWAP Level 01 ("+(string)VWAP_Level_01_Period+"): "+(string)NormalizeDouble(VWAP_Buffer_01[nIdx],_Digits))
              {
               sLevel01Str = "VWAP Level 01 (" + (string)VWAP_Level_01_Period + "): " + (string)NormalizeDouble(VWAP_Buffer_01[nIdx], _Digits);
               ObjectSetString(0,"VWAP_Level_01",OBJPROP_TEXT,sLevel01Str);
              }
           }
        }

      if(Enable_Level_02)
        {
         int nStartPos=(prev_calculated>VWAP_Level_02_Period) ?(prev_calculated-VWAP_Level_02_Period) : VWAP_Level_02_Period;
         for(nIdx=nStartPos; nIdx<rates_total; nIdx++)
           {
            double nSumTotalTPV     = 0;
            double nSumTotalVol     = 0;
            VWAP_Buffer_02[nIdx]    = EMPTY_VALUE;

            for(int nSubIdx=1; nSubIdx<VWAP_Level_02_Period; nSubIdx++)
              {
               nSumTotalTPV += nTotalTPV[nIdx - nSubIdx];
               nSumTotalVol += nTotalVol[nIdx - nSubIdx];
              }
            if(nSumTotalVol)
               VWAP_Buffer_02[nIdx]=(nSumTotalTPV/nSumTotalVol);
            else
               VWAP_Buffer_02[nIdx]=0;
            if(sLevel02Str!="VWAP Level 02 ("+(string)VWAP_Level_02_Period+"): "+(string)NormalizeDouble(VWAP_Buffer_02[nIdx],_Digits))
              {
               sLevel02Str = "VWAP Level 02 (" + (string)VWAP_Level_02_Period + "): " + (string)NormalizeDouble(VWAP_Buffer_02[nIdx], _Digits);
               ObjectSetString(0,"VWAP_Level_02",OBJPROP_TEXT,sLevel02Str);
              }
           }
        }

      if(Enable_Level_03)
        {
         int nStartPos=(prev_calculated>VWAP_Level_03_Period) ?(prev_calculated-VWAP_Level_03_Period) : VWAP_Level_03_Period;
         for(nIdx=nStartPos; nIdx<rates_total; nIdx++)
           {
            double nSumTotalTPV     = 0;
            double nSumTotalVol     = 0;
            VWAP_Buffer_03[nIdx]    = EMPTY_VALUE;

            for(int nSubIdx=1; nSubIdx<VWAP_Level_03_Period; nSubIdx++)
              {
               nSumTotalTPV += nTotalTPV[nIdx - nSubIdx];
               nSumTotalVol += nTotalVol[nIdx - nSubIdx];
              }
            if(nSumTotalVol)
               VWAP_Buffer_03[nIdx]=(nSumTotalTPV/nSumTotalVol);
            else
               VWAP_Buffer_03[nIdx]=0;
            if(sLevel03Str!="VWAP Level 03 ("+(string)VWAP_Level_03_Period+"): "+(string)NormalizeDouble(VWAP_Buffer_03[nIdx],_Digits))
              {
               sLevel03Str = "VWAP Level 03 (" + (string)VWAP_Level_03_Period + "): " + (string)NormalizeDouble(VWAP_Buffer_03[nIdx], _Digits);
               ObjectSetString(0,"VWAP_Level_03",OBJPROP_TEXT,sLevel03Str);
              }
           }
        }

      if(Enable_Level_04)
        {
         int nStartPos=(prev_calculated>VWAP_Level_04_Period) ?(prev_calculated-VWAP_Level_04_Period) : VWAP_Level_04_Period;
         for(nIdx=nStartPos; nIdx<rates_total; nIdx++)
           {
            double nSumTotalTPV     = 0;
            double nSumTotalVol     = 0;
            VWAP_Buffer_04[nIdx]    = EMPTY_VALUE;

            for(int nSubIdx=1; nSubIdx<VWAP_Level_04_Period; nSubIdx++)
              {
               nSumTotalTPV += nTotalTPV[nIdx - nSubIdx];
               nSumTotalVol += nTotalVol[nIdx - nSubIdx];
              }
            if(nSumTotalVol)
               VWAP_Buffer_04[nIdx]=(nSumTotalTPV/nSumTotalVol);
            else
               VWAP_Buffer_04[nIdx]=0;
            if(sLevel04Str!="VWAP Level 04 ("+(string)VWAP_Level_04_Period+"): "+(string)NormalizeDouble(VWAP_Buffer_04[nIdx],_Digits))
              {
               sLevel04Str = "VWAP Level 04 (" + (string)VWAP_Level_04_Period + "): " + (string)NormalizeDouble(VWAP_Buffer_04[nIdx], _Digits);
               ObjectSetString(0,"VWAP_Level_04",OBJPROP_TEXT,sLevel04Str);
              }
           }
        }

      if(Enable_Level_05)
        {
         int nStartPos=(prev_calculated>VWAP_Level_05_Period) ?(prev_calculated-VWAP_Level_05_Period) : VWAP_Level_05_Period;
         for(nIdx=nStartPos; nIdx<rates_total; nIdx++)
           {
            double nSumTotalTPV     = 0;
            double nSumTotalVol     = 0;
            VWAP_Buffer_05[nIdx]    = EMPTY_VALUE;

            for(int nSubIdx=1; nSubIdx<VWAP_Level_05_Period; nSubIdx++)
              {
               nSumTotalTPV += nTotalTPV[nIdx - nSubIdx];
               nSumTotalVol += nTotalVol[nIdx - nSubIdx];
              }
            if(nSumTotalVol)
               VWAP_Buffer_05[nIdx]=(nSumTotalTPV/nSumTotalVol);
            else
               VWAP_Buffer_05[nIdx]=0;
            if(sLevel05Str!="VWAP Level 05 ("+(string)VWAP_Level_05_Period+"): "+(string)NormalizeDouble(VWAP_Buffer_05[nIdx],_Digits))
              {
               sLevel05Str = "VWAP Level 05 (" + (string)VWAP_Level_05_Period + "): " + (string)NormalizeDouble(VWAP_Buffer_05[nIdx], _Digits);
               ObjectSetString(0,"VWAP_Level_05",OBJPROP_TEXT,sLevel05Str);
              }
           }
        }

      bIsFirstRun=false;
     }

   return(rates_total);
  }
//+------------------------------------------------------------------+
