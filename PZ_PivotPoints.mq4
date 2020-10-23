
//  `````                     +yys.                              ````````````                                        
// yNNNNNNmds:                dNNm:                 `++/        `mNNNNNNNNNNN`                                        
// yNNNdyhmNNNo    .://:.     -//:` `---  -:/:.    `hNNd---      syyyyydNNNNy    .://:-    `---  .:/.   .://:.        
// yNNNs  sNNNd  +mNNNNNNmo`  mNNN: /NNNymNNNNNh. ymNNNNNNd           +mNNm/   +dNNNNNNms` :NNNohNNN: +dNNNNNNms`    
// yNNNhosmNNNo sNNNh--sNNNh  mNNN: /NNNNs:/mNNNs :sNNNd::-         .hNNNh.   oNNNh.`:mNNh :NNNNmyss`sNNNh:-sNNNd`    
// yNNNNNNNNh/  NNNN:  .NNNN- mNNN: /NNNm   sNNNy  +NNNh           /mNNm+     mNNNmmmmNNNm :NNNN.    mNNN/  `NNNN:    
// yNNNy--.`    mNNN+  -NNNN. mNNN: /NNNd   sNNNy  +NNNh         `sNNNd-      dNNNy//////: :NNNN     dNNN+  .NNNN-    
// yNNNs        :mNNmysmNNN+  mNNN: /NNNd   sNNNy  /NNNNhyd     `dNNNNmdddddd--mNNNyoosyd- :NNNN     -mNNmysmNNNo    
// sddd+         `+ydmmdho.   hddd- :dddy   oddds   +hmmmdy     .dddddddddddd. `/ydmmmdhs` -dddd      `+ydmmdho-  
//  
// ---------------------------------------------------------------------------------------------------------------
// File        | PZ_PivotPoints.mq4
// Description | Draws Pivot Points in relation to the desired timeframe.
// Copyright   | Point Zero Trading Solutions
// Website     | http://www.pointzero-trading.com        
// ---------------------------------------------------------------------------------------------------------------
#property copyright "Copyright © Pointzero-trading.com"
#property link      "http://www.pointzero-trading.com"

#property indicator_chart_window
#property indicator_buffers 6
#property indicator_color1 Red
#property indicator_color2 Red
#property indicator_color3 Red
#property indicator_color4 DeepSkyBlue
#property indicator_color5 DeepSkyBlue
#property indicator_color6 DeepSkyBlue
#property indicator_width1 1
#property indicator_width2 1
#property indicator_width3 1
#property indicator_width4 1
#property indicator_width5 1
#property indicator_width6 1
#property indicator_style1 STYLE_SOLID
#property indicator_style2 STYLE_DASH
#property indicator_style3 STYLE_DOT
#property indicator_style4 STYLE_SOLID
#property indicator_style5 STYLE_DASH
#property indicator_style6 STYLE_DOT

//---- constants
#define  ShortName         "PZ Pivot Points"
#define  OLabel            "PZPVLabel"
#define  Shift             1

//-- Buffers
double FextMapBuffer1[];
double FextMapBuffer2[];
double FextMapBuffer3[];
double FextMapBuffer4[];
double FextMapBuffer5[];
double FextMapBuffer6[];

//-- Parameters
extern string TF_Ex           = "---- Pivot Point Timeframe";
extern string FromTimeFrame   = "D1";
extern string LB_Ex           = "---- Labels";
extern bool   DisplayLabels   = true;
extern color  ResistanceLabel = Red;
extern color  SupportLabel    = DodgerBlue;
extern int    LabelFontSize   = 10;

//---- Internal
int    FTimeFrame  = 0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//|------------------------------------------------------------------|
int init()
{  
   // Draw
   SetIndexStyle(0,DRAW_LINE);   // Resistance 1
   SetIndexStyle(1,DRAW_LINE);   // Resistance 2
   SetIndexStyle(2,DRAW_LINE);   // Resistance 3
   SetIndexStyle(3,DRAW_LINE);   // Support 1
   SetIndexStyle(4,DRAW_LINE);   // Support 2
   SetIndexStyle(5,DRAW_LINE);   // Support 3
  
   // Bufers
   SetIndexBuffer(0,FextMapBuffer1);  
   SetIndexBuffer(1,FextMapBuffer2);  
   SetIndexBuffer(2,FextMapBuffer3);  
   SetIndexBuffer(3,FextMapBuffer4);  
   SetIndexBuffer(4,FextMapBuffer5);  
   SetIndexBuffer(5,FextMapBuffer6);  
  
   // Delete objects
   DeleteObjects();
  
   // Pick the right timeframe
   if(FromTimeFrame == "MN1") FTimeFrame = PERIOD_MN1; else
   if(FromTimeFrame == "W1") FTimeFrame = PERIOD_W1; else
   if(FromTimeFrame == "D1") FTimeFrame = PERIOD_D1; else
   if(FromTimeFrame == "H4") FTimeFrame = PERIOD_H4; else
   if(FromTimeFrame == "H1") FTimeFrame = PERIOD_H1; else
   if(FromTimeFrame == "M30") FTimeFrame = PERIOD_M30; else
   if(FromTimeFrame == "M15") FTimeFrame = PERIOD_M15; else
   if(FromTimeFrame == "M5") FTimeFrame = PERIOD_M5; else
   if(FromTimeFrame == "M1") FTimeFrame = PERIOD_M1; else
   FTimeFrame = PERIOD_D1;
  
   // Name and Hi!    
   IndicatorShortName(ShortName);
   Comment("Copyright © http://www.pointzero-trading.com");
   return(0);
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int DeleteObjects()
{
   int obj_total=ObjectsTotal();
   for(int i = obj_total - 1; i >= 0; i--)
   {
       string label = ObjectName(i);
       if(StringFind(label, OLabel) == -1) continue;
       ObjectDelete(label);
   }    
   return(0);
}
int deinit()
{
   Comment("Copyright © http://www.pointzero-trading.com");
   DeleteObjects();
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
   // Start, limit, etc..
   int start = 1;
   int limit;
   int counted_bars = IndicatorCounted();
  
   // nothing else to do?
   if(counted_bars < 0)
       return(-1);

   // do not check repeated bars
   limit = Bars - 1 - counted_bars;
  
   // Only for inferior timeframes!
   if(Period() >= FTimeFrame) return(0);
  
   // Iteration
   for(int pos = limit; pos >= start; pos--)
   {
      // Daily shift to use
      int dshift = iBarShift(Symbol(), FTimeFrame, Time[pos], false);
      
      // High, low, close and open
      double HIGH    = iHigh(Symbol(), FTimeFrame, dshift+1);
      double LOW     = iLow(Symbol(), FTimeFrame, dshift+1);
      double CLOSE   = iClose(Symbol(), FTimeFrame, dshift+1);
      double OPEN    = iOpen(Symbol(), FTimeFrame, dshift+1);
      
      // Pivot Point
      double pv = (HIGH + LOW + CLOSE) / 3;
      
      // Calcuations
      FextMapBuffer1[pos] = (2 * pv) - LOW;                                   // R1
      FextMapBuffer4[pos] = (2 * pv) - HIGH;                                  // S1
      FextMapBuffer2[pos] = (pv - FextMapBuffer4[pos]) + FextMapBuffer1[pos]; // R2
      FextMapBuffer5[pos] = pv - (FextMapBuffer1[pos] - FextMapBuffer4[pos]); // S2
      FextMapBuffer3[pos] = (pv - FextMapBuffer5[pos]) + FextMapBuffer2[pos]; // R3
      FextMapBuffer6[pos] = pv - (FextMapBuffer2[pos] - FextMapBuffer5[pos]); // S3
   }

   // Draw labels
   DrawLabel("R1", Shift, FextMapBuffer1[Shift], ResistanceLabel, 0);
   DrawLabel("R2", Shift, FextMapBuffer2[Shift], ResistanceLabel, 0);
   DrawLabel("R3", Shift, FextMapBuffer3[Shift], ResistanceLabel, 0);
   DrawLabel("S1", Shift, FextMapBuffer4[Shift], SupportLabel, 0);
   DrawLabel("S2", Shift, FextMapBuffer5[Shift], SupportLabel, 0);
   DrawLabel("S3", Shift, FextMapBuffer6[Shift], SupportLabel, 0);
  
   // Bye
   return(0);
}

void DrawLabel(string text, int shift, double vPrice, color vcolor, int voffset)
{
   // Time
   datetime x1 = Time[shift];
  
   // Bye if I don't need you
   if(!DisplayLabels) return(0);
  
   // Label
   string label = OLabel +"-"+ text;
  
   // If object exists, detroy it -we might be repainting-
   if(ObjectFind(label) != -1) ObjectDelete(label);
  
   ObjectCreate(label, OBJ_TEXT, 0, x1, vPrice);
   ObjectSetText(label, text, LabelFontSize, "Tahoma", vcolor);
   ObjectSet(label, OBJPROP_BACK, true);
}
