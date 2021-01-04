//+------------------------------------------------------------------+
//|                                                   SweetSpots.mq4 |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright Shimodax"
#property link      "http://www.strategybuilderfx.com"

#property indicator_chart_window

/* Introduction:

   This indicator shows lines at sweet spots (50 and 100 
   pips levels). It is recommended to turn off the grid.
   
   Enjoy!

   Markus
*/

extern int NumLinesAboveBelow= 100;
extern int SweetSpotMainLevels= 100;
extern color LineColorMain= Gold;
extern int LineStyleMain= STYLE_SOLID;
extern bool ShowSubLevels= true;
extern int sublevels= 250;
extern color LineColorSub= Gold;
extern int LineStyleSub= STYLE_DOT;



//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   return(0);
}

int deinit()
{
   int obj_total= ObjectsTotal();
   
   for (int i= obj_total; i>=0; i--) {
      string name= ObjectName(i);
    
      if (StringSubstr(name,0,11)=="[SweetSpot]") 
         ObjectDelete(name);
   }
   
   return(0);
}
  
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
   static datetime timelastupdate= 0;
   static datetime lasttimeframe= 0;
   
    
   // no need to update these buggers too often   
   if (CurTime()-timelastupdate < 600 && Period()==lasttimeframe)
      return (0);
   
   deinit();  // delete all previous lines
      
   int i, ssp1, style, ssp, thickness; //sublevels= 50;
   double ds1;
   color linecolor;
   
   if (!ShowSubLevels)
      sublevels*= 2;
   
   ssp1= Bid / Point;
   ssp1= ssp1 - ssp1%sublevels;

   for (i= -NumLinesAboveBelow; i<NumLinesAboveBelow; i++) {
   
      ssp= ssp1+(i*sublevels); 
      
      if (ssp%SweetSpotMainLevels==0) {
         style= LineStyleMain;
         linecolor= LineColorMain;
      }
      else {
         style= LineStyleSub;
         linecolor= LineColorSub;
      }
      
      thickness= 1;
      
      if (ssp%(SweetSpotMainLevels*10)==0) {
         thickness= 2;      
      }

      if (ssp%(SweetSpotMainLevels*100)==0) {
         thickness= 3;      
      }
      
      ds1= ssp*Point;
      SetLevel(DoubleToStr(ds1,Digits), ds1,  linecolor, style, thickness, Time[10]);
   }

   return(0);
}


//+------------------------------------------------------------------+
//| Helper                                                           |
//+------------------------------------------------------------------+
void SetLevel(string text, double level, color col1, int linestyle, int thickness, datetime startofday)
{
   int digits= Digits;
   string linename= "[SweetSpot] " + text + " Line",
          pricelabel; 

   // create or move the horizontal line   
   if (ObjectFind(linename) != 0) {
      ObjectCreate(linename, OBJ_HLINE, 0, 0, level);
      ObjectSet(linename, OBJPROP_STYLE, linestyle);
      ObjectSet(linename, OBJPROP_COLOR, col1);
      ObjectSet(linename, OBJPROP_WIDTH, thickness);
      
      ObjectSet(linename, OBJPROP_BACK, True);
   }
   else {
      ObjectMove(linename, 0, Time[0], level);
   }
}
      
