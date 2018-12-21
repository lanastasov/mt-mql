//+------------------------------------------------------------------+
//|                                                   PriceAlert.mq5 |
//|                         Copyright © 2009-2011, www.earnforex.com |
//|           Issues sound alerts when price reaches certain levels. |
//+------------------------------------------------------------------+
#property copyright "EarnForex.com"
#property link      "http://www.earnforex.com"
#property version   "1.01"

#property description "Update 1.01: Dragging lines on chart will now change the alert levels."

#property indicator_chart_window

input double SoundWhenPriceGoesAbove = 0;
input double SoundWhenPriceGoesBelow = 0;
input double SoundWhenPriceIsExactly = 0;
input bool SendEmail = false; //If true e-mail is sent to the e-mail address set in your MT5. E-mail SMTP Server settings should also be configured in your MT5.

//Vars to substitute input parameters to be able to modify them
double SWPGB;
double SWPGA;
double SWPIE;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit() 
{
   if (SoundWhenPriceIsExactly > 0)
   {
      SWPIE = SoundWhenPriceIsExactly;
      ObjectCreate(0, "SoundWhenPriceIsExactly", OBJ_HLINE, 0, TimeCurrent(), SoundWhenPriceIsExactly);
      ObjectSetInteger(0, "SoundWhenPriceIsExactly", OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, "SoundWhenPriceIsExactly", OBJPROP_COLOR, Yellow);
      ObjectSetInteger(0, "SoundWhenPriceIsExactly", OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, "SoundWhenPriceIsExactly", OBJPROP_SELECTABLE, true);
   }
   if (SoundWhenPriceGoesAbove > 0)
   {
      SWPGA = SoundWhenPriceGoesAbove;
      ObjectCreate(0, "SoundWhenPriceGoesAbove", OBJ_HLINE, 0, TimeCurrent(), SoundWhenPriceGoesAbove);
      ObjectSetInteger(0, "SoundWhenPriceGoesAbove", OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, "SoundWhenPriceGoesAbove", OBJPROP_COLOR, Green);
      ObjectSetInteger(0, "SoundWhenPriceGoesAbove", OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, "SoundWhenPriceGoesAbove", OBJPROP_SELECTABLE, true);
   }
   if (SoundWhenPriceGoesBelow > 0)
   {
      SWPGB = SoundWhenPriceGoesBelow;
      ObjectCreate(0, "SoundWhenPriceGoesBelow", OBJ_HLINE, 0, TimeCurrent(), SoundWhenPriceGoesBelow);
      ObjectSetInteger(0, "SoundWhenPriceGoesBelow", OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, "SoundWhenPriceGoesBelow", OBJPROP_COLOR, Red);
      ObjectSetInteger(0, "SoundWhenPriceGoesBelow", OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, "SoundWhenPriceGoesBelow", OBJPROP_SELECTABLE, true);
   }
}

//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   ObjectDelete(0, "SoundWhenPriceIsExactly");
   ObjectDelete(0, "SoundWhenPriceGoesAbove");
   ObjectDelete(0, "SoundWhenPriceGoesBelow");
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   double Ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double Bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   if ((Ask > SWPGA) && (SWPGA > 0))
   {
      Alert("Price above the alert level.");
      PlaySound("alert.wav");
      SendMail("Price for " + Symbol() +  " above the alert level " + DoubleToString(Ask), "Price for " + Symbol() +  " reached " + DoubleToString(Ask) + " level, which is above your alert level of " + DoubleToString(SWPGA));
      ObjectDelete(0, "SoundWhenPriceGoesAbove");
      SWPGA = 0;
   }
   if ((Bid < SWPGB) && (SWPGB > 0))
   {
      Alert("Price below the alert level.");
      PlaySound("alert.wav");
      SendMail("Price for " + Symbol() +  " below the alert level " + DoubleToString(Bid), "Price for " + Symbol() +  " reached " + DoubleToString(Bid) + " level, which is below your alert level of " + DoubleToString(SWPGB));
      ObjectDelete(0, "SoundWhenPriceGoesBelow");
      SWPGB = 0;
   }
   if ((Bid == SWPIE) || (Ask == SWPIE))
   {
      Alert("Price is exactly at the alert level.");
      PlaySound("alert.wav");
      SendMail("Price for " + Symbol() +  " exactly at the alert level " + DoubleToString(Ask), "Price for " + Symbol() +  " reached " + DoubleToString(Ask) + "/" + DoubleToString(Bid) + " level, which is exactly your alert level of " + DoubleToString(SWPIE));
      ObjectDelete(0, "SoundWhenPriceIsExactly");
      SWPIE = 0;
   }
   return(rates_total);
}

void OnChartEvent(const int id,         
                  const long& lparam,   
                  const double& dparam, 
                  const string& sparam)
{
	if (id != CHARTEVENT_OBJECT_DRAG) return;
	
	double newprice = ObjectGetDouble(0, sparam, OBJPROP_PRICE);
	
	if (sparam == "SoundWhenPriceIsExactly") SWPIE = newprice;
	else if (sparam == "SoundWhenPriceGoesAbove") SWPGA = newprice;
	else if (sparam == "SoundWhenPriceGoesBelow") SWPGB = newprice;
}  
//+------------------------------------------------------------------+
