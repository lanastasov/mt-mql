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
    // Array to store the EMA values
    double emaValues[];
    
    // Copy the last EMA value
    if(CopyBuffer(EmaHandle, 0, 0, 1, emaValues) > 0)
    {
        double emaValue = emaValues[0];
        Print("Current 200 EMA value: ", emaValue);
    }
    else
    {
        int error = GetLastError();
        Print("Failed to copy EMA value. Error code: ", error);
    }
    
    MqlRates rates[];
    if(CopyRates(_Symbol, PERIOD_CURRENT, 0, 1, rates) > 0)
    {
        double closingPrice = rates[0].close;
        Print("Current closing price of ", _Symbol, ": ", closingPrice);
    }
    else
    {
        Print("Failed to get rates data. Error code: ", GetLastError());
    }

}
