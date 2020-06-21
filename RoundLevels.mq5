//+------------------------------------------------------------------+
//|                                                  RoundLevels.mq5 |
//|                                  Copyright © 2020, Andriy Moraru |
//|                                       https://www.earnforex.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2020 www.EarnForex.com"
#property link      "https://www.earnforex.com/metatrader-indicators/Round-Levels/"
#property version   "1.00"
#property strict

#property description "Generates round level zone background shading on chart."

#property indicator_chart_window 
#property indicator_plots 0

input int Levels = 5; // Levels - number of level zones in each direction.
input int Interval = 50; // Interval between zones in points.
input int ZoneWidth = 10; // Zone width in points.
input color ColorUp = clrFireBrick;
input color ColorDn = clrDarkGreen;
input bool InvertZones = false; // Invert zones to shade the areas between round numbers.
input bool DrawLines = false; // Draw lines on levels.
input color LineColor = clrDarkGray;
input int LineWidth = 1;
input ENUM_LINE_STYLE LineStyle = STYLE_DASHDOT;
input string ObjectPrefix = "RoundLevels";

enum direction
{
   Up,
   Down
};

void OnDeinit(const int reason)
{
	ObjectsDeleteAll(0, ObjectPrefix);
}

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
{
   double starting_price = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits);
   
   for (int i = 0; i < Levels; i++)
   {
      // Calculate price levels below and above the current price.
      double lvl_down = FindNextLevel(NormalizeDouble(starting_price - i * Interval * _Point, _Digits), Down);
      double lvl_up = FindNextLevel(NormalizeDouble(starting_price + i * Interval * _Point, _Digits), Up);
      
      // Calculate and draw rectangle below current price.
      string name = ObjectPrefix + "D" + IntegerToString(i);
      double price1, price2;
      if (InvertZones)
      {
         price1 = lvl_down - (ZoneWidth / 2 * _Point);
         price2 = lvl_down - ((Interval - ZoneWidth / 2) * _Point);
      }
      else
      {
         price1 = lvl_down + (ZoneWidth / 2 * _Point);
         price2 = lvl_down - (ZoneWidth / 2 * _Point);
      }
      DrawRectangle(name, price1, price2, ColorDn);
      name = ObjectPrefix + "LD" + IntegerToString(i);
      if (DrawLines) DrawLine(name, lvl_down);

      // Calculate and draw rectangle above current price.
      name = ObjectPrefix + "U" + IntegerToString(i);
      if (InvertZones)
      {
         price1 = lvl_up + ((Interval - ZoneWidth / 2) * _Point);
         price2 = lvl_up + (ZoneWidth / 2 * _Point);
      }
      else
      {
         price1 = lvl_up + (ZoneWidth / 2 * _Point);
         price2 = lvl_up - (ZoneWidth / 2 * _Point);
      }         
      DrawRectangle(name, price1, price2, ColorUp);
      name = ObjectPrefix + "LU" + IntegerToString(i);
      if (DrawLines) DrawLine(name, lvl_up);
   }
   
   // Center level required for inverted zones.
   if (InvertZones)
   {
      double lvl_down = FindNextLevel(NormalizeDouble(starting_price, _Digits), Down);
      double lvl_up = FindNextLevel(NormalizeDouble(starting_price, _Digits), Up);
      string name = ObjectPrefix + "C";
      double price1 = lvl_up - (ZoneWidth / 2 * _Point);
      double price2 = lvl_down + (ZoneWidth / 2 * _Point);
      DrawRectangle(name, price1, price2, (ColorDn + ColorUp) / 2);
      name = ObjectPrefix + "LC";
      if (DrawLines)
      {
         DrawLine(name, lvl_up);
         DrawLine(name, lvl_down);
      }
   }

   return(0);
}

double FindNextLevel(double sp, direction dir)
{
   // Multiplier for getting number of points in the price.
   double multiplier = MathPow(10, _Digits);
   // Integer price (nubmer of points in the price).
   int integer_price = (int)MathRound(sp * MathPow(10, _Digits));
   // Distance from the next round number down.
   int distance = integer_price % Interval;
   if (dir == Down)
   {
      return(NormalizeDouble(MathRound(integer_price - distance) / multiplier, _Digits));
   }
   else if (dir == Up)
   {
      return(NormalizeDouble((integer_price + (Interval - distance)) / multiplier, _Digits));
   }
   return(EMPTY_VALUE);
}

void DrawRectangle(string name, double price1, double price2, color colour)
{
   if (ObjectFind(0, name) < 0) ObjectCreate(0, name, OBJ_RECTANGLE, 0, 0, 0);
   ObjectSetDouble(0, name, OBJPROP_PRICE, 0, price1);
   ObjectSetDouble(0, name, OBJPROP_PRICE, 1, price2);
   ObjectSetInteger(0, name, OBJPROP_TIME, 0, D'1970.01.01');
   ObjectSetInteger(0, name, OBJPROP_TIME, 1, TimeLocal() + 60 * PeriodSeconds());
   ObjectSetInteger(0, name, OBJPROP_COLOR, colour);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_BACK, true);
   ObjectSetInteger(0, name, OBJPROP_FILL, true);
}

void DrawLine(string name, double price)
{
   if (ObjectFind(0, name) < 0) ObjectCreate(0, name, OBJ_HLINE, 0, 0, 0);
   ObjectSetDouble(0, name, OBJPROP_PRICE, 0, price);
   ObjectSetInteger(0, name, OBJPROP_COLOR, LineColor);
   ObjectSetInteger(0, name, OBJPROP_STYLE, LineStyle);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, LineWidth);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
}
//+------------------------------------------------------------------+
