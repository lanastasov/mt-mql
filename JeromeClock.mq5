//+------------------------------------------------------------------+
//|                                                  JeromeClock.mq5 |
//|                                         Copyright © 2007, Jerome |
//|                                                4xCoder@gmail.com | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, Jerome"
#property link      "4xCoder@gmail.com"
#property version   "1.00"
#property description "Time in six locations: local, server, GMT, London, Tokyo and New York!"

//---- Indicator version number
#property version   "1.00"
//---- The indicator is drawn in the main window
#property indicator_chart_window
//---- No buffers are used for calculating and drawing the indicator
#property indicator_buffers 0
//---- No graphical construction are used
#property indicator_plots   0

//---- Importing required functions
#import "kernel32.dll"
int  GetTimeZoneInformation(int &TZInfoArray[]);
#import
//+----------------------------------------------+
//|  Declaring constants                         |
//+----------------------------------------------+
#define RESET 0 // A constant for returning the indicator recalculation command to the terminal
//+----------------------------------------------+
// Description of enumeration type_font          |
// Description of class CFontName                | 
//+----------------------------------------------+ 
#include <GetFontName.mqh>
//+----------------------------------------------+
//| Input parameters of the indicator            |
//+----------------------------------------------+
input color  Color1=clrDarkViolet;//Color of the local time
input color  Color2=clrDodgerBlue;//Color of the server time
input color  Color3=clrDarkOrange;//Color of GMT
input color  Color4=clrTeal;      //Color of London time
input color  Color5=clrMagenta;   //Color of Tokyo time
input color  Color6=clrBlue;      //Color of New York time

input int    FontSize=13; //Font size
input type_font FontType=Font14; //Font type
input ENUM_BASE_CORNER  WhatCorner=CORNER_LEFT_LOWER; //Location corner
input uint Y_=20; //Vertical location
input uint X_=5; //Horizontal location
input string LableSirname="Clock 1";
//+----------------------------------------------+
int LondonTZ,TokyoTZ,NewYorkTZ;
string sFontType,Lable1,Lable2,Lable3,Lable4,Lable5,Lable6,Lable1_,Lable2_,Lable3_,Lable4_,Lable5_,Lable6_;
uint shift_1,shift_2,shift_3,shift_4,shift_5,shift_6,X1,X2;
//+------------------------------------------------------------------+   
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//----
   CFontName FONT;
   sFontType=FONT.GetFontName(FontType);
   Deinit();

   LondonTZ=0;
   TokyoTZ=9;
   NewYorkTZ=-5;
//---- 
   Lable1=LableSirname+"_"+"Local_Time";
   Lable2=LableSirname+"_"+"Brokers_Time";
   Lable3=LableSirname+"_"+"GMT";
   Lable4=LableSirname+"_"+"London_Time";
   Lable5=LableSirname+"_"+"Tokyo_Time";
   Lable6=LableSirname+"_"+"NewYork_Time";
//----   
   Lable1_=LableSirname+"_"+"Local_Time_";
   Lable2_=LableSirname+"_"+"Brokers_Time_";
   Lable3_=LableSirname+"_"+"GMT_";
   Lable4_=LableSirname+"_"+"London_Time_";
   Lable5_=LableSirname+"_"+"Tokyo_Time_";
   Lable6_=LableSirname+"_"+"NewYork_Time_";
//----
   switch(WhatCorner)
     {
      case CORNER_RIGHT_LOWER:
        {
         shift_1=int(Y_+FontSize*7.5);
         shift_2=int(Y_+FontSize*6.0);
         shift_3=int(Y_+FontSize*4.5);
         shift_4=int(Y_+FontSize*3.0);
         shift_5=int(Y_+FontSize*1.5);
         shift_6=int(Y_+0);
         X1=int(X_+FontSize*6);
         X2=int(X_);
         break;
        }

      case CORNER_LEFT_LOWER:
        {
         shift_1=int(Y_+FontSize*7.5);
         shift_2=int(Y_+FontSize*6.0);
         shift_3=int(Y_+FontSize*4.5);
         shift_4=int(Y_+FontSize*3.0);
         shift_5=int(Y_+FontSize*1.5);
         shift_6=int(Y_+0);
         X1=int(X_);
         X2=X_+FontSize*10;
         break;
        }

      case CORNER_RIGHT_UPPER:
        {
         shift_1=int(Y_+0);
         shift_2=int(Y_+FontSize*1.5);
         shift_3=int(Y_+FontSize*3.0);
         shift_4=int(Y_+FontSize*4.5);
         shift_5=int(Y_+FontSize*6.0);
         shift_6=int(Y_+FontSize*7.5);
         X1=int(X_+FontSize*6);
         X2=int(X_);
         break;
        }

      case CORNER_LEFT_UPPER:
        {
         shift_1=int(Y_+0);
         shift_2=int(Y_+FontSize*1.5);
         shift_3=int(Y_+FontSize*3.0);
         shift_4=int(Y_+FontSize*4.5);
         shift_5=int(Y_+FontSize*6.0);
         shift_6=int(Y_+FontSize*7.5);
         X1=int(X_);
         X2=int(X_+FontSize*10);
        }
     }
//---- End of initialization
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//----
   Deinit();
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+    
void Deinit()
  {
//----
   ObjectDelete(0,Lable1);
   ObjectDelete(0,Lable2);
   ObjectDelete(0,Lable3);
   ObjectDelete(0,Lable4);
   ObjectDelete(0,Lable5);
   ObjectDelete(0,Lable6);
   ObjectDelete(0,Lable1_);
   ObjectDelete(0,Lable2_);
   ObjectDelete(0,Lable3_);
   ObjectDelete(0,Lable4_);
   ObjectDelete(0,Lable5_);
   ObjectDelete(0,Lable6_);
//----
  }
//+------------------------------------------------------------------+
//|  Creating a text label                                           |
//+------------------------------------------------------------------+
void CreateTLabel
(
 long   chart_id,         // Chart ID
 string name,             // Object name
 int    nwin,             // window index
 ENUM_BASE_CORNER corner,// base corner location
 ENUM_ANCHOR_POINT point, // anchor point location
 int    X,                // the distance from the base corner along the X-axis in pixels
 int    Y,                // the distance from the base corner along the Y-axis in pixels
 string text,             // text
 color  Color,            // text color
 string Font,             // text font
 int    Size              // font size
 )
//---- 
  {
//----
   ObjectCreate(chart_id,name,OBJ_LABEL,0,0,0);
   ObjectSetInteger(chart_id,name,OBJPROP_CORNER,corner);
   ObjectSetInteger(chart_id,name,OBJPROP_ANCHOR,point);
   ObjectSetInteger(chart_id,name,OBJPROP_XDISTANCE,X);
   ObjectSetInteger(chart_id,name,OBJPROP_YDISTANCE,Y);
   ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetString(chart_id,name,OBJPROP_FONT,Font);
   ObjectSetInteger(chart_id,name,OBJPROP_FONTSIZE,Size);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,true);
//----
  }
//+------------------------------------------------------------------+
//|  Resetting the text label                                        |
//+------------------------------------------------------------------+
void SetTLabel
(
 long   chart_id,         // Chart ID
 string name,             // Object name
 int    nwin,             // window index
 ENUM_BASE_CORNER corner,// base corner location
 ENUM_ANCHOR_POINT point, // anchor point location
 int    X,                // the distance from the base corner along the X-axis in pixels
 int    Y,                // the distance from the base corner along the Y-axis in pixels
 string text,             // text
 color  Color,            // text color
 string Font,             // text font
 int    Size              // font size
 )
//---- 
  {
//----
   if(ObjectFind(chart_id,name)==-1) CreateTLabel(chart_id,name,nwin,corner,point,X,Y,text,Color,Font,Size);
   else
     {
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
      ObjectSetInteger(chart_id,name,OBJPROP_XDISTANCE,X);
      ObjectSetInteger(chart_id,name,OBJPROP_YDISTANCE,Y);
      ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
      ObjectSetString(chart_id,name,OBJPROP_FONT,Font);
      ObjectSetInteger(chart_id,name,OBJPROP_FONTSIZE,Size);
     }
//----
  }
//+------------------------------------------------------------------+ 
//| Custom indicator iteration function                              | 
//+------------------------------------------------------------------+ 
int OnCalculate(
                const int rates_total,    // amount of history in bars at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//----
   string sTime1,sTime2,sTime3,sTime4,sTime5,sTime6;
   int TZInfoArray[43];

   datetime GMT=TimeGMT();
   int dst=GetTimeZoneInformation(TZInfoArray);
   datetime london=GMT+(LondonTZ+(dst-1))*3600;
   datetime tokyo=GMT+(TokyoTZ)*3600;
   datetime newyork=GMT+(NewYorkTZ+(dst-1))*3600;

   sTime1=TimeToString(TimeLocal(),TIME_SECONDS);
   sTime2=TimeToString(TimeCurrent(),TIME_SECONDS);
   sTime3=TimeToString(GMT,TIME_SECONDS);
   sTime4=TimeToString(london,TIME_SECONDS);
   sTime5=TimeToString(tokyo,TIME_SECONDS);
   sTime6=TimeToString(newyork,TIME_SECONDS);

//----
   SetTLabel(0,Lable1,0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),X1,shift_1,"Local Time: ",Color1,sFontType,FontSize);
   SetTLabel(0,Lable1_,0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),X2,shift_1,sTime1,Color1,sFontType,FontSize);

   SetTLabel(0,Lable2,0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),X1,shift_2,"Brokers Time: ",Color2,sFontType,FontSize);
   SetTLabel(0,Lable2_,0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),X2,shift_2,sTime2,Color2,sFontType,FontSize);

   SetTLabel(0,Lable3,0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),X1,shift_3,"GMT: ",Color3,sFontType,FontSize);
   SetTLabel(0,Lable3_,0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),X2,shift_3,sTime3,Color3,sFontType,FontSize);
   
   SetTLabel(0,Lable4,0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),X1,shift_4,"London Time: ",Color4,sFontType,FontSize);
   SetTLabel(0,Lable4_,0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),X2,shift_4,sTime4,Color4,sFontType,FontSize);
   
   SetTLabel(0,Lable5,0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),X1,shift_5,"Tokyo Time: ",Color5,sFontType,FontSize);
   SetTLabel(0,Lable5_,0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),X2,shift_5,sTime5,Color5,sFontType,FontSize);
   
   SetTLabel(0,Lable6,0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),X1,shift_6,"NewYork Time: ",Color6,sFontType,FontSize);
   SetTLabel(0,Lable6_,0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),X2,shift_6,sTime6,Color6,sFontType,FontSize);
//----
   ChartRedraw(0);
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
