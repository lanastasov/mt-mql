//+---------------------------------------------------------------------+
//|                                              Murrey_Math_Line_X.mq5 |
//|                                     Copyright © 2024, EarnForex.com |
//|                            Copyright © 2004, Vladislav Goshkov (VG) |
//|                                                         4vg@mail.ru |
//|                                    code change by Alex.Piech.FinGeR |
//| https://www.earnforex.com/metatrader-indicators/Murrey-Math-Line-X/ |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2024, EarnForex"
#property link      "https://www.earnforex.com/metatrader-indicators/Murrey-Math-Line-X/"
#property version   "1.05"

#property description "Murrey Math Line X - support and resistance lines according to Murrey Math rules."

#property indicator_chart_window
#property indicator_plots 0

// ============================================================================================
// * Line 8/8 и 0/8 (Ultimate Support and Ultimate Resistance).
// * Those lines are the most strong concerning Support and resistance.
// ============================================================================================
//* Line 7/8  (Weak, Place to Stop and Reverse).
//* This line is weak. If suddenly the price was going too fast and too far and stops around this line
//* it means the price will reverse down very soon. If the price did not stop near this line this price
//* will continue the movement to the line 8/8.
// ============================================================================================
//* Line 1/8  (Weak, Place to Stop and Reverse).
//* This line is weak. If suddenly the price was going too fast and too far and stops around this line
//* it means the price will reverse up very soon. If the price did not stop near this line this price
//* will continue the movement down to the line 0/8.
// ============================================================================================
//* Line 2/8 and 6/8 (Pivot, Reverse)
//* Those two lines yield the line 4/8 only to the strength to reverse the price movement.
// ============================================================================================
//* Line 5/8 (Top of Trading Range)
//* The price is spending the about 40% of the time on the movement between the lines 5/8 and 3/8.
//* If the price is moving near line 5/8 and stopping near the line during the 10 - 12 days so it means
//* that it is necessary to sell in this "bonus zone" (some people are doing like this) but if the price is keeping the tendency to stay above
//* 5/8 line, so it means that the price will be above. But if the price is dropping below 5/8 line it means that the price will continue
//* falling to the next level of resistance.
// ============================================================================================
//* Line 3/8 (Bottom of Trading Range).
//* If the price is below this line and in uptrend it means that it will be very difficult for the price to break this level.
//* If the price broke this line during the uptrend and staying above during the 10 12 days it means that the price will be above this line
//* during the 40% of its time moving between this line and 5/8 line.
// ============================================================================================
//* Line 4/8 (Major Support/Resistance Line).
//* It is the major line concerning support and resistance. This level is the better for the new sell or buy.
//* It is the strong level of support of the price is above 4/8. It is the fine resistance line if the price is below this 4/8 line.
// ============================================================================================

enum enum_side
{
    Left,
    Right
};

enum ENUM_CANDLE_TO_CHECK
{
    Current,
    Previous
};

input int period = 64; // Period
input ENUM_TIMEFRAMES UpperTimeframe = PERIOD_D1;
input int StepBack = 0;

input enum_side LabelSide = Left;

input color mml_clr_m_2_8 = clrWhite;  // [-2]/8 Color
input color mml_clr_m_1_8 = clrWhite;  // [-1]/8 Color
input color mml_clr_0_8   = clrAqua;   //  [0]/8 Color
input color mml_clr_1_8   = clrYellow; //  [1]/8 Color
input color mml_clr_2_8   = clrRed;    //  [2]/8 Color
input color mml_clr_3_8   = clrGreen;  //  [3]/8 Color
input color mml_clr_4_8   = clrBlue;   //  [4]/8 Color
input color mml_clr_5_8   = clrGreen;  //  [5]/8 Color
input color mml_clr_6_8   = clrRed;    //  [6]/8 Color
input color mml_clr_7_8   = clrYellow; //  [7]/8 Color
input color mml_clr_8_8   = clrAqua;   //  [8]/8 Color
input color mml_clr_p_1_8 = clrWhite;  // [+1]/8 Color
input color mml_clr_p_2_8 = clrWhite;  // [+2]/8 Color

input int   mml_wdth_m_2_8 = 2; // [-2]/8 Width
input int   mml_wdth_m_1_8 = 1; // [-1]/8 Width
input int   mml_wdth_0_8   = 1; //  [0]/8 Width
input int   mml_wdth_1_8   = 1; //  [1]/8 Width
input int   mml_wdth_2_8   = 1; //  [2]/8 Width
input int   mml_wdth_3_8   = 1; //  [3]/8 Width
input int   mml_wdth_4_8   = 1; //  [4]/8 Width
input int   mml_wdth_5_8   = 1; //  [5]/8 Width
input int   mml_wdth_6_8   = 1; //  [6]/8 Width
input int   mml_wdth_7_8   = 1; //  [7]/8 Width
input int   mml_wdth_8_8   = 1; //  [8]/8 Width
input int   mml_wdth_p_1_8 = 1; // [+1]/8 Width
input int   mml_wdth_p_2_8 = 2; // [+2]/8 Width

input color  MarkColor  = clrBlue;
input int    MarkNumber = 217;

input string FontFace = "Verdana";
input int FontSize = 10;
input string ObjectPrefix = "MML-";

input ENUM_CANDLE_TO_CHECK TriggerCandle = Previous;
input bool NativeAlerts = false;
input bool EmailAlerts = false;
input bool NotificationAlerts = false;

string ln_txt[13];

int
OctLinesCnt = 13,
mml_clr[13],
mml_wdth[13];
double mml[13];

datetime nTime = 0;

int NewPeriod = 0;

// For alerts. Each line can have its own signal.
datetime LastAlertTime[13];
int prevSignal[13];

void OnInit()
{
    if ((UpperTimeframe != PERIOD_CURRENT) && (UpperTimeframe != Period()))
    {
        NewPeriod = period * (int)MathCeil(PeriodSeconds(UpperTimeframe) / PeriodSeconds(Period()));
    }
    else
    {
        NewPeriod = period;
    }

    ln_txt[0]  = "[-2/8]P Extreme Overshoot [-2/8]";
    ln_txt[1]  = "[-1/8]P Overshoot [-1/8]";
    ln_txt[2]  = "[0/8]P Ultimate Support - extremely oversold [0/8]";
    ln_txt[3]  = "[1/8]P Weak, Place to Stop and Reverse [1/8]";
    ln_txt[4]  = "[2/8]P Pivot, Reverse - major [2/8]";
    ln_txt[5]  = "[3/8]P Bottom of Trading Range [3/8] - BUY Premium Zone";
    ln_txt[6]  = "[4/8]P Major S/R Pivot Point [4/8] - Best New BUY or SELL level";
    ln_txt[7]  = "[5/8]P Top of Trading Range [5/8] - SELL Premium Zone";
    ln_txt[8]  = "[6/8]P Pivot, Reverse - major [6/8]";
    ln_txt[9]  = "[7/8]P Weak, Place to Stop and Reverse [7/8]";
    ln_txt[10] = "[8/8]P Ultimate Resistance - extremely overbought [8/8]";
    ln_txt[11] = "[+1/8]P Overshoot [+1/8]";
    ln_txt[12] = "[+2/8]P Extreme Overshoot [+2/8]";

    // Initial setting of the lines' colors and width
    mml_clr[0]  = mml_clr_m_2_8;
    mml_wdth[0] = mml_wdth_m_2_8; // [-2]/8
    mml_clr[1]  = mml_clr_m_1_8;
    mml_wdth[1] = mml_wdth_m_1_8; // [-1]/8
    mml_clr[2]  = mml_clr_0_8;
    mml_wdth[2] = mml_wdth_0_8;   //  [0]/8
    mml_clr[3]  = mml_clr_1_8;
    mml_wdth[3] = mml_wdth_1_8;   //  [1]/8
    mml_clr[4]  = mml_clr_2_8;
    mml_wdth[4] = mml_wdth_2_8;   //  [2]/8
    mml_clr[5]  = mml_clr_3_8;
    mml_wdth[5] = mml_wdth_3_8;   //  [3]/8
    mml_clr[6]  = mml_clr_4_8;
    mml_wdth[6] = mml_wdth_4_8;   //  [4]/8
    mml_clr[7]  = mml_clr_5_8;
    mml_wdth[7] = mml_wdth_5_8;   //  [5]/8
    mml_clr[8]  = mml_clr_6_8;
    mml_wdth[8] = mml_wdth_6_8;   //  [6]/8
    mml_clr[9]  = mml_clr_7_8;
    mml_wdth[9] = mml_wdth_7_8;   //  [7]/8
    mml_clr[10] = mml_clr_8_8;
    mml_wdth[10] = mml_wdth_8_8;  //  [8]/8
    mml_clr[11] = mml_clr_p_1_8;
    mml_wdth[11] = mml_wdth_p_1_8; // [+1]/8
    mml_clr[12] = mml_clr_p_2_8;
    mml_wdth[12] = mml_wdth_p_2_8; // [+2]/8
}

void OnDeinit(const int reason)
{
    ObjectsDeleteAll(ChartID(), ObjectPrefix);
}

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &Time[],
                const double &Open[],
                const double &High[],
                const double &Low[],
                const double &Close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
    ArraySetAsSeries(High, true);
    ArraySetAsSeries(Low, true);
    ArraySetAsSeries(Open, true);
    ArraySetAsSeries(Close, true);
    ArraySetAsSeries(Time, true);

    if (nTime < Time[0])
    {
        // Price
        int bn_v1 = ArrayMinimum(Low,  StepBack, NewPeriod + StepBack);
        int bn_v2 = ArrayMaximum(High, StepBack, NewPeriod + StepBack);
    
        double v1 = Low[bn_v1];
        double v2 = High[bn_v2];
    
        double fractal = 0;
    
        // Determine fractal
        if ((v2 <= 250000) && (v2 > 25000))
            fractal = 100000;
        else if ((v2 <= 25000) && (v2 > 2500))
            fractal = 10000;
        else if ((v2 <= 2500) && (v2 > 250))
            fractal = 1000;
        else if ((v2 <= 250) && (v2 > 25))
            fractal = 100;
        else if ((v2 <= 25) && (v2 > 12.5))
            fractal = 12.5;
        else if ((v2 <= 12.5) && (v2 > 6.25))
            fractal = 12.5;
        else if ((v2 <= 6.25) && (v2 > 3.125))
            fractal = 6.25;
        else if ((v2 <= 3.125) && (v2 > 1.5625))
            fractal = 3.125;
        else if ((v2 <= 1.5625) && (v2 > 0.390625))
            fractal = 1.5625;
        else if ((v2 <= 0.390625) && (v2 > 0))
            fractal = 0.1953125;
    
        double range = v2 - v1;
        double sum = MathFloor(MathLog(fractal / range) / MathLog(2));
        double octave = fractal * (MathPow(0.5, sum));
        double mn = MathFloor(v1 / octave) * octave;
        double mx;
        if (mn + octave > v2) mx = mn + octave;
        else mx = mn + (2 * octave);
    
        // Calculating X's
        double x1, x2, x3, x4, x5, x6;
        
        // x2
        if ((v1 >= (3 * (mx - mn) / 16 + mn)) && (v2 <= (9 * (mx - mn) / 16 + mn)))
            x2 = mn + (mx - mn) / 2;
        else
            x2 = 0;
    
        // x1
        if ((v1 >= (mn - (mx - mn) / 8)) && (v2 <= (5 * (mx - mn) / 8 + mn)) && (x2 == 0))
            x1 = mn + (mx - mn) / 2;
        else
            x1 = 0;
    
        // x4
        if ((v1 >= (mn + 7 * (mx - mn) / 16)) && (v2 <= (13 * (mx - mn) / 16 + mn)))
            x4 = mn + 3 * (mx - mn) / 4;
        else x4 = 0;
    
        // x5
        if ((v1 >= (mn + 3 * (mx - mn) / 8)) && (v2 <= (9 * (mx - mn) / 8 + mn)) && (x4 == 0))
            x5 = mx;
        else
            x5 = 0;
    
        // x3
        if ((v1 >= (mn + (mx - mn) / 8)) && (v2 <= (7 * (mx - mn) / 8 + mn)) && (x1 == 0) && (x2 == 0) && (x4 == 0) && (x5 == 0))
            x3 = mn + 3 * (mx - mn) / 4;
        else
            x3 = 0;
    
        // x6
        if ((x1 + x2 + x3 + x4 + x5) == 0)
            x6 = mx;
        else
            x6 = 0;
    
        double finalH = x1 + x2 + x3 + x4 + x5 + x6;
    
        // Calculating Y's
        double y1, y2, y3, y4, y5, y6;
    
        // y1
        if (x1 > 0)
            y1 = mn;
        else
            y1 = 0;
    
        // y2
        if (x2 > 0)
            y2 = mn + (mx - mn) / 4;
        else
            y2 = 0;
    
        // y3
        if (x3 > 0)
            y3 = mn + (mx - mn) / 4;
        else
            y3 = 0;
    
        // y4
        if (x4 > 0)
            y4 = mn + (mx - mn) / 2;
        else
            y4 = 0;
    
        // y5
        if (x5 > 0)
            y5 = mn + (mx - mn) / 2;
        else
            y5 = 0;
    
        // y6
        if ((finalH > 0) && ((y1 + y2 + y3 + y4 + y5) == 0))
            y6 = mn;
        else
            y6 = 0;
    
        double finalL = y1 + y2 + y3 + y4 + y5 + y6;
    
        double dmml = (finalH - finalL) / 8;
    
        mml[0] = (finalL - dmml * 2); //-2/8
    
        for (int i = 1; i < OctLinesCnt; i++)
            mml[i] = mml[i - 1] + dmml;
    
        int first_bar = (int)ChartGetInteger(0, CHART_FIRST_VISIBLE_BAR);
        
        if (first_bar == 0) return 0; // Data not ready.
    
        if (LabelSide == Right) first_bar = 1;
    
        for (int i = 0; i < OctLinesCnt; i++)
        {
            string name = ObjectPrefix + IntegerToString(i);
            if (ObjectFind(0, name) == -1)
            {
                ObjectCreate(0, name, OBJ_HLINE, 0, Time[0], mml[i]);
                ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
                ObjectSetInteger(0, name, OBJPROP_COLOR, mml_clr[i]);
                ObjectSetInteger(0, name, OBJPROP_WIDTH, mml_wdth[i]);
            }
            else ObjectMove(0, name, 0, Time[0], mml[i]);
    
            name = ObjectPrefix + "txt" + IntegerToString(i);
            if (ObjectFind(0, name) == -1)
            {
                ObjectCreate(0, name, OBJ_TEXT, 0, Time[first_bar - 1], mml[i]);
                ObjectSetString(0,  name, OBJPROP_TEXT, ln_txt[i]);
                ObjectSetInteger(0, name, OBJPROP_FONTSIZE, FontSize);
                ObjectSetString(0,  name, OBJPROP_FONT, FontFace);
                ObjectSetInteger(0, name, OBJPROP_COLOR, mml_clr[i]);
                ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
            }
            else ObjectMove(0, name, 0, Time[first_bar - 1],  mml[i]);
        }
    
        string name = ObjectPrefix + "LatestCalcBar";
        if (ObjectFind(0, name) == -1)
        {
            ObjectCreate(0, name, OBJ_ARROW, 0, Time[StepBack], Low[StepBack] - 2 * _Point);
            ObjectSetInteger(0, name, OBJPROP_ARROWCODE, MarkNumber);
            ObjectSetInteger(0, name, OBJPROP_COLOR, MarkColor);
        }
        else ObjectMove(0, name, 0, Time[StepBack], Low[StepBack] - 2 * _Point);

        nTime = Time[0];
    }

    if ((!NativeAlerts) && (!EmailAlerts) && (!NotificationAlerts)) return rates_total;

    for (int i = 0; i < 13; i++) // Process alerts for each line.
    {
        // Current Signal calculation.
        int Signal = 0; // No signal at all.
        
        // UP: Current Close above the Line while either current Open is below the Line or previous Close is below the Line.
        if (Close[TriggerCandle] > mml[i])
        {
            if (((Open[TriggerCandle] <= mml[i])) || (Close[TriggerCandle + 1] <= mml[i])) Signal =  1;
        }
        // DOWN: Current Close below the Line while either current Open is above the Line or previous Close is above the Line.
        else if (Close[TriggerCandle] < mml[i])
        {
            if (((Open[TriggerCandle] >= mml[i])) || (Close[TriggerCandle + 1] >= mml[i])) Signal =  -1;
        }
        
        if (prevSignal[i] == 42) // Avoiding initial alert.
        {
            prevSignal[i] = Signal;
            continue;
        }

        if (((TriggerCandle > 0) && (Time[TriggerCandle] > LastAlertTime[i])) || (TriggerCandle == 0))
        {
            string Text, TextNative;
            // UP signal.
            if ((Signal == 1) && (prevSignal[i] != 1))
            {
                Text = "MMLX: " + Symbol() + " - " + StringSubstr(EnumToString((ENUM_TIMEFRAMES)Period()), 7) + " - Breach Up: " + ln_txt[i] + " at " + DoubleToString(mml[i], _Digits) + ".";
                TextNative = "Breach Up: " + ln_txt[i] + " at " + DoubleToString(mml[i], _Digits) + ".";
                DoAlerts(Text, TextNative);
                LastAlertTime[i] = Time[TriggerCandle];
            }
            // DOWN signal.
            else if ((Signal == -1) && (prevSignal[i] != -1))
            {
                Text = "MMLX: " + Symbol() + " - " + StringSubstr(EnumToString((ENUM_TIMEFRAMES)Period()), 7) + " - Breach Down: " + ln_txt[i] + " at " + DoubleToString(mml[i], _Digits) + ".";
                TextNative = "Breach Down: " + ln_txt[i] + " at " + DoubleToString(mml[i], _Digits) + ".";
                DoAlerts(Text, TextNative);
                LastAlertTime[i] = Time[TriggerCandle];
            }
        }
        prevSignal[i] = Signal;
    }

    return rates_total;
}

void DoAlerts(string Text, string TextNative)
{
    if (NativeAlerts) Alert(TextNative);
    if (EmailAlerts) SendMail(Text, Text);
    if (NotificationAlerts) SendNotification(Text);
}
//+------------------------------------------------------------------+
