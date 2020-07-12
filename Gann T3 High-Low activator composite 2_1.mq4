//+------------------------------------------------------------------+
//|                                               high-low activator |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "mladen"
#property link      "www.forex-station.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1  LimeGreen
#property indicator_color2  PaleVioletRed
#property indicator_color3  Gold
#property indicator_width1  2
#property indicator_width2  2
#property indicator_width3  2
#property indicator_minimum 0
#property indicator_maximum 1

//
//
//
//
//

extern string TimeFrame       = "Current time frame";
extern string LbPeriods       = "7;10;14";
extern string LbClosePeriods  = "3;0;7";
extern string LbHots          = "0.5;0.7;2.5";
extern string LbOriginals     = "T;F;F";
extern bool   InheriteState   = false;
extern bool   alertsOn        = false;
extern bool   alertsOnCurrent = true;
extern bool   alertsMessage   = true;
extern bool   alertsSound     = false;
extern bool   alertsEmail     = false;

//
//
//
//
//

double guhu[];
double guhd[];
double guhn[];
double trend[];

//
//
//
//
//

int    timeFrame;
string indicatorFileName;
bool   returnBars;
bool   calculateValue;
double periods[];
double cperiods[];
double hots[];
bool   originals[];
int size;

//+------------------------------------------------------------------
//|                                                                  
//+------------------------------------------------------------------
//
//
//
//
//

int init()
{
   IndicatorBuffers(4);
   SetIndexBuffer(0,guhu); SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(1,guhd); SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(2,guhn); SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexBuffer(3,trend);
   
      //
      //
      //
      //
      //

      if (StringSubstr(LbPeriods,StringLen(LbPeriods)-1,1) != ";")
                       LbPeriods = StringConcatenate(LbPeriods,";");
         int s = 0;
         int i = StringFind(LbPeriods,";",s);
         int current;
            while (i > 0)
            {
               current = StrToDouble(StringSubstr(LbPeriods,s,i-s));
               if (current > 0) {
                     ArrayResize(periods,ArraySize(periods)+1);
                                 periods[ArraySize(periods)-1] = current; }
                                 s = i + 1;
                                     i = StringFind(LbPeriods,";",s);
            }
         size = MathMin(ArraySize(periods),8);
         
      //
      //
      //
      //
      //
               
      if (StringSubstr(LbClosePeriods,StringLen(LbClosePeriods)-1,1) != ";")
                       LbClosePeriods = StringConcatenate(LbClosePeriods,";");
         s = 0;
         i = StringFind(LbClosePeriods,";",s);
            while (i > 0)
            {
               current = StrToDouble(StringSubstr(LbClosePeriods,s,i-s));
                     ArrayResize(cperiods,ArraySize(cperiods)+1);
                                 cperiods[ArraySize(cperiods)-1] = current; 
                                 s = i + 1;
                                     i = StringFind(LbClosePeriods,";",s);
            }

      //
      //
      //
      //
      //
               
      if (StringSubstr(LbHots,StringLen(LbHots)-1,1) != ";")
                       LbHots = StringConcatenate(LbHots,";");
         s = 0;
         i = StringFind(LbHots,";",s);
            while (i > 0)
            {
               double currend = StrToDouble(StringSubstr(LbHots,s,i-s));
               if (currend > 0) {
                     ArrayResize(hots,ArraySize(hots)+1);
                                 hots[ArraySize(hots)-1] = currend; }
                                 s = i + 1;
                                     i = StringFind(LbHots,";",s);
            }

      //
      //
      //
      //
      //
      
      LbOriginals = StringConcatenate(LbOriginals,";");
      if (StringSubstr(LbOriginals,StringLen(LbOriginals)-1,1) != ";")
          StringToUpper(LbOriginals);
         s = 0;
         i = StringFind(LbOriginals,";",s);
            while (i > 0)
            {
               string currens = StringSubstr(LbOriginals,s,i-s);
               if (currens == "F" || currens == "T") {
                     ArrayResize(originals,ArraySize(originals)+1);
                                 originals[ArraySize(originals)-1] = (currens=="T"); }
                                 s = i + 1;
                                     i = StringFind(LbOriginals,";",s);
            }


         //
         //
         //
         //
         //
               
         indicatorFileName = WindowExpertName();
         calculateValue    = (TimeFrame=="calculateValue"); if (calculateValue) return(0);
         returnBars        = (TimeFrame=="returnBars");     if (returnBars)     return(0);
         timeFrame         = stringToTimeFrame(TimeFrame);

      
      //
      //
      //
      //
      //
      
   IndicatorShortName(timeFrameToString(timeFrame)+" Gann T3 High/low composite activator ("+LbPeriods+")");
         
   return(0);
}

//+------------------------------------------------------------------
//|                                                                  
//+------------------------------------------------------------------
//
//
//
//
//

double trends[][8];
int start()
{
   int i,r,counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
           int limit=MathMin(Bars-counted_bars,Bars-1);
           if (returnBars) { guhu[0] = limit+1; return(0); }

   //
   //
   //
   //
   //

   if (calculateValue || timeFrame == Period())
   {
      if (ArrayRange(trends,0)!=Bars) ArrayResize(trends,Bars);
      for(i=limit, r=Bars-i-1; i>=0; i--,r++)
      {
         int score = 0;
         for (int k=0; k<size; k++)
            {
               trends[r][k] = trends[r-1][k];
               int lbClose = cperiods[k]; 
                  if (lbClose==0) lbClose = periods[k];
                     double tclose = iT3(Close[i] ,lbClose   ,hots[k],originals[k],i,k*3+0);
                     double thigh  = iT3(High[i+1],periods[k],hots[k],originals[k],i,k*3+1);
                     double tlow   = iT3(Low[i+1] ,periods[k],hots[k],originals[k],i,k*3+2);
                  if(tclose>thigh) trends[r][k] =  1;
                  if(tclose<tlow)  trends[r][k] = -1;
                        score += trends[r][k];
            }               
            guhd[i] = EMPTY_VALUE;
            guhu[i] = EMPTY_VALUE;
            guhn[i] = EMPTY_VALUE;
               if (score== size)                                 { guhu[i] = 1; trend[i] =  1; }
               if (score==-size)                                 { guhd[i] = 1; trend[i] = -1; }
               if (guhd[i]==EMPTY_VALUE && guhu[i]==EMPTY_VALUE)
                  if (InheriteState)
                        { guhu[i] = guhu[i+1]; guhd[i] = guhd[i+1]; trend[i] = trend[i+1]; }
                  else  { guhn[i] = 1;                              trend[i] =  0;         }
      }
      manageAlerts();
      return(0);
   }      

   //
   //
   //
   //
   //
   
   limit = MathMax(limit,MathMin(Bars-1,iCustom(NULL,timeFrame,indicatorFileName,"returnBars",0,0)*timeFrame/Period()));
   for(i=limit; i>=0; i--)
   {
      int y = iBarShift(NULL,timeFrame,Time[i]);
         trend[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",LbPeriods,LbClosePeriods,LbHots,LbOriginals,InheriteState,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,3,y);
         guhd[i] = EMPTY_VALUE;
         guhu[i] = EMPTY_VALUE;
         guhn[i] = EMPTY_VALUE;
            if(trend[i] ==  1) guhu[i] = 1;
            if(trend[i] == -1) guhd[i] = 1;
            if(trend[i] ==  0) guhn[i] = 1;
   }
   return(0);
}


//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

double workT3[][144];
double workT3Coeffs[][6];
#define _period 0
#define _c1     1
#define _c2     2
#define _c3     3
#define _c4     4
#define _alpha  5

//
//
//
//
//

double iT3(double price, double period, double hot, bool original, int i, int instanceNo=0)
{
   if (ArrayRange(workT3,0) != Bars)                ArrayResize(workT3,Bars);
   if (ArrayRange(workT3Coeffs,0) < (instanceNo+1)) ArrayResize(workT3Coeffs,instanceNo+1);

   if (workT3Coeffs[instanceNo][_period] != period)
   {
     workT3Coeffs[instanceNo][_period] = period;
        double a = hot;
            workT3Coeffs[instanceNo][_c1] = -a*a*a;
            workT3Coeffs[instanceNo][_c2] = 3*a*a+3*a*a*a;
            workT3Coeffs[instanceNo][_c3] = -6*a*a-3*a-3*a*a*a;
            workT3Coeffs[instanceNo][_c4] = 1+3*a+a*a*a+3*a*a;
            if (original)
                 workT3Coeffs[instanceNo][_alpha] = 2.0/(1.0 + period);
            else workT3Coeffs[instanceNo][_alpha] = 2.0/(2.0 + (period-1.0)/2.0);
   }
   
   //
   //
   //
   //
   //
   
   int buffer = instanceNo*6;
   int r = Bars-i-1;
   if (r == 0)
      {
         workT3[r][0+buffer] = price;
         workT3[r][1+buffer] = price;
         workT3[r][2+buffer] = price;
         workT3[r][3+buffer] = price;
         workT3[r][4+buffer] = price;
         workT3[r][5+buffer] = price;
      }
   else
      {
         workT3[r][0+buffer] = workT3[r-1][0+buffer]+workT3Coeffs[instanceNo][_alpha]*(price              -workT3[r-1][0+buffer]);
         workT3[r][1+buffer] = workT3[r-1][1+buffer]+workT3Coeffs[instanceNo][_alpha]*(workT3[r][0+buffer]-workT3[r-1][1+buffer]);
         workT3[r][2+buffer] = workT3[r-1][2+buffer]+workT3Coeffs[instanceNo][_alpha]*(workT3[r][1+buffer]-workT3[r-1][2+buffer]);
         workT3[r][3+buffer] = workT3[r-1][3+buffer]+workT3Coeffs[instanceNo][_alpha]*(workT3[r][2+buffer]-workT3[r-1][3+buffer]);
         workT3[r][4+buffer] = workT3[r-1][4+buffer]+workT3Coeffs[instanceNo][_alpha]*(workT3[r][3+buffer]-workT3[r-1][4+buffer]);
         workT3[r][5+buffer] = workT3[r-1][5+buffer]+workT3Coeffs[instanceNo][_alpha]*(workT3[r][4+buffer]-workT3[r-1][5+buffer]);
      }

   //
   //
   //
   //
   //
   
   return(workT3Coeffs[instanceNo][_c1]*workT3[r][5+buffer] + 
          workT3Coeffs[instanceNo][_c2]*workT3[r][4+buffer] + 
          workT3Coeffs[instanceNo][_c3]*workT3[r][3+buffer] + 
          workT3Coeffs[instanceNo][_c4]*workT3[r][2+buffer]);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

void manageAlerts()
{
   if (alertsOn)
   {
      if (alertsOnCurrent)
           int whichBar = 0;
      else     whichBar = 1; 
      if (trend[whichBar] != trend[whichBar+1])
      {
         if (trend[whichBar] == 1) doAlert(whichBar,"up");
         if (trend[whichBar] ==-1) doAlert(whichBar,"down");
      }         
   }
}   

//
//
//
//
//

void doAlert(int forBar, string doWhat)
{
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;
   
      if (previousAlert != doWhat || previousTime != Time[forBar]) {
          previousAlert  = doWhat;
          previousTime   = Time[forBar];

          //
          //
          //
          //
          //

          message =  StringConcatenate(timeFrameToString(timeFrame)+" "+Symbol()," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," Gann T3 High low activator trends alligned to ",doWhat);
             if (alertsMessage) Alert(message);
             if (alertsEmail)   SendMail(StringConcatenate(Symbol()," Gann T3 High low activator "),message);
             if (alertsSound)   PlaySound("alert2.wav");
      }
}

//+-------------------------------------------------------------------
//|                                                                  
//+-------------------------------------------------------------------
//
//
//
//
//

string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

//
//
//
//
//

int stringToTimeFrame(string tfs)
{
   StringToUpper(tfs);
   for (int i=ArraySize(iTfTable)-1; i>=0; i--)
         if (tfs==sTfTable[i] || tfs==""+iTfTable[i]) return(MathMax(iTfTable[i],Period()));
                                                      return(Period());
}
string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}
