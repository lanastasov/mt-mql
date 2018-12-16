//+------------------------------------------------------------------+
//|                                      	 DailyPercentageChange.mq4 |
//| 				                      Copyright © 2016, EarnForex.com |
//|                                        http://www.earnforex.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, EarnForex.com"
#property link      "http://www.earnforex.com"
#property version   "1.00"
#property strict

#property description "Shows daily percentage change value (yesterday's close to current bid)."
#property description "You can set hourly shift for day start."
#property description "Can also show weekly and monthly price changes."

#property indicator_chart_window
#property indicator_plots 0

input int 	 Time_Shift  			  = 0; // Time shift for day start (-12 to +12 hours)
input bool 	 Show_Weekly  			  = true; // Show weekly change?
input bool 	 Show_Monthly 			  = true; // Show monthly change?
input int    Font_Size             = 8; // Font size
input int    Arrow_Size            = 10; // Arrow size
input color  Up_Color              = clrGreen; // Up color
input string Up_Arrow              = "p"; // Up arrow Windings code
input color  Down_Color            = clrRed; // Down color
input string Down_Arrow            = "q"; // Up arrow Windings code
input color  No_Mvt_Color          = clrBlue; // No change color

input int   X_Position_Text       = 21; // X distance for text
input int   Y_Position_Text       = 20; // Y distance for text
input ENUM_BASE_CORNER   Corner_Position_Text  = CORNER_LEFT_LOWER; // Text corner

input int   X_Position_Arrow      = 5; // X distance for arrow
input int   Y_Position_Arrow      = 20; // Y distance for arrow
input ENUM_BASE_CORNER Corner_Position_Arrow = CORNER_LEFT_LOWER; // Arrow corner

input int   X_Position_Text_W     = 21; // X distance for weekly text
input int   Y_Position_Text_W     = 35; // Y distance for weekly text
input ENUM_BASE_CORNER   Corner_Position_Text_W  = CORNER_LEFT_LOWER; // Weekly text corner

input int   X_Position_Arrow_W    = 5; // X distance for weekly arrow
input int   Y_Position_Arrow_W    = 35; // Y distance for weekly arrow
input ENUM_BASE_CORNER Corner_Position_Arrow_W = CORNER_LEFT_LOWER; // Weekly arrow corner

input int   X_Position_Text_M     = 21; // X distance for monthly text
input int   Y_Position_Text_M     = 50; // Y distance for monthly text
input ENUM_BASE_CORNER   Corner_Position_Text_M  = CORNER_LEFT_LOWER; // Monthly text corner

input int   X_Position_Arrow_M    = 5; // X distance for monthly arrow
input int   Y_Position_Arrow_M    = 50; // Y distance for monthly arrow
input ENUM_BASE_CORNER Corner_Position_Arrow_M = CORNER_LEFT_LOWER; // Monthly arrow corner

input string Text_Object = "DailyChange"; // Text object name
input string Arrow_Object = "ArrowChange"; // Arrow object name
input string Text_Object_W = "WeeklyChange"; // Weekly text object name
input string Arrow_Object_W = "ArrowChange_W"; // Weekly arrow object name
input string Text_Object_M = "MonthlyChange"; // Monthly text object name
input string Arrow_Object_M = "ArrowChange_M"; // Monthly arrow object name

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
	if ((Time_Shift > 12) || (Time_Shift < -12))
	{
		Alert("Time shift should be between -12 and 12.");
		return(INIT_FAILED);
	}
	
	return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   ObjectDelete(0, Text_Object);
   ObjectDelete(0, Arrow_Object);
   ObjectDelete(0, Text_Object_W);
   ObjectDelete(0, Arrow_Object_W);
   ObjectDelete(0, Text_Object_M);
   ObjectDelete(0, Arrow_Object_M);
   ChartRedraw();
}

//+------------------------------------------------------------------+
//| Custom Market Profile main iteration function                    |
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
   double PercChange, DailyClose = -1;
   string PerChg;
   
   if (Time_Shift == 0)
   {
   	double CloseDaily[];
   	if (CopyClose(Symbol(), PERIOD_D1, 1, 1, CloseDaily) != 1) return(0);
   	DailyClose = CloseDaily[0];
   }
   else
   {
   	double CloseHourly[];
   	datetime TimeHourly[];
		MqlDateTime datetime_str;
		if (CopyClose(Symbol(), PERIOD_H1, 0, 25, CloseHourly) != 25) return(0);
   	if (CopyTime(Symbol(), PERIOD_H1, 0, 25, TimeHourly) != 25) return(0);

   	// Current imaginary day.
   	TimeToStruct(TimeHourly[24] + Time_Shift * 3600, datetime_str);
   	int current_img_day = datetime_str.day_of_year;

   	for (int i = 23; i >= 0; i--)
   	{
			TimeToStruct(TimeHourly[i] + Time_Shift * 3600, datetime_str);
   		// Found the last hour of the previous imaginary day.
			if (datetime_str.day_of_year != current_img_day)
   		{
  				DailyClose = CloseHourly[i];
   			break;
   		}
   	}
   }

   PercChange = ((SymbolInfoDouble(Symbol(), SYMBOL_BID) - DailyClose) / DailyClose) * 100;
	PerChg = "Daily Change: " + DoubleToString(PercChange, 2) + "%";

	ShowObjects(PercChange,
					PerChg,
					Text_Object,
					Arrow_Object,
					Corner_Position_Text,
					X_Position_Text,
					Y_Position_Text,
					Corner_Position_Arrow,
					X_Position_Arrow,
					Y_Position_Arrow);

	if (Show_Weekly)
	{
   	double CloseWeekly[];
   	if (CopyClose(Symbol(), PERIOD_W1, 1, 1, CloseWeekly) != 1) return(0);
   	double WeeklyClose = CloseWeekly[0];

	   PercChange = ((SymbolInfoDouble(Symbol(), SYMBOL_BID) - WeeklyClose) / WeeklyClose) * 100;
		PerChg = "Weekly Change: " + DoubleToString(PercChange, 2) + "%";
	
		ShowObjects(PercChange,
						PerChg,
						Text_Object_W,
						Arrow_Object_W,
						Corner_Position_Text_W,
						X_Position_Text_W,
						Y_Position_Text_W,
						Corner_Position_Arrow_W,
						X_Position_Arrow_W,
						Y_Position_Arrow_W);
	}
	
	if (Show_Monthly)
	{
		double MonthlyClose = -1;
	   if (Time_Shift == 0)
	   {
	   	double CloseMonthly[];
	   	if (CopyClose(Symbol(), PERIOD_MN1, 1, 1, CloseMonthly) != 1) return(0);
	   	MonthlyClose = CloseMonthly[0];
	   }
	   else
	   {
	   	double CloseHourly[];
	   	datetime TimeHourly[];
			MqlDateTime datetime_str;
			// We will need 31 x 24 + 1 hours at maximum to look back.
			if (CopyClose(Symbol(), PERIOD_H1, 0, 31 * 24 + 1, CloseHourly) != 31 * 24 + 1) return(0);
	   	if (CopyTime(Symbol(), PERIOD_H1, 0, 31 * 24 + 1, TimeHourly) != 31 * 24 + 1) return(0);
	
	   	// Current imaginary month.
	   	TimeToStruct(TimeHourly[31 * 24] + Time_Shift * 3600, datetime_str);
	   	int current_img_month = datetime_str.mon;
	
	   	for (int i = 31 * 24; i >= 0; i--)
	   	{
				TimeToStruct(TimeHourly[i] + Time_Shift * 3600, datetime_str);
	   		// Found the last hour of the previous imaginary month.
				if (datetime_str.mon != current_img_month)
	   		{
	  				MonthlyClose = CloseHourly[i];
	   			break;
	   		}
	   	}
	   }
		
	   PercChange = ((SymbolInfoDouble(Symbol(), SYMBOL_BID) - MonthlyClose) / MonthlyClose) * 100;
		PerChg = "Monthly Change: " + DoubleToString(PercChange, 2) + "%";
	
		ShowObjects(PercChange,
						PerChg,
						Text_Object_M,
						Arrow_Object_M,
						Corner_Position_Text_M,
						X_Position_Text_M,
						Y_Position_Text_M,
						Corner_Position_Arrow_M,
						X_Position_Arrow_M,
						Y_Position_Arrow_M);
	}
	
   return(rates_total);
}

void ShowObjects(double PercChange,
					  string PerChg, 
					  string text_obj,
					  string arrow_obj,
					  ENUM_BASE_CORNER corner_pos_text,
					  int x_pos_text,
					  int y_pos_text,
					  ENUM_BASE_CORNER corner_pos_arrow,
					  int x_pos_arrow,
					  int y_pos_arrow)
{
   
   string Arrow = "";
   color Obj_Color = No_Mvt_Color;
   if (PercChange > 0)
   {
   	Arrow = Up_Arrow;
   	Obj_Color = Up_Color;
   }
   else if (PercChange < 0)
   {
   	Arrow = Down_Arrow;
   	Obj_Color = Down_Color;
   }
     
   if (ObjectFind(0, text_obj) < 0)
   {
      ObjectCreate(0, text_obj, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, text_obj, OBJPROP_CORNER, corner_pos_text);
      ObjectSetInteger(0, text_obj, OBJPROP_XDISTANCE, x_pos_text);
      ObjectSetInteger(0, text_obj, OBJPROP_YDISTANCE, y_pos_text);
      ObjectSetInteger(0, text_obj, OBJPROP_FONTSIZE, Font_Size);
      ObjectSetString(0, text_obj, OBJPROP_FONT, "Verdana");
   } 
 
   ObjectSetInteger(0, text_obj, OBJPROP_COLOR, Obj_Color);
   ObjectSetString(0, text_obj, OBJPROP_TEXT, PerChg);

	if (ObjectFind(0, arrow_obj) < 0)
   {
      ObjectCreate(0, arrow_obj, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, arrow_obj, OBJPROP_CORNER, corner_pos_arrow);
      ObjectSetInteger(0, arrow_obj, OBJPROP_XDISTANCE, x_pos_arrow);
      ObjectSetInteger(0, arrow_obj, OBJPROP_YDISTANCE, y_pos_arrow);
      ObjectSetInteger(0, arrow_obj, OBJPROP_FONTSIZE, Font_Size);
      ObjectSetString(0, arrow_obj, OBJPROP_FONT, "Wingdings 3");
   } 
   
   ObjectSetInteger(0, arrow_obj, OBJPROP_COLOR, Obj_Color);
   ObjectSetString(0, arrow_obj, OBJPROP_TEXT, Arrow);
}
//+------------------------------------------------------------------+
