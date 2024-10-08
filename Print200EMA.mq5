//+--------------------------------------------------------------------+
//|                                               Print200EMA.mq5      |
//|                        Copyright 2024,        lanastasov           |
//|                                               https://www.mql5.com |
//+--------------------------------------------------------------------+
#property copyright "Copyright 2024, lanastasov"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

input ENUM_APPLIED_PRICE AppliedPrice = PRICE_CLOSE; // Applied price for EMA calculation

int EmaHandle;
int DailyEmaHandle;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    // Create the EMA indicator handle
    EmaHandle = iMA(_Symbol, PERIOD_CURRENT, 200, 0, MODE_EMA, AppliedPrice);
    
    if(EmaHandle == INVALID_HANDLE)
    {
        Print("Failed to create EMA indicator handle");
        return(INIT_FAILED);
    }
    
    DailyEmaHandle = iMA(_Symbol, PERIOD_D1, 200, 0, MODE_EMA, AppliedPrice);
    if(DailyEmaHandle == INVALID_HANDLE)
    {
        Print("Failed to create EMA indicator handle");
        return(INIT_FAILED);
    }
    
    // Array to store the EMA values
    double emaValues[];
    double closingPrice;
    double emaValue;
    double dailyemaValues[];
    double dailyemaValue;
    
    // Copy the last EMA value
    if(CopyBuffer(EmaHandle, 0, 0, 1, emaValues) > 0)
    {
        emaValue = emaValues[0];
        Print("Current 200 EMA value: ", emaValue);
    }
    else
    {
        int error = GetLastError();
        Print("Failed to copy EMA value. Error code: ", error);
    }
   
    if(CopyBuffer(DailyEmaHandle, 0, 0, 1, dailyemaValues) > 0)
    {
        dailyemaValue = dailyemaValues[0];
        Print("Current Daily 200 EMA value: ", dailyemaValue);
    }
    else
    {
        int error = GetLastError();
        Print("Failed to copy EMA value. Error code: ", error);
    }
    
    MqlRates rates[];
    if(CopyRates(_Symbol, PERIOD_CURRENT, 0, 1, rates) > 0)
    {
       closingPrice = rates[0].close;
       Print("Current closing price of ", _Symbol, ": ", closingPrice);
    }
    else
    {
       Print("Failed to get rates data. Error code: ", GetLastError());
    }
    
        
    double distancePercent = ((closingPrice - emaValue) / emaValue) * 100;
    Print("Distance in Percent: ", distancePercent, "%");
    
    double dailydistancePercent = ((closingPrice - dailyemaValue) / dailyemaValue) * 100;
    Print("Daily Distance in Percent: ", dailydistancePercent, "%");   
    
    
    // Create a text label on the chart
    string labelName = "Daily-200EMA_Distance_Label-To-Current-Close-Price";
    if (ObjectFind(0, labelName) == -1)
    {
        ObjectCreate(0, labelName, OBJ_LABEL, 0, 0, 0);
    }

    // Set the label properties
    ObjectSetString(0, labelName, OBJPROP_TEXT, dailydistancePercent);
    ObjectSetInteger(0, labelName, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
    ObjectSetInteger(0, labelName, OBJPROP_XDISTANCE, 100);
    ObjectSetInteger(0, labelName, OBJPROP_YDISTANCE, 20);
    ObjectSetInteger(0, labelName, OBJPROP_COLOR, clrBlack);
    ObjectSetInteger(0, labelName, OBJPROP_FONTSIZE, 12);
    
    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    // Release the indicator handle
    if(EmaHandle != INVALID_HANDLE)
        IndicatorRelease(EmaHandle);
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
    
     
    
}
